import 'package:freezed_annotation/freezed_annotation.dart';

part 'plan_models.freezed.dart';
part 'plan_models.g.dart';

// Helper functions for price conversion (from cents to yuan)
double? _priceFromJson(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble() / 100;
  if (value is String) {
    final v = double.tryParse(value);
    return v != null ? v / 100 : null;
  }
  return null;
}

int? _priceToJson(double? value) {
  if (value is double) {
    return (value * 100).round();
  }
  return null;
}

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

@freezed
class Plan with _$Plan {
  const factory Plan({
    required int id,
    @JsonKey(name: 'group_id') required int groupId,
    @JsonKey(name: 'transfer_enable') required double transferEnable,
    required String name,
    List<String>? tags,
    int? speedLimit,
    required bool show,
    String? content,
    @JsonKey(name: 'onetime_price', fromJson: _priceFromJson, toJson: _priceToJson)
    double? onetimePrice,
    @JsonKey(name: 'month_price', fromJson: _priceFromJson, toJson: _priceToJson)
    double? monthPrice,
    @JsonKey(name: 'quarter_price', fromJson: _priceFromJson, toJson: _priceToJson)
    double? quarterPrice,
    @JsonKey(name: 'half_year_price', fromJson: _priceFromJson, toJson: _priceToJson)
    double? halfYearPrice,
    @JsonKey(name: 'year_price', fromJson: _priceFromJson, toJson: _priceToJson)
    double? yearPrice,
    @JsonKey(name: 'two_year_price', fromJson: _priceFromJson, toJson: _priceToJson)
    double? twoYearPrice,
    @JsonKey(name: 'three_year_price', fromJson: _priceFromJson, toJson: _priceToJson)
    double? threeYearPrice,
    int? createdAt,
    int? updatedAt,
  }) = _Plan;

  const Plan._();

  factory Plan.fromJson(Map<String, dynamic> json) => _$PlanFromJson(json);

  /// 获取流量（GB）
  double get transferEnableGB => transferEnable / 1024 / 1024 / 1024;

  /// 获取指定周期的价格
  double? getPriceForPeriod(String period) {
    switch (period) {
      case 'onetime':
        return onetimePrice;
      case 'month':
        return monthPrice;
      case 'quarter':
        return quarterPrice;
      case 'half_year':
        return halfYearPrice;
      case 'year':
        return yearPrice;
      case 'two_year':
        return twoYearPrice;
      case 'three_year':
        return threeYearPrice;
      default:
        return null;
    }
  }

  /// 是否可见
  bool get isVisible => show;

  /// 是否有价格
  bool get hasPrice => [onetimePrice, monthPrice, quarterPrice, halfYearPrice, yearPrice, twoYearPrice, threeYearPrice].any((p) => p != null && p! > 0);
}

@freezed
class PlanResponse with _$PlanResponse {
  const factory PlanResponse({
    required List<Plan> data,
    int? total,
  }) = _PlanResponse;

  const PlanResponse._();

  factory PlanResponse.fromJson(Map<String, dynamic> json) => _$PlanResponseFromJson(json);

  /// 获取可用套餐
  List<Plan> get availablePlans => data.where((p) => p.isVisible && p.hasPrice).toList();
}