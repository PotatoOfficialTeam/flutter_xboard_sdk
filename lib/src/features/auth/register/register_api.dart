import 'package:flutter_xboard_sdk/src/services/http_service.dart';
import 'package:flutter_xboard_sdk/src/common/models/api_response.dart';

class RegisterApi {
  final HttpService _httpService;

  RegisterApi(this._httpService);

  /// 用户注册
  /// [email] 邮箱地址
  /// [password] 密码
  /// [inviteCode] 邀请码
  /// [emailCode] 邮箱验证码
  /// 返回注册结果
  Future<ApiResponse> register(
    String email,
    String password,
    String inviteCode,
    String emailCode,
  ) async {
    final response = await _httpService.postRequest(
      "/api/v1/passport/auth/register",
      {
        "email": email,
        "password": password,
        "invite_code": inviteCode,
        "email_code": emailCode,
      },
    );
    return ApiResponse.fromJson(response, (json) => json);
  }
}