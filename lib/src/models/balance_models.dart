/// 系统配置模型
class SystemConfig {
  final String? currency;
  final bool withdrawEnabled;
  final int? minWithdrawAmount;
  final int? maxWithdrawAmount;
  final double? withdrawFeeRate;
  final List<String>? withdrawMethods;
  final String? withdrawNotice;

  SystemConfig({
    this.currency,
    required this.withdrawEnabled,
    this.minWithdrawAmount,
    this.maxWithdrawAmount,
    this.withdrawFeeRate,
    this.withdrawMethods,
    this.withdrawNotice,
  });

  factory SystemConfig.fromJson(Map<String, dynamic> json) {
    return SystemConfig(
      currency: json['currency'],
      withdrawEnabled: json['withdraw_enable'] == 1 || json['withdraw_enable'] == true,
      minWithdrawAmount: json['min_withdraw_amount'],
      maxWithdrawAmount: json['max_withdraw_amount'],
      withdrawFeeRate: json['withdraw_fee_rate']?.toDouble(),
      withdrawMethods: json['withdraw_methods'] != null 
          ? List<String>.from(json['withdraw_methods'])
          : null,
      withdrawNotice: json['withdraw_notice'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'withdraw_enable': withdrawEnabled,
      'min_withdraw_amount': minWithdrawAmount,
      'max_withdraw_amount': maxWithdrawAmount,
      'withdraw_fee_rate': withdrawFeeRate,
      'withdraw_methods': withdrawMethods,
      'withdraw_notice': withdrawNotice,
    };
  }
}

/// 余额信息模型
class BalanceInfo {
  final double? balance;
  final double? commissionBalance;
  final double? totalBalance;
  final String? currency;

  BalanceInfo({
    this.balance,
    this.commissionBalance,
    this.totalBalance,
    this.currency,
  });

  factory BalanceInfo.fromJson(Map<String, dynamic> json) {
    return BalanceInfo(
      balance: json['balance']?.toDouble(),
      commissionBalance: json['commission_balance']?.toDouble(),
      totalBalance: json['total_balance']?.toDouble(),
      currency: json['currency'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'commission_balance': commissionBalance,
      'total_balance': totalBalance,
      'currency': currency,
    };
  }
}

/// 转账结果模型
class TransferResult {
  final bool success;
  final String? message;
  final double? newBalance;
  final double? transferAmount;

  TransferResult({
    required this.success,
    this.message,
    this.newBalance,
    this.transferAmount,
  });

  factory TransferResult.fromJson(Map<String, dynamic> json) {
    return TransferResult(
      success: json['success'] ?? false,
      message: json['message'],
      newBalance: json['new_balance']?.toDouble(),
      transferAmount: json['transfer_amount']?.toDouble(),
    );
  }
}

/// 提现结果模型
class WithdrawResult {
  final bool success;
  final String? message;
  final String? withdrawId;
  final String? status;

  WithdrawResult({
    required this.success,
    this.message,
    this.withdrawId,
    this.status,
  });

  factory WithdrawResult.fromJson(Map<String, dynamic> json) {
    return WithdrawResult(
      success: json['success'] ?? false,
      message: json['message'],
      withdrawId: json['withdraw_id'],
      status: json['status'],
    );
  }
} 