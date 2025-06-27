import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';

void main() async {
  // 使用XBoard SDK的完整示例
  await xboardExample();
}

Future<void> xboardExample() async {
  // 获取SDK实例
  final sdk = XBoardSDK.instance;

  try {
    // 1. 初始化SDK
    print('初始化XBoard SDK...');
    await sdk.initialize('https://your-xboard-domain.com');
    print('SDK初始化成功');

    // 2. 用户登录示例
    print('\n开始用户登录...');
    final loginResult = await sdk.auth.login(
      'user@example.com',
      'password123',
    );
    
    if (loginResult['success'] == true) {
      print('登录成功!');
      
      // 从响应中获取token
      final token = loginResult['data']['token'];
      if (token != null) {
        // 设置认证token
        sdk.setAuthToken(token);
        print('已设置认证token');
      }
      
      // 解析用户信息
      final loginResponse = LoginResponse.fromJson(loginResult);
      if (loginResponse.user != null) {
        print('用户ID: ${loginResponse.user!.id}');
        print('用户邮箱: ${loginResponse.user!.email}');
        print('账户余额: ${loginResponse.user!.balance}');
      }
    } else {
      print('登录失败: ${loginResult['message']}');
      return;
    }

    // 3. 发送验证码示例
    print('\n发送邮箱验证码...');
    final verifyResult = await sdk.auth.sendVerificationCode('user@example.com');
    if (verifyResult['success'] == true) {
      print('验证码发送成功');
    } else {
      print('验证码发送失败: ${verifyResult['message']}');
    }

    // 4. 用户注册示例
    print('\n用户注册示例...');
    final registerResult = await sdk.auth.register(
      'newuser@example.com',
      'newpassword123',
      'invite_code_123',
      'email_verification_code',
    );
    
    if (registerResult['success'] == true) {
      print('注册成功!');
    } else {
      print('注册失败: ${registerResult['message']}');
    }

    // 5. 刷新token示例
    print('\n刷新认证token...');
    final refreshResult = await sdk.auth.refreshToken();
    if (refreshResult['success'] == true) {
      final newToken = refreshResult['data']['token'];
      if (newToken != null) {
        sdk.setAuthToken(newToken);
        print('Token刷新成功');
      }
    }

    // 6. 重置密码示例
    print('\n重置密码示例...');
    final resetResult = await sdk.auth.resetPassword(
      'user@example.com',
      'new_password123',
      'email_verification_code',
    );
    
    if (resetResult['success'] == true) {
      print('密码重置成功');
    } else {
      print('密码重置失败: ${resetResult['message']}');
    }

    // 7. 退出登录
    print('\n退出登录...');
    final logoutResult = await sdk.auth.logout();
    if (logoutResult['success'] == true) {
      // 清除本地token
      sdk.clearAuthToken();
      print('退出登录成功');
    }

  } catch (e) {
    print('发生错误: $e');
    
    // 处理特定类型的异常
    if (e is AuthException) {
      print('认证错误: ${e.message}');
    } else if (e is NetworkException) {
      print('网络错误: ${e.message}');
    } else if (e is ConfigException) {
      print('配置错误: ${e.message}');
    }
  }
}

// 使用模型类的示例
void modelExample() {
  // 创建登录请求
  final loginRequest = LoginRequest(
    email: 'user@example.com',
    password: 'password123',
  );
  
  print('登录请求数据: ${loginRequest.toJson()}');
  
  // 解析API响应
  final apiResponseJson = {
    'success': true,
    'message': 'Login successful',
    'data': {
      'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
      'user': {
        'id': 1,
        'email': 'user@example.com',
        'balance': 10000,
        'commission_balance': 500,
      }
    }
  };
  
  final loginResponse = LoginResponse.fromJson(apiResponseJson);
  print('解析后的响应:');
  print('  成功: ${loginResponse.success}');
  print('  消息: ${loginResponse.message}');
  print('  Token: ${loginResponse.token}');
  print('  用户信息: ${loginResponse.user?.toJson()}');
} 