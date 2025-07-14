import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/payment_models.dart';

/// 支付服务
/// 
/// 提供完整的支付功能，包括获取支付方式、创建支付订单、处理支付流程等
class PaymentService {
  final String _baseUrl;
  final Map<String, String> _headers;

  PaymentService(this._baseUrl, this._headers);

  /// 获取支付方式列表
  /// 
  /// 返回当前可用的所有支付方式
  Future<List<PaymentMethodInfo>> getPaymentMethods() async {
    final client = http.Client();
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/api/v1/user/order/getPaymentMethod'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] != true) {
          throw PaymentError.invalidResponse(data['message']?.toString());
        }

        final methodsList = (data['data'] as List).cast<Map<String, dynamic>>();
        return methodsList
            .map((json) => PaymentMethodInfo.fromJson(json))
            .where((method) => method.isAvailable)
            .toList();
      } else {
        throw PaymentError.networkError('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (e is PaymentError) rethrow;
      throw PaymentError.fromException(e);
    }
  }

  /// 获取可用的支付方式列表（带金额验证）
  /// 
  /// [amount] 支付金额，用于过滤可用的支付方式
  Future<List<PaymentMethodInfo>> getAvailablePaymentMethods(double amount) async {
    final allMethods = await getPaymentMethods();
    return allMethods.where((method) => method.isAmountValid(amount)).toList();
  }

  /// 根据ID获取支付方式详情
  /// 
  /// [methodId] 支付方式ID
  Future<PaymentMethodInfo?> getPaymentMethodById(String methodId) async {
    final methods = await getPaymentMethods();
    try {
      return methods.firstWhere((method) => method.id == methodId);
    } catch (e) {
      return null;
    }
  }

  /// 提交订单支付
  /// 
  /// [request] 支付请求参数
  /// 返回支付响应，包含支付结果信息
  Future<PaymentResponse> submitOrderPayment(PaymentRequest request) async {
    final client = http.Client();
    try {
      // 验证支付方式是否可用
      final paymentMethod = await getPaymentMethodById(request.method);
      if (paymentMethod == null) {
        throw PaymentError.paymentMethodUnavailable('Payment method ${request.method} not found');
      }

      if (!paymentMethod.isAvailable) {
        throw PaymentError.paymentMethodUnavailable('Payment method ${request.method} is not available');
      }

      final response = await client.post(
        Uri.parse('$_baseUrl/api/v1/user/order/checkout'),
        headers: {
          ..._headers,
          'Content-Type': 'application/json',
        },
        body: json.encode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return PaymentResponse.fromJson(data);
      } else {
        throw PaymentError.networkError('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (e is PaymentError) rethrow;
      throw PaymentError.fromException(e);
    }
  }

  /// 查询支付状态
  /// 
  /// [tradeNo] 订单交易号
  /// 返回支付状态结果
  Future<PaymentStatusResult> checkPaymentStatus(String tradeNo) async {
    final client = http.Client();
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/api/v1/user/order/status?trade_no=$tradeNo'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] != true) {
          throw PaymentError.invalidResponse(data['message']?.toString());
        }

        final statusData = data['data'] as Map<String, dynamic>;
        final status = statusData['status']?.toString().toLowerCase();
        
        switch (status) {
          case 'paid':
          case 'success':
          case 'completed':
            return PaymentStatusResult.success(statusData['message'] as String?);
          case 'cancelled':
          case 'canceled':
          case 'cancel':
            return PaymentStatusResult.canceled(statusData['message'] as String?);
          case 'pending':
          case 'processing':
          case 'waiting':
            return PaymentStatusResult.pending(statusData['message'] as String?);
          default:
            return PaymentStatusResult.failed(statusData['message'] as String? ?? 'Unknown status: $status');
        }
      } else {
        throw PaymentError.networkError('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (e is PaymentError) rethrow;
      throw PaymentError.fromException(e);
    }
  }

  /// 取消支付
  /// 
  /// [tradeNo] 订单交易号
  Future<bool> cancelPayment(String tradeNo) async {
    final client = http.Client();
    try {
      final response = await client.post(
        Uri.parse('$_baseUrl/api/v1/user/order/cancel'),
        headers: {
          ..._headers,
          'Content-Type': 'application/json',
        },
        body: json.encode({'trade_no': tradeNo}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else {
        throw PaymentError.networkError('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (e is PaymentError) rethrow;
      throw PaymentError.fromException(e);
    }
  }

  /// 计算支付总金额（包含手续费）
  /// 
  /// [amount] 原始金额
  /// [methodId] 支付方式ID
  Future<double> calculateTotalAmount(double amount, String methodId) async {
    final paymentMethod = await getPaymentMethodById(methodId);
    if (paymentMethod == null) {
      throw PaymentError.paymentMethodUnavailable('Payment method $methodId not found');
    }
    return paymentMethod.calculateTotalAmount(amount);
  }

  /// 验证支付金额
  /// 
  /// [amount] 支付金额
  /// [methodId] 支付方式ID
  Future<bool> validatePaymentAmount(double amount, String methodId) async {
    if (amount <= 0) {
      throw PaymentError.invalidAmount('Amount must be greater than 0');
    }

    final paymentMethod = await getPaymentMethodById(methodId);
    if (paymentMethod == null) {
      throw PaymentError.paymentMethodUnavailable('Payment method $methodId not found');
    }

    return paymentMethod.isAmountValid(amount);
  }

  /// 预检查支付条件
  /// 
  /// [request] 支付请求
  /// 验证支付条件是否满足
  Future<void> preCheckPayment(PaymentRequest request) async {
    // 检查支付方式
    final paymentMethod = await getPaymentMethodById(request.method);
    if (paymentMethod == null) {
      throw PaymentError.paymentMethodUnavailable('Payment method ${request.method} not found');
    }

    if (!paymentMethod.isAvailable) {
      throw PaymentError.paymentMethodUnavailable('Payment method ${request.method} is not available');
    }

    // 可以添加更多预检查逻辑，比如检查订单状态等
  }

  /// 完整的支付流程
  /// 
  /// [tradeNo] 订单交易号
  /// [methodId] 支付方式ID
  /// [callbackUrl] 回调URL（可选）
  /// 
  /// 返回支付结果，自动处理支付流程
  Future<PaymentResult> processPayment({
    required String tradeNo,
    required String methodId,
    String? callbackUrl,
    Map<String, dynamic>? extra,
  }) async {
    try {
      // 创建支付请求
      final request = PaymentRequest(
        tradeNo: tradeNo,
        method: methodId,
        callbackUrl: callbackUrl,
        extra: extra,
      );

      // 预检查
      await preCheckPayment(request);

      // 提交支付
      final response = await submitOrderPayment(request);

      if (response.success && response.result != null) {
        return response.result!;
      } else {
        return PaymentResult.failed(
          message: response.message ?? 'Payment failed',
          extra: response.data,
        );
      }
    } catch (e) {
      if (e is PaymentError) {
        return PaymentResult.failed(
          message: e.message,
          errorCode: e.errorCode,
        );
      }
      return PaymentResult.failed(
        message: e.toString(),
        errorCode: 'UNKNOWN_ERROR',
      );
    }
  }

  /// 轮询支付状态
  /// 
  /// [tradeNo] 订单交易号
  /// [maxAttempts] 最大尝试次数
  /// [intervalSeconds] 轮询间隔（秒）
  /// 
  /// 持续检查支付状态直到完成或超时
  Future<PaymentStatusResult> pollPaymentStatus({
    required String tradeNo,
    int maxAttempts = 60,
    int intervalSeconds = 3,
  }) async {
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final result = await checkPaymentStatus(tradeNo);
        
        // 如果是最终状态，直接返回
        if (result.isSuccess || result.isCanceled || !result.isPending) {
          return result;
        }

        // 等待下次轮询
        if (attempt < maxAttempts - 1) {
          await Future.delayed(Duration(seconds: intervalSeconds));
        }
      } catch (e) {
        // 记录错误但继续轮询
        if (attempt == maxAttempts - 1) {
          return PaymentStatusResult.failed('Polling timeout: ${e.toString()}');
        }
        await Future.delayed(Duration(seconds: intervalSeconds));
      }
    }

    return PaymentStatusResult.failed('Payment status polling timeout');
  }

  /// 创建订单并支付的完整流程
  /// 
  /// 整合订单创建和支付流程，提供一站式服务
  /// 
  /// [planId] 计划ID
  /// [period] 订购周期
  /// [methodId] 支付方式ID
  /// [couponCode] 优惠券代码（可选）
  /// [callbackUrl] 支付回调URL（可选）
  Future<PaymentResult> createOrderAndPay({
    required int planId,
    required String period,
    required String methodId,
    String? couponCode,
    String? callbackUrl,
  }) async {
    try {
      // 注意：这里需要先创建订单，然后支付
      // 实际使用时，您可能需要先调用 OrderService.createOrder() 获取 tradeNo
      throw PaymentError.preCheckFailed(
        'This method requires OrderService integration. Please create order first, then use processPayment().'
      );
    } catch (e) {
      if (e is PaymentError) rethrow;
      throw PaymentError.fromException(e);
    }
  }

  /// 获取支付历史
  /// 
  /// [limit] 限制返回数量
  /// [offset] 偏移量
  Future<List<Map<String, dynamic>>> getPaymentHistory({
    int limit = 20,
    int offset = 0,
  }) async {
    final client = http.Client();
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/api/v1/user/payment/history?limit=$limit&offset=$offset'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] != true) {
          throw PaymentError.invalidResponse(data['message']?.toString());
        }

        return (data['data'] as List).cast<Map<String, dynamic>>();
      } else {
        throw PaymentError.networkError('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (e is PaymentError) rethrow;
      throw PaymentError.fromException(e);
    }
  }

  /// 获取支付统计信息
  /// 
  /// 返回支付相关的统计数据
  Future<Map<String, dynamic>> getPaymentStats() async {
    final client = http.Client();
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/api/v1/user/payment/stats'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] != true) {
          throw PaymentError.invalidResponse(data['message']?.toString());
        }

        return data['data'] as Map<String, dynamic>;
      } else {
        throw PaymentError.networkError('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } catch (e) {
      if (e is PaymentError) rethrow;
      throw PaymentError.fromException(e);
    }
  }
} 