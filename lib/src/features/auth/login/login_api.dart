import 'package:flutter_xboard_sdk/src/features/auth/login/login_models.dart';
import 'package:flutter_xboard_sdk/src/services/http_service.dart';

class LoginApi {
  final HttpService _httpService;

  LoginApi(this._httpService);

  /// 用户登录
  /// [email] 邮箱地址
  /// [password] 密码
  /// 返回登录结果，包含token等信息
  Future<LoginResponse> login(String email, String password) async {
    final response = await _httpService.postRequest(
      "/api/v1/passport/auth/login",
      {"email": email, "password": password},
    );
    print('Login API raw response: $response'); // Add this line for debugging
    return LoginResponse.fromJson(response);
  }
}
