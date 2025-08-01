import 'package:flutter_xboard_sdk/src/services/http_service.dart';
import 'package:flutter_xboard_sdk/src/common/models/api_response.dart';

class ResetPasswordApi {
  final HttpService _httpService;

  ResetPasswordApi(this._httpService);

  /// 重置密码
  /// [email] 邮箱地址
  /// [password] 新密码
  /// [emailCode] 邮箱验证码
  /// 返回重置结果
  Future<ApiResponse> resetPassword(
    String email,
    String password,
    String emailCode,
  ) async {
    final response = await _httpService.postRequest(
      "/api/v1/passport/auth/forget",
      {
        "email": email,
        "password": password,
        "email_code": emailCode,
      },
    );
    return ApiResponse.fromJson(response, (json) => json);
  }
}