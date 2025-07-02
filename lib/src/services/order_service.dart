import 'http_service.dart';
import '../models/order_models.dart';

/// 订单服务类
/// 
/// 提供订单相关的API接口
class OrderService {
  final HttpService _httpService;

  OrderService(this._httpService);

  /// 获取用户订单列表
  /// 
  /// 返回包含用户所有订单的原始响应数据
  Future<Map<String, dynamic>> fetchUserOrdersRaw() async {
    return await _httpService.getRequest("/api/v1/user/order/fetch");
  }

  /// 获取用户订单列表（结构化返回）
  /// 
  /// 返回 [OrderResponse] 对象，包含订单列表
  /// 
  /// 示例：
  /// ```dart
  /// final response = await sdk.order.fetchUserOrders();
  /// print('共有${response.orders.length}个订单');
  /// for (final order in response.orders) {
  ///   print('订单号: ${order.tradeNo}, 状态: ${order.statusDescription}');
  /// }
  /// ```
  Future<OrderResponse> fetchUserOrders() async {
    final result = await fetchUserOrdersRaw();
    
    if (result.containsKey("data")) {
      return OrderResponse.fromJson(result);
    }
    
    throw Exception("Failed to retrieve orders: Invalid response format");
  }

  /// 获取订单详情
  /// 
  /// [tradeNo] 订单号
  /// 返回订单详情的原始数据
  /// 
  /// 示例：
  /// ```dart
  /// final details = await sdk.order.getOrderDetails('ORDER123456');
  /// ```
  Future<Map<String, dynamic>> getOrderDetails(String tradeNo) async {
    return await _httpService.getRequest(
      "/api/v1/user/order/detail?trade_no=$tradeNo",
    );
  }

  /// 取消订单
  /// 
  /// [tradeNo] 订单号
  /// 返回取消结果
  /// 
  /// 示例：
  /// ```dart
  /// final result = await sdk.order.cancelOrder('ORDER123456');
  /// print('取消结果: ${result['message']}');
  /// ```
  Future<Map<String, dynamic>> cancelOrder(String tradeNo) async {
    return await _httpService.postRequest(
      "/api/v1/user/order/cancel",
      {"trade_no": tradeNo},
    );
  }

  /// 创建订单
  /// 
  /// [planId] 套餐计划ID
  /// [period] 订阅周期
  /// [couponCode] 优惠券代码（可选）
  /// 返回创建的订单信息
  /// 
  /// 示例：
  /// ```dart
  /// final result = await sdk.order.createOrder(
  ///   planId: 1,
  ///   period: 'month',
  ///   couponCode: 'DISCOUNT20',
  /// );
  /// final tradeNo = result['data'];
  /// ```
  Future<Map<String, dynamic>> createOrder({
    required int planId,
    required String period,
    String? couponCode,
  }) async {
    final request = CreateOrderRequest(
      planId: planId,
      period: period,
      couponCode: couponCode,
    );

    return await _httpService.postRequest(
      "/api/v1/user/order/save",
      request.toJson(),
    );
  }

  /// 获取套餐计划列表
  /// 
  /// 返回所有可用套餐计划的原始数据
  Future<Map<String, dynamic>> fetchPlansRaw() async {
    return await _httpService.getRequest("/api/v1/user/plan/fetch");
  }

  /// 获取套餐计划列表（结构化返回）
  /// 
  /// 返回 [PlanResponse] 对象，包含计划列表
  /// 
  /// 示例：
  /// ```dart
  /// final response = await sdk.order.fetchPlans();
  /// for (final plan in response.availablePlans) {
  ///   print('套餐: ${plan.name}, 价格: ${plan.monthPrice}元/月');
  /// }
  /// ```
  Future<PlanResponse> fetchPlans() async {
    final result = await fetchPlansRaw();
    
    if (result.containsKey("data")) {
      return PlanResponse.fromJson(result);
    }
    
    throw Exception("Failed to retrieve plans: Invalid response format");
  }

  /// 获取套餐计划详情
  /// 
  /// [planId] 套餐计划ID
  /// 返回指定套餐的详细信息
  /// 
  /// 示例：
  /// ```dart
  /// final plan = await sdk.order.getPlanDetails(1);
  /// if (plan != null) {
  ///   print('套餐详情: ${plan.name}');
  /// }
  /// ```
  Future<Plan?> getPlanDetails(int planId) async {
    final result = await _httpService.getRequest(
      "/api/v1/user/plan/fetch?id=$planId",
    );

    if (result['data'] != null) {
      return Plan.fromJson(result['data'] as Map<String, dynamic>);
    }
    
    return null;
  }

  /// 获取支付方式列表
  /// 
  /// 返回可用的支付方式原始数据
  Future<Map<String, dynamic>> getPaymentMethodsRaw() async {
    return await _httpService.getRequest("/api/v1/user/order/getPaymentMethod");
  }

  /// 获取支付方式列表（结构化返回）
  /// 
  /// 返回 [PaymentMethod] 列表
  /// 
  /// 示例：
  /// ```dart
  /// final methods = await sdk.order.getPaymentMethods();
  /// for (final method in methods) {
  ///   print('支付方式: ${method.name}');
  /// }
  /// ```
  Future<List<PaymentMethod>> getPaymentMethods() async {
    final result = await getPaymentMethodsRaw();
    
    if (result['data'] is List) {
      final methodsJson = result['data'] as List<dynamic>;
      return methodsJson
          .map((method) => PaymentMethod.fromJson(method as Map<String, dynamic>))
          .toList();
    }
    
    return [];
  }

