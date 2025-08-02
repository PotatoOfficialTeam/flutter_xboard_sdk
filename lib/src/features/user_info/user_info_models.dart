
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_info_models.freezed.dart';
part 'user_info_models.g.dart';

DateTime? _fromUnixTimestamp(int? timestamp) =>
    timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp * 1000) : null;
int? _toUnixTimestamp(DateTime? date) =>
    date?.millisecondsSinceEpoch == null ? null : date!.millisecondsSinceEpoch ~/ 1000;

bool _intToBool(dynamic value) {
  if (value is bool) {
    return value;
  }
  if (value is int) {
    return value == 1;
  }
  return false; // Default or handle error
}
int _boolToInt(bool value) => value ? 1 : 0;

// Helper functions for telegram_id conversion
String? _telegramIdFromJson(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is int) return value.toString();
  return value.toString();
}

dynamic _telegramIdToJson(String? value) => value;

@freezed
class UserInfo with _$UserInfo {
  const factory UserInfo({
    required String email,
    @JsonKey(name: 'transfer_enable') required double transferEnable,
    @JsonKey(name: 'last_login_at', fromJson: _fromUnixTimestamp, toJson: _toUnixTimestamp)
    DateTime? lastLoginAt,
    @JsonKey(name: 'created_at', fromJson: _fromUnixTimestamp, toJson: _toUnixTimestamp)
    DateTime? createdAt,
    @JsonKey(fromJson: _intToBool, toJson: _boolToInt) required bool banned,
    @JsonKey(name: 'remind_expire', fromJson: _intToBool, toJson: _boolToInt)
    required bool remindExpire,
    @JsonKey(name: 'remind_traffic', fromJson: _intToBool, toJson: _boolToInt)
    required bool remindTraffic,
    @JsonKey(name: 'expired_at', fromJson: _fromUnixTimestamp, toJson: _toUnixTimestamp)
    DateTime? expiredAt,
    required double balance,
    @JsonKey(name: 'commission_balance') required double commissionBalance,
    @JsonKey(name: 'plan_id') required int planId,
    double? discount,
    @JsonKey(name: 'commission_rate') double? commissionRate,
    @JsonKey(name: 'telegram_id', fromJson: _telegramIdFromJson, toJson: _telegramIdToJson) String? telegramId,
    required String uuid,
    @JsonKey(name: 'avatar_url') required String avatarUrl,
  }) = _UserInfo;

  const UserInfo._();

  factory UserInfo.fromJson(Map<String, dynamic> json) => _$UserInfoFromJson(json);

  double get balanceInYuan => balance / 100;
  double get commissionBalanceInYuan => commissionBalance / 100;
}
