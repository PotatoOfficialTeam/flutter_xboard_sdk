/// 用户信息模型
class UserInfo {
  final String email;
  final double transferEnable;
  final int? lastLoginAt;
  final int createdAt;
  final bool banned;
  final bool remindExpire;
  final bool remindTraffic;
  final int? expiredAt;
  final double balance;
  final double commissionBalance;
  final int planId;
  final double? discount;
  final double? commissionRate;
  final String? telegramId;
  final String uuid;
  final String avatarUrl;

  double get balanceInYuan => balance / 100;
  double get commissionBalanceInYuan => commissionBalance / 100;

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
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'transfer_enable': transferEnable,
      'last_login_at': lastLoginAt,
      'created_at': createdAt,
      'banned': banned ? 1 : 0,
      'remind_expire': remindExpire ? 1 : 0,
      'remind_traffic': remindTraffic ? 1 : 0,
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