  /// 提交订单支付
  /// 
  /// [tradeNo] 订单号
  /// [method] 支付方式
  /// 返回支付提交结果
  /// 
  /// 示例：
  /// ```dart
  /// final result = await sdk.order.submitPayment(
  ///   tradeNo: 'ORDER123456',
  ///   method: 'alipay',
  /// );
  /// ```
  Future<Map<String, dynamic>> submitPayment({
    required String tradeNo,
    required String method,
  }) async {
    final request = SubmitOrderRequest(
      tradeNo: tradeNo,
      method: method,
    );

    return await _httpService.postRequest(
      "/api/v1/user/payment/submit",
      request.toJson(),
    );
  }

  /// 获取待支付订单
  /// 
  /// 返回所有状态为待支付的订单列表
  /// 
  /// 示例：
  /// ```dart
  /// final pendingOrders = await sdk.order.getPendingOrders();
  /// print('有${pendingOrders.length}个待支付订单');
  /// ```
  Future<List<Order>> getPendingOrders() async {
    try {
      final response = await fetchUserOrders();
      return response.pendingOrders;
    } catch (e) {
      return [];
    }
  }

  /// 获取已支付订单
  /// 
  /// 返回所有状态为已支付的订单列表
  /// 
  /// 示例：
  /// ```dart
  /// final paidOrders = await sdk.order.getPaidOrders();
  /// print('有${paidOrders.length}个已支付订单');
  /// ```
  Future<List<Order>> getPaidOrders() async {
    try {
      final response = await fetchUserOrders();
      return response.paidOrders;
    } catch (e) {
      return [];
    }
  }

  /// 批量取消待支付订单
  /// 
  /// 取消所有待支付状态的订单
  /// 返回成功取消的订单数量
  /// 
  /// 示例：
  /// ```dart
  /// final canceledCount = await sdk.order.cancelPendingOrders();
  /// print('已取消${canceledCount}个待支付订单');
  /// ```
  Future<int> cancelPendingOrders() async {
    try {
      final pendingOrders = await getPendingOrders();
      int canceledCount = 0;
      
      for (final order in pendingOrders) {
        if (order.tradeNo != null) {
          try {
            await cancelOrder(order.tradeNo!);
            canceledCount++;
          } catch (e) {
            // 单个订单取消失败，继续处理其他订单
          }
        }
      }
      
      return canceledCount;
    } catch (e) {
      return 0;
    }
  }

  /// 处理完整的订阅流程
  /// 
  /// [planId] 套餐计划ID
  /// [period] 订阅周期
  /// [couponCode] 优惠券代码（可选）
  /// 
  /// 自动处理：
  /// 1. 取消现有的待支付订单
  /// 2. 创建新订单
  /// 3. 获取支付方式
  /// 4. 返回支付响应
  /// 
  /// 示例：
  /// ```dart
  /// final paymentResponse = await sdk.order.handleSubscription(
  ///   planId: 1,
  ///   period: 'month',
  ///   couponCode: 'DISCOUNT20',
  /// );
  /// 
  /// // 显示支付方式选择
  /// for (final method in paymentResponse.paymentMethods) {
  ///   print('支付方式: ${method.name}');
  /// }
  /// 
  /// // 提交支付
  /// await sdk.order.submitPayment(
  ///   tradeNo: paymentResponse.tradeNo,
  ///   method: 'alipay',
  /// );
  /// ```
  Future<PaymentResponse> handleSubscription({
    required int planId,
    required String period,
    String? couponCode,
  }) async {
    // 1. 取消现有的待支付订单
    await cancelPendingOrders();

    // 2. 创建新订单
    final orderResult = await createOrder(
      planId: planId,
      period: period,
      couponCode: couponCode,
    );

    final tradeNo = orderResult['data']?.toString();
    if (tradeNo == null || tradeNo.isEmpty) {
      throw Exception('创建订单失败，未获取到订单号');
    }

    // 3. 获取支付方式
    final paymentMethods = await getPaymentMethods();
    if (paymentMethods.isEmpty) {
      throw Exception('未获取到支付方式');
    }

    // 4. 返回支付响应
    return PaymentResponse(
      paymentMethods: paymentMethods,
      tradeNo: tradeNo,
    );
  }

  /// 根据订单号查找订单
  /// 
  /// [tradeNo] 订单号
  /// 返回找到的订单，如果未找到则返回null
  /// 
  /// 示例：
  /// ```dart
  /// final order = await sdk.order.findOrderByTradeNo('ORDER123456');
  /// if (order != null) {
  ///   print('订单状态: ${order.statusDescription}');
  /// }
  /// ```
  Future<Order?> findOrderByTradeNo(String tradeNo) async {
    try {
      final response = await fetchUserOrders();
      
      for (final order in response.orders) {
        if (order.tradeNo == tradeNo) {
          return order;
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 获取可用的套餐计划
  /// 
  /// 返回所有可显示的套餐计划列表
  /// 
  /// 示例：
  /// ```dart
  /// final availablePlans = await sdk.order.getAvailablePlans();
  /// for (final plan in availablePlans) {
  ///   print('${plan.name}: ${plan.transferEnableGB.toStringAsFixed(1)} GB');
  /// }
  /// ```
  Future<List<Plan>> getAvailablePlans() async {
    try {
      final response = await fetchPlans();
      return response.availablePlans;
    } catch (e) {
      return [];
    }
  }
} 