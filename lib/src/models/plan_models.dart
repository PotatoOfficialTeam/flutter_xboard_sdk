import 'package:html/parser.dart' as html_parser;

/// 套餐/计划模型
class Plan {
  final int id;
  final int groupId;
  final double transferEnable; // 单位：字节
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

  Plan({
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

  /// 从JSON创建Plan对象
  factory Plan.fromJson(Map<String, dynamic> json) {
    // 清理HTML标签
    final rawContent = json['content'] ?? '';
    final document = html_parser.parse(rawContent);
    final cleanContent = document.body?.text ?? '';

    double? parsePrice(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble() / 100;
      if (value is String) {
        final v = double.tryParse(value);
        return v != null ? v / 100 : null;
      }
      return null;
    }

    return Plan(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id'].toString()) ?? 0,
      groupId: json['group_id'] is int ? json['group_id'] as int : int.tryParse(json['group_id'].toString()) ?? 0,
      transferEnable: json['transfer_enable'] is num
          ? (json['transfer_enable'] as num).toDouble()
          : double.tryParse(json['transfer_enable'].toString()) ?? 0.0,
      name: json['name']?.toString() ?? '未知',
      speedLimit: json['speed_limit'] is int ? json['speed_limit'] as int : int.tryParse(json['speed_limit'].toString()) ?? 0,
      show: json['show'] == 1 || json['show'] == true,
      content: cleanContent.isNotEmpty ? cleanContent : null,
      onetimePrice: parsePrice(json['onetime_price']),
      monthPrice: parsePrice(json['month_price']),
      quarterPrice: parsePrice(json['quarter_price']),
      halfYearPrice: parsePrice(json['half_year_price']),
      yearPrice: parsePrice(json['year_price']),
      twoYearPrice: parsePrice(json['two_year_price']),
      threeYearPrice: parsePrice(json['three_year_price']),
      createdAt: json['created_at'] is int ? json['created_at'] as int : int.tryParse(json['created_at']?.toString() ?? ''),
      updatedAt: json['updated_at'] is int ? json['updated_at'] as int : int.tryParse(json['updated_at']?.toString() ?? ''),
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
  bool get hasPrice => [onetimePrice, monthPrice, quarterPrice, halfYearPrice, yearPrice, twoYearPrice, threeYearPrice].any((p) => p != null && p > 0);
}

/// 套餐列表响应
class PlanResponse {
  final List<Plan> plans;
  final int total;

  PlanResponse({required this.plans, required this.total});

  factory PlanResponse.fromJson(Map<String, dynamic> json) {
    final plans = (json['data'] as List?)?.map((e) => Plan.fromJson(e)).toList() ?? [];
    final total = json['total'] is int ? json['total'] as int : plans.length;
    return PlanResponse(plans: plans, total: total);
  }

  Map<String, dynamic> toJson() {
    return {
      'data': plans.map((e) => e.toJson()).toList(),
      'total': total,
    };
  }

  /// 获取可用套餐
  List<Plan> get availablePlans => plans.where((p) => p.isVisible && p.hasPrice).toList();
} 