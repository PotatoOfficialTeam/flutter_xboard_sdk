import 'package:flutter_xboard_sdk/src/services/http_service.dart';
import 'package:flutter_xboard_sdk/src/features/payment/payment_models.dart';
import 'package:flutter_xboard_sdk/src/common/models/api_response.dart';
import 'package:flutter_xboard_sdk/src/exceptions/xboard_exceptions.dart';

class PaymentApi {
  final HttpService _httpService;

  PaymentApi(this._httpService);

  /// 获取支付方式列表
  Future<ApiResponse<List<PaymentMethodInfo>>> getPaymentMethods() async {
    try {
      final result = await _httpService.getRequest('/api/v1/user/order/getPaymentMethod');
      return ApiResponse.fromJson(result, (json) => (json as List<dynamic>).map((e) => PaymentMethodInfo.fromJson(e as Map<String, dynamic>)).toList());
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('获取支付方式失败: $e');
    }
  }

  /// 提交订单支付
  Future<ApiResponse<Map<String, dynamic>>> submitOrderPayment(PaymentRequest request) async {
    try {
      final result = await _httpService.postRequest('/api/v1/user/order/checkout', request.toJson());
      
      // HttpService会自动包装成: {success: true, data: {type: 1, data: "url"}}
      // 我们直接使用ApiResponse.fromJson解析
      return ApiResponse.fromJson(result, (json) => json as Map<String, dynamic>);
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('提交订单支付失败: $e');
    }
  }

  /// 查询支付状态
  Future<ApiResponse<PaymentStatusResult>> checkPaymentStatus(String tradeNo) async {
    try {
      final result = await _httpService.getRequest('/api/v1/user/order/status?trade_no=$tradeNo');
      return ApiResponse.fromJson(result, (json) => PaymentStatusResult.fromJson(json as Map<String, dynamic>));
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('查询支付状态失败: $e');
    }
  }

  /// 检查订单状态（使用check接口）
  Future<ApiResponse<PaymentStatusResult>> checkOrderStatus(String tradeNo) async {
    try {
      final result = await _httpService.getRequest('/api/v1/user/order/check?trade_no=$tradeNo');
      return ApiResponse.fromJson(result, (json) {
        // API返回的data字段是整数状态码，需要转换为PaymentStatusResult
        if (json is int) {
          switch (json) {
            case 0:
              return PaymentStatusResult.pending('等待中');
            case 2:
              return PaymentStatusResult.canceled('订单已取消');
            case 3:
              return PaymentStatusResult.success('支付成功');
            default:
              return PaymentStatusResult.failed('未知状态: $json');
          }
        } else if (json is Map<String, dynamic>) {
          return PaymentStatusResult.fromJson(json);
        } else {
          throw ApiException('无效的订单状态数据类型: ${json.runtimeType}');
        }
      });
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('检查订单状态失败: $e');
    }
  }

  /// 取消支付
  Future<ApiResponse<void>> cancelPayment(String tradeNo) async {
    try {
      final result = await _httpService.postRequest('/api/v1/user/order/cancel', {'trade_no': tradeNo});
      return ApiResponse.fromJson(result, (json) => null);
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('取消支付失败: $e');
    }
  }

  /// 获取支付历史
  Future<ApiResponse<List<Map<String, dynamic>>>> getPaymentHistory({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final result = await _httpService.getRequest('/api/v1/user/payment/history?limit=$limit&offset=$offset');
      return ApiResponse.fromJson(result, (json) => (json as List<dynamic>).cast<Map<String, dynamic>>());
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('获取支付历史失败: $e');
    }
  }

  /// 获取支付统计信息
  Future<ApiResponse<Map<String, dynamic>>> getPaymentStats() async {
    try {
      final result = await _httpService.getRequest('/api/v1/user/payment/stats');
      return ApiResponse.fromJson(result, (json) => json as Map<String, dynamic>);
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('获取支付统计信息失败: $e');
    }
  }
}
