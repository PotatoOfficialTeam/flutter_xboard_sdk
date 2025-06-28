/// 订阅信息模型
class SubscriptionInfo {
  final String? subscribeUrl;
  final String? planName;
  final PlanDetails? plan;
  final String? token;
  final DateTime? expiredAt;

  SubscriptionInfo({
    this.subscribeUrl,
    this.planName,
    this.plan,
    this.token,
    this.expiredAt,
  });

  factory SubscriptionInfo.fromJson(Map<String, dynamic> json) {
    return SubscriptionInfo(
      subscribeUrl: json['subscribe_url'],
      planName: json['plan']?['name'],
      plan: json['plan'] != null ? PlanDetails.fromJson(json['plan']) : null,
      token: json['token'],
      expiredAt: json['expired_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['expired_at'] * 1000)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscribe_url': subscribeUrl,
      'plan_name': planName,
      'plan': plan?.toJson(),
      'token': token,
      'expired_at': expiredAt?.millisecondsSinceEpoch != null 
          ? expiredAt!.millisecondsSinceEpoch ~/ 1000 
          : null,
    };
  }
}

/// 计划详情模型
class PlanDetails {
  final String? name;
  final int? id;
  final double? price;
  final String? description;
  final int? transferEnable;
  final int? speedLimit;

  PlanDetails({
    this.name,
    this.id,
    this.price,
    this.description,
    this.transferEnable,
    this.speedLimit,
  });

  factory PlanDetails.fromJson(Map<String, dynamic> json) {
    return PlanDetails(
      name: json['name'],
      id: json['id'],
      price: json['price']?.toDouble(),
      description: json['description'],
      transferEnable: json['transfer_enable'],
      speedLimit: json['speed_limit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
      'price': price,
      'description': description,
      'transfer_enable': transferEnable,
      'speed_limit': speedLimit,
    };
  }
}

/// 订阅统计信息模型
class SubscriptionStats {
  final int? todayUsed;
  final int? monthUsed;
  final int? totalUsed;
  final int? totalRemaining;
  final DateTime? expiredAt;

  SubscriptionStats({
    this.todayUsed,
    this.monthUsed,
    this.totalUsed,
    this.totalRemaining,
    this.expiredAt,
  });

  factory SubscriptionStats.fromJson(Map<String, dynamic> json) {
    return SubscriptionStats(
      todayUsed: json['today_used'],
      monthUsed: json['month_used'], 
      totalUsed: json['total_used'],
      totalRemaining: json['total_remaining'],
      expiredAt: json['expired_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['expired_at'] * 1000)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'today_used': todayUsed,
      'month_used': monthUsed,
      'total_used': totalUsed,
      'total_remaining': totalRemaining,
      'expired_at': expiredAt?.millisecondsSinceEpoch != null
          ? expiredAt!.millisecondsSinceEpoch ~/ 1000
          : null,
    };
  }

  /// 格式化流量数据
  String formatBytes(int? bytes) {
    if (bytes == null) return 'N/A';
    
    const units = ['B', 'KB', 'MB', 'GB', 'TB'];
    double size = bytes.toDouble();
    int unitIndex = 0;
    
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    
    return '${size.toStringAsFixed(2)} ${units[unitIndex]}';
  }
}

/// 订阅响应模型
class SubscriptionResponse {
  final bool success;
  final String? message;
  final SubscriptionInfo? data;

  SubscriptionResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory SubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? SubscriptionInfo.fromJson(json['data']) : null,
    );
  }
} 