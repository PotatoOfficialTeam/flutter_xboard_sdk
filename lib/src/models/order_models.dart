/// 订单模型
/// 
/// 表示用户的订单信息
class Order {
  final int? planId;
  final String? tradeNo;
  final double? totalAmount;
  final String? period;
  final int? status;
  final int? createdAt;
  final OrderPlan? orderPlan;

  const Order({
    this.planId,
    this.tradeNo,
    this.totalAmount,
    this.period,
    this.status,
    this.createdAt,
    this.orderPlan,
  });

  /// 从JSON创建Order实例
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      planId: json['plan_id'] as int?,
      tradeNo: json['trade_no'] as String?,
      totalAmount: (json['total_amount'] as num?)?.toDouble(),
      period: json['period'] as String?,
      status: json['status'] as int?,
      createdAt: json['created_at'] as int?,
      orderPlan: json['plan'] != null
          ? OrderPlan.fromJson(json['plan'] as Map<String, dynamic>)
          : null,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'plan_id': planId,
      'trade_no': tradeNo,
      'total_amount': totalAmount,
      'period': period,
      'status': status,
      'created_at': createdAt,
      'plan': orderPlan?.toJson(),
    };
  }

  /// 获取订单状态描述
  String get statusDescription {
    switch (status) {
      case 0:
        return '待支付';
      case 1:
        return '已开通';
      case 2:
        return '已取消';
      case 3:
        return '已完成';
      case 4:
        return '已折抵';
      default:
        return '未知状态';
    }
  }

  /// 是否为待支付状态
  bool get isPending => status == 0;

  /// 是否为已支付状态
  bool get isPaid => status == 1 || status == 3;

  /// 是否为已取消状态
  bool get isCancelled => status == 2;

  /// 获取创建时间
  DateTime? get createdDateTime {
    if (createdAt == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(createdAt! * 1000);
  }
}

/// 订单套餐信息
class OrderPlan {
  final int id;
  final String name;
  final double? onetimePrice;
  final String? content;

  const OrderPlan({
    required this.id,
    required this.name,
    this.onetimePrice,
    this.content,
  });

  /// 从JSON创建OrderPlan实例
  factory OrderPlan.fromJson(Map<String, dynamic> json) {
    return OrderPlan(
      id: json['id'] as int,
      name: json['name'] as String,
      onetimePrice: (json['onetime_price'] as num?)?.toDouble(),
      content: json['content'] as String?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'onetime_price': onetimePrice,
      'content': content,
    };
  }
}

/// 套餐计划模型（简化版）
class Plan {
  final int id;
  final int groupId;
  final double transferEnable;
  final String name;
  final int speedLimit;
  final bool show;
  final String? content;
  final double? onetimePrice;
  final double? monthPrice;
  final double? quarterPrice;
  final double? halfYearPrice;
  final double? yearPrice;
  final double? twoYearPrice;
  final double? threeYearPrice;
  final int? createdAt;
  final int? updatedAt;

  const Plan({
    required this.id,
    required this.groupId,
    required this.transferEnable,
    required this.name,
    required this.speedLimit,
    required this.show,
    this.content,
    this.onetimePrice,
    this.monthPrice,
    this.quarterPrice,
    this.halfYearPrice,
    this.yearPrice,
    this.twoYearPrice,
    this.threeYearPrice,
    this.createdAt,
    this.updatedAt,
  });

  /// 从JSON创建Plan实例
  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'] is int ? json['id'] as int : 0,
      groupId: json['group_id'] is int ? json['group_id'] as int : 0,
      transferEnable: json['transfer_enable'] is num
          ? (json['transfer_enable'] as num).toDouble()
          : 0.0,
      name: json['name'] is String ? json['name'] as String : '未知',
      speedLimit: json['speed_limit'] is int ? json['speed_limit'] as int : 0,
      show: json['show'] == 1,
      content: json['content'] as String?,
      
      // 价格处理（从分转换为元）
      onetimePrice: json['onetime_price'] != null
          ? (json['onetime_price'] as num).toDouble() / 100
          : null,
      monthPrice: json['month_price'] != null
          ? (json['month_price'] as num).toDouble() / 100
          : null,
      quarterPrice: json['quarter_price'] != null
          ? (json['quarter_price'] as num).toDouble() / 100
          : null,
      halfYearPrice: json['half_year_price'] != null
          ? (json['half_year_price'] as num).toDouble() / 100
          : null,
      yearPrice: json['year_price'] != null
          ? (json['year_price'] as num).toDouble() / 100
          : null,
      twoYearPrice: json['two_year_price'] != null
          ? (json['two_year_price'] as num).toDouble() / 100
          : null,
      threeYearPrice: json['three_year_price'] != null
          ? (json['three_year_price'] as num).toDouble() / 100
          : null,
          
