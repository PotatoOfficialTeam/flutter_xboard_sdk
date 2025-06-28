/// 登录请求模型
class LoginRequest {
  final String email;
  final String password;

  LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

/// 登录响应模型 - 兼容XBoard API格式
class LoginResponse {
  final bool success;
  final String? message;
  final String? token;
  final Map<String, dynamic>? user;

  LoginResponse({
    required this.success,
    this.message,
    this.token,
    this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    // 兼容两种格式：success字段和status字段
    bool isSuccess = false;
    if (json.containsKey('success')) {
      isSuccess = json['success'] ?? false;
    } else if (json.containsKey('status')) {
      isSuccess = json['status'] == 'success';
    }

    return LoginResponse(
      success: isSuccess,
      message: json['message'],
      token: json['data']?['token'],
      user: json['data']?['user'],
    );
  }
}

/// 注册请求模型
class RegisterRequest {
  final String email;
  final String password;
  final String inviteCode;
  final String emailCode;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.inviteCode,
    required this.emailCode,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'invite_code': inviteCode,
      'email_code': emailCode,
    };
  }
}

/// API响应基础模型 - 兼容XBoard格式
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int? code;
  final dynamic error;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.code,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    // 兼容两种格式：success字段和status字段
    bool isSuccess = false;
    if (json.containsKey('success')) {
      isSuccess = json['success'] ?? false;
    } else if (json.containsKey('status')) {
      isSuccess = json['status'] == 'success';
    }

    return ApiResponse<T>(
      success: isSuccess,
      message: json['message'],
      code: json['code'],
      error: json['error'],
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
    );
  }
}

/// 验证码发送响应
class VerificationCodeResponse {
  final bool success;
  final String? message;

  VerificationCodeResponse({
    required this.success,
    this.message,
  });

  factory VerificationCodeResponse.fromJson(Map<String, dynamic> json) {
    bool isSuccess = false;
    if (json.containsKey('success')) {
      isSuccess = json['success'] ?? false;
    } else if (json.containsKey('status')) {
      isSuccess = json['status'] == 'success';
    }

    return VerificationCodeResponse(
      success: isSuccess,
      message: json['message'],
    );
  }
} 