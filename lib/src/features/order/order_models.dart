import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_xboard_sdk/src/common/models/api_response.dart';
import 'package:flutter_xboard_sdk/src/features/plan/plan_models.dart';

part 'order_models.freezed.dart';
part 'order_models.g.dart';

// Helper functions for DateTime to Unix timestamp conversion
int? _toUnixTimestamp(DateTime? date) => date?.millisecondsSinceEpoch == null ? null : date!.millisecondsSinceEpoch ~/ 1000;
DateTime? _fromUnixTimestamp(int? timestamp) =>
    timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp * 1000) : null;

// Helper for int to bool conversion (for 'show' field)
bool _intToBool(dynamic value) {
  if (value is int) {
    return value == 1;
  } else if (value is bool) {
    return value;
  }
  return false; // Default or handle error
}

int _boolToInt(bool value) => value ? 1 : 0;

// Helper for price conversion (from cents to yuan)
double? _priceFromJson(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is num) {
    return value.toDouble() / 100;
  }
  return null;
}

int? _priceToJson(double? value) {
  if (value is double) {
    return (value * 100).round();
  }
  return null;
}

@freezed
class Order with _$Order {
  const factory Order({
    @JsonKey(name: 'plan_id') int? planId,
    @JsonKey(name: 'trade_no') String? tradeNo,
    @JsonKey(name: 'total_amount') double? totalAmount,
    String? period,
    int? status,
    @JsonKey(name: 'created_at', fromJson: _fromUnixTimestamp, toJson: _toUnixTimestamp)
    DateTime? createdAt,
    @JsonKey(name: 'plan') Plan? orderPlan,
  }) = _Order;

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}

@freezed
class OrderPlan with _$OrderPlan {
  const factory OrderPlan({
    required int id,
    required String name,
    @JsonKey(name: 'onetime_price') double? onetimePrice,
    String? content,
  }) = _OrderPlan;

  factory OrderPlan.fromJson(Map<String, dynamic> json) => _$OrderPlanFromJson(json);
}

@freezed
class CreateOrderRequest with _$CreateOrderRequest {
  const factory CreateOrderRequest({
    @JsonKey(name: 'plan_id') required int planId,
    required String period,
    @JsonKey(name: 'coupon_code') String? couponCode,
  }) = _CreateOrderRequest;

  factory CreateOrderRequest.fromJson(Map<String, dynamic> json) => _$CreateOrderRequestFromJson(json);
}

@freezed
class SubmitOrderRequest with _$SubmitOrderRequest {
  const factory SubmitOrderRequest({
    @JsonKey(name: 'trade_no') required String tradeNo,
    required String method,
  }) = _SubmitOrderRequest;

  factory SubmitOrderRequest.fromJson(Map<String, dynamic> json) => _$SubmitOrderRequestFromJson(json);
}

@freezed
class PaymentMethod with _$PaymentMethod {
  const factory PaymentMethod({
    @JsonKey(fromJson: _idFromJson, toJson: _idToJson)
    required String id, // Custom fromJson/toJson for id
    required String name,
    String? icon,
    @JsonKey(name: 'is_available', defaultValue: false) required bool isAvailable,
    Map<String, dynamic>? config,
  }) = _PaymentMethod;

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => _$PaymentMethodFromJson(json);
}

// Helper for PaymentMethod id conversion
String _idFromJson(dynamic value) {
  if (value is int) {
    return value.toString();
  } else if (value is String) {
    return value;
  }
  return ''; // Default or handle error
}

dynamic _idToJson(String value) => value; // No special conversion needed for toJson

@freezed
class OrderPaymentInfoResponse with _$OrderPaymentInfoResponse {
  const factory OrderPaymentInfoResponse({
    @JsonKey(name: 'payment_methods') required List<PaymentMethod> paymentMethods,
    @JsonKey(name: 'trade_no') required String tradeNo,
  }) = _OrderPaymentInfoResponse;

  factory OrderPaymentInfoResponse.fromJson(Map<String, dynamic> json) => _$OrderPaymentInfoResponseFromJson(json);
}

@freezed
class OrderResponse with _$OrderResponse {
  const factory OrderResponse({
    required List<Order> data, // Renamed from orders to data to match ApiResponse
    int? total,
  }) = _OrderResponse;

  factory OrderResponse.fromJson(Map<String, dynamic> json) => _$OrderResponseFromJson(json);
}




