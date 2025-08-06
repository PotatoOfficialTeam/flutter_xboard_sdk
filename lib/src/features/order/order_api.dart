import 'package:flutter_xboard_sdk/src/services/http_service.dart';
import 'package:flutter_xboard_sdk/src/features/order/order_models.dart';
import 'package:flutter_xboard_sdk/src/exceptions/xboard_exceptions.dart';
import 'package:flutter_xboard_sdk/src/common/models/api_response.dart';

class OrderApi {
  final HttpService _httpService;

  OrderApi(this._httpService);

  /// 获取用户订单列表
  /// 返回 [OrderResponse] 对象，包含订单列表
  Future<OrderResponse> fetchUserOrders() async {
    try {
      final result = await _httpService.getRequest("/api/v1/user/order/fetch");
      return OrderResponse.fromJson(result);
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('获取订单列表失败: $e');
    }
  }

  /// 获取订单详情
  /// [tradeNo] 订单号
  /// 返回订单详情
  Future<Order> getOrderDetails(String tradeNo) async {
    try {
      final result = await _httpService.getRequest(
        "/api/v1/user/order/detail?trade_no=$tradeNo",
      );
      if (result['data'] != null) {
        return Order.fromJson(result['data'] as Map<String, dynamic>);
      }
      throw ApiException('获取订单详情失败: ${result['message'] ?? 'Unknown error'}');
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('获取订单详情失败: $e');
    }
  }

  /// 取消订单
  /// [tradeNo] 订单号
  /// 返回取消结果
  Future<ApiResponse<dynamic>> cancelOrder(String tradeNo) async {
    try {
      final result = await _httpService.postRequest(
        "/api/v1/user/order/cancel",
        {"trade_no": tradeNo},
      );
      return ApiResponse.fromJson(result, (json) => json);
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('取消订单失败: $e');
    }
  }

  /// 创建订单
  /// [planId] 套餐计划ID
  /// [period] 订阅周期
  /// [couponCode] 优惠券代码（可选）
  /// 返回创建的订单信息
  Future<ApiResponse<String>> createOrder({
    required int planId,
    required String period,
    String? couponCode,
  }) async {
    try {
      final request = CreateOrderRequest(
        planId: planId,
        period: period,
        couponCode: couponCode,
      );

      final result = await _httpService.postRequest(
        "/api/v1/user/order/save",
        request.toJson(),
      );
      return ApiResponse.fromJson(result, (data) => data.toString());
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('创建订单失败: $e');
    }
  }

  

  /// 获取支付方式列表
  /// 返回 [PaymentMethod] 列表
  Future<ApiResponse<List<PaymentMethod>>> getPaymentMethods() async {
    try {
      final result = await _httpService.getRequest("/api/v1/user/order/getPaymentMethod");
      return ApiResponse.fromJson(result, (json) => (json as List<dynamic>).map((e) => PaymentMethod.fromJson(e as Map<String, dynamic>)).toList());
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('获取支付方式失败: $e');
    }
  }

  /// 提交订单支付
  /// [tradeNo] 订单号
  /// [method] 支付方式
  /// 返回支付提交结果
  Future<ApiResponse<dynamic>> submitPayment({
    required String tradeNo,
    required String method,
  }) async {
    try {
      final request = SubmitOrderRequest(
        tradeNo: tradeNo,
        method: method,
      );

      final result = await _httpService.postRequest(
        "/api/v1/user/order/checkout",
        request.toJson(),
      );
      return ApiResponse.fromJson(result, (json) => json);
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('提交支付失败: $e');
    }
  }
}