import 'package:freezed_annotation/freezed_annotation.dart';

part 'config_models.freezed.dart';
part 'config_models.g.dart';

@freezed
class ConfigData with _$ConfigData {
  const factory ConfigData({
    @JsonKey(name: 'tos_url') String? tosUrl,
    @JsonKey(name: 'is_email_verify', fromJson: _intToBool, toJson: _boolToInt)
    required bool isEmailVerify,
    @JsonKey(name: 'is_invite_force', fromJson: _intToBool, toJson: _boolToInt)
    required bool isInviteForce,
    @JsonKey(name: 'email_whitelist_suffix', fromJson: _emailWhitelistFromJson, toJson: _emailWhitelistToJson)
    required List<String> emailWhitelistSuffix,
    @JsonKey(name: 'is_captcha', fromJson: _intToBool, toJson: _boolToInt)
    required bool isCaptcha,
    @JsonKey(name: 'captcha_type') required String captchaType,
    @JsonKey(name: 'recaptcha_site_key') String? recaptchaSiteKey,
    @JsonKey(name: 'recaptcha_v3_site_key') String? recaptchaV3SiteKey,
    @JsonKey(name: 'recaptcha_v3_score_threshold')
    required double recaptchaV3ScoreThreshold,
    @JsonKey(name: 'turnstile_site_key') String? turnstileSiteKey,
    @JsonKey(name: 'app_description') required String appDescription,
    @JsonKey(name: 'app_url') required String appUrl,
    String? logo,
    @JsonKey(name: 'is_recaptcha', fromJson: _intToBool, toJson: _boolToInt)
    required bool isRecaptcha,
  }) = _ConfigData;

  factory ConfigData.fromJson(Map<String, dynamic> json) => _$ConfigDataFromJson(json);
}

bool _intToBool(int value) => value == 1;
int _boolToInt(bool value) => value ? 1 : 0;

List<String> _emailWhitelistFromJson(dynamic value) {
  if (value is int && value == 0) {
    return [];
  }
  if (value is List) {
    return value.map((e) => e.toString()).toList();
  }
  return [];
}

dynamic _emailWhitelistToJson(List<String> value) {
  if (value.isEmpty) {
    return 0; // 或者根据API要求返回其他默认值
  }
  return value;
}


@freezed
class ConfigResponse with _$ConfigResponse {
  const factory ConfigResponse({
    required String status,
    required String message,
    ConfigData? data,
    dynamic error,
  }) = _ConfigResponse;

  factory ConfigResponse.fromJson(Map<String, dynamic> json) => _$ConfigResponseFromJson(json);
}