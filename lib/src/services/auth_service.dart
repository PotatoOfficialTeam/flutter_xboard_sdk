import 'http_service.dart';

class AuthService {
  final HttpService _httpService;

  AuthService(this._httpService);

  /// 用户登录
  /// [email] 邮箱地址
  /// [password] 密码
  /// 返回登录结果，包含token等信息
  Future<Map<String, dynamic>> login(String email, String password) async {
    return await _httpService.postRequest(
      "/api/v1/passport/auth/login",
      {"email": email, "password": password},
    );
  }

  /// 用户注册
  /// [email] 邮箱地址
  /// [password] 密码
  /// [inviteCode] 邀请码
  /// [emailCode] 邮箱验证码
  /// 返回注册结果
  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String inviteCode,
    String emailCode,
  ) async {
    return await _httpService.postRequest(
      "/api/v1/passport/auth/register",
      {
        "email": email,
        "password": password,
        "invite_code": inviteCode,
        "email_code": emailCode,
      },
    );
  }

  /// 发送邮箱验证码
  /// [email] 邮箱地址
  /// 返回发送结果
  Future<Map<String, dynamic>> sendVerificationCode(String email) async {
    return await _httpService.postRequest(
      "/api/v1/passport/comm/sendEmailVerify",
      {'email': email},
    );
  }

  /// 重置密码
  /// [email] 邮箱地址
  /// [password] 新密码
  /// [emailCode] 邮箱验证码
  /// 返回重置结果
  Future<Map<String, dynamic>> resetPassword(
    String email,
    String password,
    String emailCode,
  ) async {
    return await _httpService.postRequest(
      "/api/v1/passport/auth/forget",
      {
        "email": email,
        "password": password,
        "email_code": emailCode,
      },
    );
  }

  /// 刷新token
  /// 返回新的token信息
  Future<Map<String, dynamic>> refreshToken() async {
    return await _httpService.postRequest(
      "/api/v1/passport/auth/token",
      {},
    );
  }

  /// 退出登录
  /// 返回退出结果
  Future<Map<String, dynamic>> logout() async {
    return await _httpService.postRequest(
      "/api/v1/passport/auth/logout",
      {},
    );
  }
} 