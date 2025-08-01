import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_models.freezed.dart';
part 'register_models.g.dart';

/// 注册请求模型
@freezed
class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    required String email,
    required String password,
    @JsonKey(name: 'invite_code') required String inviteCode,
    @JsonKey(name: 'email_code') required String emailCode,
  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);
}

class RegistrationConfig {
  final String? tosUrl;
  final int isEmailVerify; // int类型：1开启，0关闭
  final int isInviteForce; // int类型：1需要，0不需要
  final List<String> emailWhitelistSuffix;
  final int isRecaptcha; // int类型：1开启，0关闭
  final String? recaptchaSiteKey;
  final String appDescription;
  final String appUrl;
  final String logo;

  RegistrationConfig({
    this.tosUrl,
    required this.isEmailVerify,
    required this.isInviteForce,
    required this.emailWhitelistSuffix,
    required this.isRecaptcha,
    this.recaptchaSiteKey,
    required this.appDescription,
    required this.appUrl,
    required this.logo,
  });

  factory RegistrationConfig.fromJson(Map<String, dynamic> json) {
    List<String> emailWhitelist = [];
    if (json['email_whitelist_suffix'] is List) {
      emailWhitelist = (json['email_whitelist_suffix'] as List)
          .map((item) => item.toString())
          .toList();
    }

    return RegistrationConfig(
      tosUrl: json['tos_url'] != null ? json['tos_url'] as String : null,
      isEmailVerify: json['is_email_verify'] is bool
          ? (json['is_email_verify'] as bool ? 1 : 0)
          : json['is_email_verify'] as int,
      isInviteForce: json['is_invite_force'] as int,
      emailWhitelistSuffix: emailWhitelist,
      isRecaptcha: json['is_recaptcha'] as int,
      recaptchaSiteKey: json['recaptcha_site_key'] != null
          ? json['recaptcha_site_key'] as String
          : null,
      appDescription: json['app_description'] as String,
      appUrl: json['app_url'] as String,
      logo: json['logo'] != null ? json['logo'] as String : '',
    );
  }

  // 布尔转换辅助方法
  bool get isEmailVerifyBool => isEmailVerify == 1;
  bool get isInviteForceBool => isInviteForce == 1;
  bool get isRecaptchaBool => isRecaptcha == 1;

  Map<String, dynamic> toJson() {
    return {
      'tos_url': tosUrl,
      'is_email_verify': isEmailVerify,
      'is_invite_force': isInviteForce,
      'email_whitelist_suffix': emailWhitelistSuffix,
      'is_recaptcha': isRecaptcha,
      'recaptcha_site_key': recaptchaSiteKey,
      'app_description': appDescription,
      'app_url': appUrl,
      'logo': logo,
    };
  }
}