<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/tools/pub/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/to/develop-packages).
-->

# XBoard Flutter SDK

一个用于集成XBoard API的Flutter SDK，提供简单易用的接口来访问XBoard的各种功能。

## 功能特性

- 🔐 完整的用户认证系统（登录、注册、退出）
- 📧 邮箱验证码发送和验证
- 🔑 密码重置功能
- 🔄 Token自动管理和刷新
- 🛡️ 类型安全的API调用
- 🧪 完整的单元测试覆盖
- 📱 异常处理和错误管理

## 安装

在你的 `pubspec.yaml` 文件中添加依赖：

```yaml
dependencies:
  flutter_xboard_sdk: ^0.0.1
```

然后运行：

```bash
flutter pub get
```

## 快速开始

### 1. 初始化SDK

```dart
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';

// 获取SDK实例并初始化
final sdk = XBoardSDK.instance;
await sdk.initialize('https://your-xboard-domain.com');
```

### 2. 用户登录

```dart
try {
  final result = await sdk.auth.login('user@example.com', 'password123');
  
  if (result['success'] == true) {
    // 登录成功，设置token
    final token = result['data']['token'];
    sdk.setAuthToken(token);
    
    // 解析用户信息
    final loginResponse = LoginResponse.fromJson(result);
    print('欢迎，${loginResponse.user?.email}！');
  }
} catch (e) {
  print('登录失败: $e');
}
```

### 3. 用户注册

```dart
try {
  // 先发送验证码
  await sdk.auth.sendVerificationCode('newuser@example.com');
  
  // 用户输入验证码后进行注册
  final result = await sdk.auth.register(
    'newuser@example.com',
    'password123',
    'invite_code',
    'verification_code',
  );
  
  if (result['success'] == true) {
    print('注册成功！');
  }
} catch (e) {
  print('注册失败: $e');
}
```

### 4. 密码重置

```dart
try {
  // 发送验证码
  await sdk.auth.sendVerificationCode('user@example.com');
  
  // 重置密码
  final result = await sdk.auth.resetPassword(
    'user@example.com',
    'new_password123',
    'verification_code',
  );
  
  if (result['success'] == true) {
    print('密码重置成功！');
  }
} catch (e) {
  print('密码重置失败: $e');
}
```

### 5. 退出登录

```dart
try {
  await sdk.auth.logout();
  sdk.clearAuthToken();
  print('退出登录成功');
} catch (e) {
  print('退出登录失败: $e');
}
```

## API 参考

### XBoardSDK

主要的SDK类，提供单例模式访问。

```dart
// 获取实例
final sdk = XBoardSDK.instance;

// 初始化
await sdk.initialize(String baseUrl);

// Token管理
sdk.setAuthToken(String token);
sdk.clearAuthToken();

// 检查初始化状态
bool isInitialized = sdk.isInitialized;
```

### AuthService

认证服务，处理用户相关操作。

```dart
// 登录
Future<Map<String, dynamic>> login(String email, String password);

// 注册
Future<Map<String, dynamic>> register(String email, String password, String inviteCode, String emailCode);

// 发送验证码
Future<Map<String, dynamic>> sendVerificationCode(String email);

// 重置密码
Future<Map<String, dynamic>> resetPassword(String email, String password, String emailCode);

// 刷新Token
Future<Map<String, dynamic>> refreshToken();

// 退出登录
Future<Map<String, dynamic>> logout();
```

### 数据模型

#### LoginResponse
```dart
class LoginResponse {
  final bool success;
  final String? message;
  final String? token;
  final UserInfo? user;
}
```

#### UserInfo
```dart
class UserInfo {
  final int? id;
  final String? email;
  final String? avatar;
  final int? balance;
  final int? commissionBalance;
  final String? telegramId;
}
```

## 异常处理

SDK提供了多种异常类型：

```dart
try {
  await sdk.auth.login(email, password);
} on AuthException catch (e) {
  print('认证错误: ${e.message}');
} on NetworkException catch (e) {
  print('网络错误: ${e.message}');
} on ConfigException catch (e) {
  print('配置错误: ${e.message}');
} on ParameterException catch (e) {
  print('参数错误: ${e.message}');
} catch (e) {
  print('未知错误: $e');
}
```

## 高级用法

### 自定义HTTP请求

如果需要调用SDK未封装的API，可以直接使用HttpService：

```dart
final httpService = sdk.httpService;

// GET请求
final result = await httpService.getRequest('/api/v1/user/info');

// POST请求
final result = await httpService.postRequest('/api/v1/custom', {
  'key': 'value',
});
```

### 使用模型类

```dart
// 创建请求模型
final loginRequest = LoginRequest(
  email: 'user@example.com',
  password: 'password123',
);

// 序列化为JSON
final json = loginRequest.toJson();

// 解析响应
final response = LoginResponse.fromJson(apiResponse);
```

## 测试

运行测试：

```bash
flutter test
```

SDK包含了完整的单元测试，确保代码质量和稳定性。

## 贡献

欢迎提交Issue和Pull Request来改进这个SDK。

## 许可证

MIT License

## 更新日志

### 0.0.1
- 初始版本发布
- 实现基础认证功能
- 添加用户登录、注册、密码重置
- 完整的类型定义和异常处理