      createdAt: json['created_at'] as int?,
      updatedAt: json['updated_at'] as int?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'group_id': groupId,
      'transfer_enable': transferEnable,
      'name': name,
      'speed_limit': speedLimit,
      'show': show ? 1 : 0,
      'content': content,
      'onetime_price': onetimePrice != null ? (onetimePrice! * 100).round() : null,
      'month_price': monthPrice != null ? (monthPrice! * 100).round() : null,
      'quarter_price': quarterPrice != null ? (quarterPrice! * 100).round() : null,
      'half_year_price': halfYearPrice != null ? (halfYearPrice! * 100).round() : null,
      'year_price': yearPrice != null ? (yearPrice! * 100).round() : null,
      'two_year_price': twoYearPrice != null ? (twoYearPrice! * 100).round() : null,
      'three_year_price': threeYearPrice != null ? (threeYearPrice! * 100).round() : null,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

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

  /// 获取流量大小（GB）
  double get transferEnableGB => transferEnable / (1024 * 1024 * 1024);
}

/// 支付方式模型
class PaymentMethod {
  final String id;
  final String name;
  final String? icon;
  final bool isAvailable;
  final Map<String, dynamic>? config;

  const PaymentMethod({
    required this.id,
    required this.name,
    this.icon,
    required this.isAvailable,
    this.config,
  });

  /// 从JSON创建PaymentMethod实例
  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id']?.toString() ?? json['method']?.toString() ?? '',
      name: json['name'] as String? ?? '未知支付方式',
      icon: json['icon'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      config: json['config'] as Map<String, dynamic>?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'is_available': isAvailable,
      'config': config,
    };
  }
}

/// 订单创建请求模型
class CreateOrderRequest {
  final int planId;
  final String period;
  final String? couponCode;

  const CreateOrderRequest({
    required this.planId,
    required this.period,
    this.couponCode,
  });

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'plan_id': planId.toString(),
      'period': period,
      if (couponCode != null) 'coupon_code': couponCode,
    };
  }
}

/// 订单提交请求模型
class SubmitOrderRequest {
  final String tradeNo;
  final String method;

  const SubmitOrderRequest({
    required this.tradeNo,
    required this.method,
  });

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'trade_no': tradeNo,
      'method': method,
    };
  }
}

/// 支付响应模型
class PaymentResponse {
  final List<PaymentMethod> paymentMethods;
  final String tradeNo;

  const PaymentResponse({
    required this.paymentMethods,
    required this.tradeNo,
  });

  /// 从JSON创建PaymentResponse实例
  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    final methodsJson = json['payment_methods'] as List<dynamic>? ?? [];
    final methods = methodsJson
        .map((method) => PaymentMethod.fromJson(method as Map<String, dynamic>))
        .toList();

    return PaymentResponse(
      paymentMethods: methods,
      tradeNo: json['trade_no'] as String,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'payment_methods': paymentMethods.map((method) => method.toJson()).toList(),
      'trade_no': tradeNo,
    };
  }
}

/// 订单响应模型
class OrderResponse {
  final List<Order> orders;
  final int? total;

  const OrderResponse({
    required this.orders,
    this.total,
  });

  /// 从JSON创建OrderResponse实例
  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    final ordersJson = json['data'] as List<dynamic>? ?? [];
    final orders = ordersJson
        .map((order) => Order.fromJson(order as Map<String, dynamic>))
        .toList();

    return OrderResponse(
      orders: orders,
      total: json['total'] as int?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'data': orders.map((order) => order.toJson()).toList(),
      'total': total,
    };
  }

  /// 获取待支付订单
  List<Order> get pendingOrders {
    return orders.where((order) => order.isPending).toList();
  }

  /// 获取已支付订单
  List<Order> get paidOrders {
    return orders.where((order) => order.isPaid).toList();
  }
}

/// 计划响应模型
class PlanResponse {
  final List<Plan> plans;
  final int? total;

  const PlanResponse({
    required this.plans,
    this.total,
  });

  /// 从JSON创建PlanResponse实例
  factory PlanResponse.fromJson(Map<String, dynamic> json) {
    final plansJson = json['data'] as List<dynamic>? ?? [];
    final plans = plansJson
        .map((plan) => Plan.fromJson(plan as Map<String, dynamic>))
        .toList();

    return PlanResponse(
      plans: plans,
      total: json['total'] as int?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'data': plans.map((plan) => plan.toJson()).toList(),
      'total': total,
    };
  }

  /// 获取可用的计划
  List<Plan> get availablePlans {
    return plans.where((plan) => plan.show).toList();
  }
} 