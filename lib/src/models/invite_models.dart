// 邀请码相关数据模型

/// 邀请码模型 - 基于hiddify真实结构
class InviteCode {
  final int userId;
  final String code;
  final int pv; // 页面访问量
  final int status; // 状态
  final int createdAt; // 创建时间戳
  final int updatedAt; // 更新时间戳

  InviteCode({
    required this.userId,
    required this.code,
    required this.pv,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InviteCode.fromJson(Map<String, dynamic> json) {
    return InviteCode(
      userId: json['user_id'] as int,
      code: json['code'] as String,
      pv: json['pv'] as int,
      status: json['status'] as int,
      createdAt: json['created_at'] as int,
      updatedAt: json['updated_at'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'code': code,
      'pv': pv,
      'status': status,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// 获取创建时间的DateTime对象
  DateTime get createdDateTime => DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);

  /// 获取更新时间的DateTime对象  
  DateTime get updatedDateTime => DateTime.fromMillisecondsSinceEpoch(updatedAt * 1000);

  /// 检查邀请码是否有效
  bool get isActive => status == 1;
}

/// 邀请码数据容器 - 基于hiddify真实结构
class InviteCodeData {
  final List<InviteCode> codes;
  final List<int> stat; // 统计数据

  InviteCodeData({
    required this.codes,
    required this.stat,
  });

  factory InviteCodeData.fromJson(Map<String, dynamic> json) {
    return InviteCodeData(
      codes: (json['codes'] as List)
          .map((code) => InviteCode.fromJson(code as Map<String, dynamic>))
          .toList(),
      stat: (json['stat'] as List).map((e) => e as int).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codes': codes.map((code) => code.toJson()).toList(),
      'stat': stat,
    };
  }

  /// 获取总邀请数
  int get totalInvites => stat.isNotEmpty ? stat[0] : 0;

  /// 获取有效邀请数
  int get validInvites => stat.length > 1 ? stat[1] : 0;

  /// 获取佣金总额
  int get totalCommission => stat.length > 2 ? stat[2] : 0;
}

/// 邀请码响应 - 基于hiddify真实结构
class InviteCodeResponse {
  final bool success;
  final String message;
  final InviteCodeData? data;
  final String? error;

  InviteCodeResponse({
    required this.success,
    required this.message,
    this.data,
    this.error,
  });

  factory InviteCodeResponse.fromJson(Map<String, dynamic> json) {
    final status = json['status'] as String?;
    final success = status == 'success';
    
    return InviteCodeResponse(
      success: success,
      message: json['message'] as String? ?? (success ? '操作成功' : '操作失败'),
      data: json['data'] != null ? InviteCodeData.fromJson(json['data'] as Map<String, dynamic>) : null,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': success ? 'success' : 'fail',
      'message': message,
      'data': data?.toJson(),
      'error': error,
    };
  }
}

/// 佣金详情模型 - 基于hiddify真实结构
class CommissionDetail {
  final int id;
  final int orderAmount; // 订单金额（分为单位）
  final String tradeNo; // 交易号
  final int getAmount; // 获得佣金金额（分为单位）
  final int createdAt; // 创建时间戳

  CommissionDetail({
    required this.id,
    required this.orderAmount,
    required this.tradeNo,
    required this.getAmount,
    required this.createdAt,
  });

  factory CommissionDetail.fromJson(Map<String, dynamic> json) {
    return CommissionDetail(
      id: json['id'] as int,
      orderAmount: json['order_amount'] as int,
      tradeNo: json['trade_no'] as String,
      getAmount: json['get_amount'] as int,
      createdAt: json['created_at'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_amount': orderAmount,
      'trade_no': tradeNo,
      'get_amount': getAmount,
      'created_at': createdAt,
    };
  }

  /// 获取订单金额（元）
  double get orderAmountInYuan => orderAmount / 100.0;

  /// 获得佣金金额（元）
  double get getAmountInYuan => getAmount / 100.0;

  /// 获取创建时间的DateTime对象
  DateTime get createdDateTime => DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);
}

/// 佣金详情分页响应 - 基于hiddify真实结构
class CommissionDetailResponse {
  final bool success;
  final String message;
  final List<CommissionDetail> data;
  final int total; // 总数
  final String? error;

  CommissionDetailResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.total,
    this.error,
  });

  factory CommissionDetailResponse.fromJson(Map<String, dynamic> json) {
    final status = json['status'] as String?;
    final success = status == 'success' || json['data'] != null;
    
    return CommissionDetailResponse(
      success: success,
      message: json['message'] as String? ?? (success ? '获取成功' : '获取失败'),
      data: json['data'] != null 
          ? (json['data'] as List)
              .map((detail) => CommissionDetail.fromJson(detail as Map<String, dynamic>))
              .toList()
          : <CommissionDetail>[],
      total: json['total'] as int? ?? 0,
      error: json['error'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': success ? 'success' : 'fail',
      'message': message,
      'data': data.map((detail) => detail.toJson()).toList(),
      'total': total,
      'error': error,
    };
  }

  /// 获取总佣金金额（元）
  double get totalCommissionInYuan {
    return data.fold(0.0, (sum, detail) => sum + detail.getAmountInYuan);
  }
}

/// 专属App生成响应
class AppGenerationResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  AppGenerationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory AppGenerationResponse.fromJson(Map<String, dynamic> json) {
    final status = json['status'] as String?;
    final success = status == 'success' || status == 'unchanged';
    
    return AppGenerationResponse(
      success: success,
      message: json['message'] as String? ?? (success ? '操作成功' : '操作失败'),
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data,
    };
  }
}
