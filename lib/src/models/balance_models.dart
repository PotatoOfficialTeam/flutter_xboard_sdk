/// 系统配置模型 - 基于真实API结构
class SystemConfig {
  final List<String> withdrawMethods;
  final bool withdrawEnabled;
  final String currency;
  final String currencySymbol;

  SystemConfig({
    required this.withdrawMethods,
    required this.withdrawEnabled,
    required this.currency,
    required this.currencySymbol,
  });

  factory SystemConfig.fromJson(Map<String, dynamic> json) {
    return SystemConfig(
      withdrawMethods: (json['withdraw_methods'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      withdrawEnabled: json['withdraw_close'] == 0, // 0表示开启，1表示关闭
      currency: json['currency']?.toString() ?? 'CNY',
      currencySymbol: json['currency_symbol']?.toString() ?? '¥',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'withdraw_methods': withdrawMethods,
      'withdraw_close': withdrawEnabled ? 0 : 1,
      'currency': currency,
      'currency_symbol': currencySymbol,
    };
  }
}

/// 用户信息模型 - 包含余额信息，基于真实API结构
class UserInfo {
  final String email;
  final double transferEnable;
  final int? lastLoginAt;
  final int createdAt;
  final bool banned;
  final bool remindExpire;
  final bool remindTraffic;
  final int? expiredAt;
  final double balance; // 消费余额（分为单位）
  final double commissionBalance; // 剩余佣金余额（分为单位）
  final int planId;
  final double? discount;
  final double? commissionRate;
  final String? telegramId;
  final String uuid;
  final String avatarUrl;

  /// 获取以元为单位的余额
  double get balanceInYuan => balance / 100;
  
  /// 获取以元为单位的佣金余额
  double get commissionBalanceInYuan => commissionBalance / 100;

  /// 获取总余额（元）
  double get totalBalanceInYuan => balanceInYuan + commissionBalanceInYuan;

  UserInfo({
    required this.email,
    required this.transferEnable,
    this.lastLoginAt,
    required this.createdAt,
    required this.banned,
    required this.remindExpire,
    required this.remindTraffic,
    this.expiredAt,
    required this.balance,
    required this.commissionBalance,
    required this.planId,
    this.discount,
    this.commissionRate,
    this.telegramId,
    required this.uuid,
    required this.avatarUrl,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    print('UserInfo.fromJson - 原始JSON: $json');
    try {
      return UserInfo(
        email: json['email'] as String? ?? '',
        transferEnable: (json['transfer_enable'] as num?)?.toDouble() ?? 0.0,
        lastLoginAt: json['last_login_at'] as int?,
        createdAt: json['created_at'] as int? ?? 0,
        banned: json['banned'] as bool? ?? false,
        remindExpire: json['remind_expire'] as bool? ?? false,
        remindTraffic: json['remind_traffic'] as bool? ?? false,
        expiredAt: json['expired_at'] as int?,
        balance: (json['balance'] as num?)?.toDouble() ?? 0.0,
      commissionBalance: (json['commission_balance'] as num?)?.toDouble() ?? 0.0,
      planId: json['plan_id'] as int? ?? 0,
      discount: (json['discount'] as num?)?.toDouble(),
      commissionRate: (json['commission_rate'] as num?)?.toDouble(),
      telegramId: json['telegram_id']?.toString(),
      uuid: json['uuid'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
    );
    } catch (e, stackTrace) {
      print('UserInfo.fromJson 解析失败: $e');
      print('堆栈跟踪: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'transfer_enable': transferEnable,
      'last_login_at': lastLoginAt,
      'created_at': createdAt,
      'banned': banned,
      'remind_expire': remindExpire,
      'remind_traffic': remindTraffic,
      'expired_at': expiredAt,
      'balance': balance,
      'commission_balance': commissionBalance,
      'plan_id': planId,
      'discount': discount,
      'commission_rate': commissionRate,
      'telegram_id': telegramId,
      'uuid': uuid,
      'avatar_url': avatarUrl,
    };
  }
}

/// 转账结果模型
class TransferResult {
  final bool success;
  final String? message;
  final UserInfo? updatedUserInfo;

  TransferResult({
    required this.success,
    this.message,
    this.updatedUserInfo,
  });

  factory TransferResult.fromJson(Map<String, dynamic> json) {
    return TransferResult(
      success: json['status'] == 'success',
      message: json['message'],
      updatedUserInfo: json['data'] != null ? UserInfo.fromJson(json['data']) : null,
    );
  }
}

/// 提现结果模型
class WithdrawResult {
  final bool success;
  final String? message;
  final String? withdrawId;

  WithdrawResult({
    required this.success,
    this.message,
    this.withdrawId,
  });

  factory WithdrawResult.fromJson(Map<String, dynamic> json) {
    return WithdrawResult(
      success: json['status'] == 'success',
      message: json['message'],
      withdrawId: json['data']?['withdraw_id']?.toString(),
    );
  }
} 