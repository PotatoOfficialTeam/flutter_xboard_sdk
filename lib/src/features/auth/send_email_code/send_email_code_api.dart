import 'package:flutter_xboard_sdk/src/features/auth/send_email_code/send_email_code_models.dart';
import 'package:flutter_xboard_sdk/src/services/http_service.dart';

class SendEmailCodeApi {
  final HttpService _httpService;

  SendEmailCodeApi(this._httpService);

  /// 发送邮箱验证码
  /// [email] 邮箱地址
  /// 返回发送结果
  Future<VerificationCodeResponse> sendVerificationCode(String email) async {
    final response = await _httpService.postRequest(
      "/api/v1/passport/comm/sendEmailVerify",
      {'email': email},
    );
    return VerificationCodeResponse.fromJson(response);
  }
}