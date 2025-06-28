/// 优惠券数据模型
class CouponData {
  final String? id;
  final String? name;
  final String? code;
  final int? type; // 1: 金额折扣, 2: 百分比折扣
  final double? value; // 折扣值
  final int? limitUse; // 使用限制次数
  final int? limitUseWithUser; // 单用户使用限制
  final int? limitPlanIds; // 限制的套餐ID
  final DateTime? startedAt; // 开始时间
  final DateTime? endedAt; // 结束时间
  final bool? show; // 是否显示
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CouponData({
    this.id,
    this.name,
    this.code,
    this.type,
    this.value,
    this.limitUse,
    this.limitUseWithUser,
    this.limitPlanIds,
    this.startedAt,
    this.endedAt,
    this.show,
    this.createdAt,
    this.updatedAt,
  });

  factory CouponData.fromJson(Map<String, dynamic> json) {
    return CouponData(
      id: json['id']?.toString(),
      name: json['name'],
      code: json['code'],
      type: json['type'],
      value: json['value']?.toDouble(),
      limitUse: json['limit_use'],
      limitUseWithUser: json['limit_use_with_user'],
      limitPlanIds: json['limit_plan_ids'],
      startedAt: json['started_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['started_at'] * 1000)
          : null,
      endedAt: json['ended_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['ended_at'] * 1000)
          : null,
      show: json['show'] == 1 || json['show'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['created_at'] * 1000)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updated_at'] * 1000)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'type': type,
      'value': value,
      'limit_use': limitUse,
      'limit_use_with_user': limitUseWithUser,
      'limit_plan_ids': limitPlanIds,
      'started_at': startedAt?.millisecondsSinceEpoch,
      'ended_at': endedAt?.millisecondsSinceEpoch,
      'show': show,
      'created_at': createdAt?.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }
}

/// 优惠券验证响应模型
class CouponResponse {
  final bool success;
  final String? message;
  final CouponData? data;
  final Map<String, dynamic>? errors;

  CouponResponse({
    required this.success,
    this.message,
    this.data,
    this.errors,
  });

  factory CouponResponse.fromJson(Map<String, dynamic> json) {
    // 兼容不同的API响应格式
    bool success = false;
    if (json.containsKey('success')) {
      success = json['success'] == true;
    } else if (json.containsKey('status')) {
      success = json['status'] == 'success';
    }

    return CouponResponse(
      success: success,
      message: json['message'],
      data: json['data'] != null ? CouponData.fromJson(json['data']) : null,
      errors: json['errors'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
      'errors': errors,
    };
  }
}

/// 可用优惠券列表响应模型
class AvailableCouponsResponse {
  final bool success;
  final String? message;
  final List<CouponData>? data;
  final int? total;

  AvailableCouponsResponse({
    required this.success,
    this.message,
    this.data,
    this.total,
  });

  factory AvailableCouponsResponse.fromJson(Map<String, dynamic> json) {
    bool success = false;
    if (json.containsKey('success')) {
      success = json['success'] == true;
    } else if (json.containsKey('status')) {
      success = json['status'] == 'success';
    }

    List<CouponData>? coupons;
    if (json['data'] is List) {
      coupons = (json['data'] as List)
          .map((item) => CouponData.fromJson(item))
          .toList();
    }

    return AvailableCouponsResponse(
      success: success,
      message: json['message'],
      data: coupons,
      total: json['total'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.map((item) => item.toJson()).toList(),
      'total': total,
    };
  }
} 