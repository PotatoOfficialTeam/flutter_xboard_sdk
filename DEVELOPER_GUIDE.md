# XBoard Flutter SDK 开发集成指南

## 📖 目录
- [快速开始](#快速开始)
- [安装配置](#安装配置)
- [基础集成](#基础集成)
- [核心功能](#核心功能)
- [高级用法](#高级用法)
- [错误处理](#错误处理)
- [最佳实践](#最佳实践)
- [调试和测试](#调试和测试)
- [常见问题](#常见问题)

---

## 🚀 快速开始

### 30秒集成示例

```dart
// 1. 初始化SDK
await XBoardSDK.instance.initialize('https://your-xboard-domain.com');

// 2. 用户登录
final success = await XBoardSDK.instance.loginWithCredentials(
  'user@example.com', 
  'password123'
);

// 3. 获取用户信息
if (success) {
  final userInfo = await XBoardSDK.instance.userInfo.getUserInfo();
  print('用户邮箱: ${userInfo.data?.email}');
}
```

---

## 📦 安装配置

### 1. 添加依赖

在你的 `pubspec.yaml` 文件中添加：

```yaml
dependencies:
  flutter_xboard_sdk:
    path: ./lib/sdk/flutter_xboard_sdk  # 本地路径
    # 或者 git 仓库路径:
    # git:
    #   url: https://github.com/your-org/flutter_xboard_sdk.git
    #   ref: main
```

### 2. 运行依赖安装

```bash
flutter pub get
```

### 3. 导入SDK

```dart
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';
```

---

## 🔧 基础集成

### 1. 在应用启动时初始化

```dart
// lib/main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化XBoard SDK
  try {
    await XBoardSDK.instance.initialize('https://your-xboard-domain.com');
    print('XBoard SDK初始化成功');
  } catch (e) {
    print('XBoard SDK初始化失败: $e');
  }
  
  runApp(MyApp());
}
```

### 2. 创建服务包装类（推荐）

```dart
// lib/services/xboard_service.dart
class XBoardService {
  static XBoardService? _instance;
  static XBoardService get instance => _instance ??= XBoardService._();
  
  XBoardService._();
  
  // 检查SDK是否已初始化
  bool get isInitialized => XBoardSDK.instance.isInitialized;
  
  // 检查用户是否已登录
  bool get isLoggedIn => XBoardSDK.instance.isAuthenticated;
  
  // 获取当前认证状态
  AuthState get authState => XBoardSDK.instance.authState;
  
  // 监听认证状态变化
  Stream<AuthState> get authStateStream => XBoardSDK.instance.authStateStream;
}
```

### 3. 状态管理集成（Riverpod示例）

```dart
// lib/providers/xboard_providers.dart
import 'package:riverpod/riverpod.dart';

// 认证状态Provider
final authStateProvider = StreamProvider<AuthState>((ref) {
  return XBoardService.instance.authStateStream;
});

// 用户信息Provider
final userInfoProvider = FutureProvider<UserInfo?>((ref) async {
  if (!XBoardService.instance.isLoggedIn) return null;
  
  try {
    final response = await XBoardSDK.instance.userInfo.getUserInfo();
    return response.data;
  } catch (e) {
    print('获取用户信息失败: $e');
    return null;
  }
});

// 订阅信息Provider
final subscriptionInfoProvider = FutureProvider<SubscriptionInfo?>((ref) async {
  if (!XBoardService.instance.isLoggedIn) return null;
  
  try {
    final response = await XBoardSDK.instance.subscription.getSubscriptionInfo();
    return response.data;
  } catch (e) {
    print('获取订阅信息失败: $e');
    return null;
  }
});
```

---

## 🎯 核心功能

### 1. 用户认证

#### 登录
```dart
// 方式1: 使用便捷方法（推荐）
final success = await XBoardSDK.instance.loginWithCredentials(
  'user@example.com',
  'password123'
);

// 方式2: 使用底层API
final response = await XBoardSDK.instance.login.login(
  'user@example.com', 
  'password123'
);

if (response.success && response.data?.token != null) {
  await XBoardSDK.instance.saveTokens(
    accessToken: response.data!.token!,
    refreshToken: response.data!.token!, // 根据实际API调整
    expiry: DateTime.now().add(Duration(hours: 24)),
  );
}
```

#### 注册
```dart
// 1. 发送验证码
final codeResponse = await XBoardSDK.instance.sendEmailCode.sendEmailCode(
  'newuser@example.com'
);

if (codeResponse.success) {
  // 2. 用户输入验证码后注册
  final registerResponse = await XBoardSDK.instance.register.register(
    email: 'newuser@example.com',
    password: 'password123',
    emailCode: 'verification_code', // 用户输入的验证码
    inviteCode: 'optional_invite_code', // 可选邀请码
  );
  
  if (registerResponse.success) {
    print('注册成功');
  }
}
```

#### 重置密码
```dart
// 1. 发送验证码
await XBoardSDK.instance.sendEmailCode.sendEmailCode('user@example.com');

// 2. 重置密码
final response = await XBoardSDK.instance.resetPassword.resetPassword(
  email: 'user@example.com',
  password: 'new_password',
  emailCode: 'verification_code',
);
```

#### 登出
```dart
await XBoardSDK.instance.clearTokens();
```

### 2. 订阅管理

```dart
// 获取订阅信息
final subscriptionResponse = await XBoardSDK.instance.subscription.getSubscriptionInfo();
if (subscriptionResponse.success && subscriptionResponse.data != null) {
  final subscription = subscriptionResponse.data!;
  print('订阅链接: ${subscription.subscribeUrl}');
  print('已用流量: ${subscription.usedTraffic}');
  print('总流量: ${subscription.totalTraffic}');
}

// 重置订阅链接
final resetResponse = await XBoardSDK.instance.subscription.resetSubscription();
if (resetResponse.success) {
  print('订阅链接已重置');
}
```

### 3. 用户信息

```dart
final userResponse = await XBoardSDK.instance.userInfo.getUserInfo();
if (userResponse.success && userResponse.data != null) {
  final user = userResponse.data!;
  print('用户邮箱: ${user.email}');
  print('余额: ${user.balance}');
  print('佣金: ${user.commissionBalance}');
  print('到期时间: ${user.expiredAt}');
}
```

### 4. 套餐管理

```dart
// 获取可用套餐
final plansResponse = await XBoardSDK.instance.plan.getPlans();
if (plansResponse.success && plansResponse.data != null) {
  for (final plan in plansResponse.data!) {
    print('套餐: ${plan.name} - 价格: ${plan.price}');
  }
}
```

### 5. 余额相关

```dart
// 获取余额信息
final balanceResponse = await XBoardSDK.instance.balanceApi.getUserInfo();

// 佣金转账
final transferResponse = await XBoardSDK.instance.balanceApi.transferCommission(1000); // 10.00元（分为单位）

// 申请提现
final withdrawResponse = await XBoardSDK.instance.balanceApi.withdrawFunds(
  'alipay', 
  'your_account@example.com'
);
```

---

## 🔬 高级用法

### 1. Token管理配置

```dart
// 自定义Token存储配置
final tokenConfig = TokenStorageConfig.custom(
  storage: SecureTokenStorage(), // 安全存储
  refreshBuffer: Duration(minutes: 5), // 提前5分钟刷新
  autoRefresh: true, // 自动刷新
  onTokenExpired: () {
    print('Token已过期');
    // 跳转到登录页面
  },
  onRefreshFailed: (error) {
    print('Token刷新失败: $error');
    // 清除Token并跳转到登录页面
  },
);

await XBoardSDK.instance.initialize(
  'https://your-xboard-domain.com',
  tokenConfig: tokenConfig,
);
```

### 2. 自定义HTTP请求

```dart
// 访问底层HTTP服务
final httpService = XBoardSDK.instance.httpService;

// 自定义GET请求
final response = await httpService.getRequest('/api/v1/custom/endpoint');

// 自定义POST请求
final response = await httpService.postRequest('/api/v1/custom/action', {
  'param1': 'value1',
  'param2': 'value2',
});
```

### 3. 监听认证状态

```dart
// 使用StreamBuilder监听认证状态
StreamBuilder<AuthState>(
  stream: XBoardSDK.instance.authStateStream,
  builder: (context, snapshot) {
    final authState = snapshot.data ?? AuthState.unauthenticated;
    
    switch (authState) {
      case AuthState.authenticated:
        return DashboardPage();
      case AuthState.unauthenticated:
        return LoginPage();
      case AuthState.refreshing:
        return LoadingPage();
      default:
        return LoginPage();
    }
  },
);
```

---

## ⚠️ 错误处理

### 1. 异常类型

```dart
try {
  await XBoardSDK.instance.login.login('email', 'password');
} on AuthException catch (e) {
  print('认证错误: ${e.message}');
  // 显示登录错误提示
} on NetworkException catch (e) {
  print('网络错误: ${e.message}');
  // 显示网络错误提示
} on ApiException catch (e) {
  print('API错误: ${e.message} (代码: ${e.code})');
  // 根据错误代码显示不同提示
} on ConfigException catch (e) {
  print('配置错误: ${e.message}');
  // 检查SDK配置
} catch (e) {
  print('未知错误: $e');
  // 通用错误处理
}
```

### 2. 统一错误处理器

```dart
class ErrorHandler {
  static void handle(dynamic error, {VoidCallback? onRetry}) {
    String message = '操作失败';
    bool canRetry = false;
    
    if (error is AuthException) {
      message = '登录信息已过期，请重新登录';
      // 自动跳转到登录页面
      navigateToLogin();
    } else if (error is NetworkException) {
      message = '网络连接失败，请检查网络设置';
      canRetry = true;
    } else if (error is ApiException) {
      message = error.message;
      canRetry = error.code != 401; // 401不可重试
    }
    
    // 显示错误提示
    showErrorDialog(message, canRetry: canRetry, onRetry: onRetry);
  }
}

// 使用示例
try {
  await XBoardSDK.instance.userInfo.getUserInfo();
} catch (e) {
  ErrorHandler.handle(e, onRetry: () {
    // 重试逻辑
  });
}
```

---

## 💡 最佳实践

### 1. 项目结构建议

```
lib/
├── services/
│   ├── xboard_service.dart      # XBoard业务逻辑封装
│   └── auth_service.dart        # 认证状态管理
├── providers/
│   ├── xboard_providers.dart    # Riverpod providers
│   └── auth_providers.dart      # 认证相关providers
├── models/
│   └── app_models.dart          # 应用级数据模型
├── pages/
│   ├── auth/
│   │   ├── login_page.dart
│   │   ├── register_page.dart
│   │   └── reset_password_page.dart
│   └── dashboard/
│       ├── subscription_page.dart
│       └── profile_page.dart
└── utils/
    ├── error_handler.dart       # 统一错误处理
    └── validators.dart          # 表单验证
```

### 2. 状态管理模式

```dart
// 认证状态管理
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.unauthenticated) {
    // 监听SDK认证状态变化
    XBoardSDK.instance.authStateStream.listen((authState) {
      state = authState;
    });
  }
  
  Future<bool> login(String email, String password) async {
    state = AuthState.loading;
    
    try {
      final success = await XBoardSDK.instance.loginWithCredentials(email, password);
      if (success) {
        state = AuthState.authenticated;
      } else {
        state = AuthState.unauthenticated;
      }
      return success;
    } catch (e) {
      state = AuthState.unauthenticated;
      rethrow;
    }
  }
  
  Future<void> logout() async {
    await XBoardSDK.instance.clearTokens();
    state = AuthState.unauthenticated;
  }
}
```

### 3. 数据缓存策略

```dart
class UserDataService {
  static const Duration cacheTimeout = Duration(minutes: 5);
  static DateTime? _lastFetch;
  static UserInfo? _cachedUserInfo;
  
  static Future<UserInfo?> getUserInfo({bool forceRefresh = false}) async {
    // 检查缓存是否有效
    if (!forceRefresh && 
        _cachedUserInfo != null && 
        _lastFetch != null &&
        DateTime.now().difference(_lastFetch!) < cacheTimeout) {
      return _cachedUserInfo;
    }
    
    // 从API获取最新数据
    try {
      final response = await XBoardSDK.instance.userInfo.getUserInfo();
      if (response.success && response.data != null) {
        _cachedUserInfo = response.data;
        _lastFetch = DateTime.now();
        return _cachedUserInfo;
      }
    } catch (e) {
      print('获取用户信息失败: $e');
    }
    
    return _cachedUserInfo; // 返回缓存的数据，即使过期
  }
  
  static void clearCache() {
    _cachedUserInfo = null;
    _lastFetch = null;
  }
}
```

### 4. 环境配置

```dart
// lib/config/app_config.dart
class AppConfig {
  static const String _prodBaseUrl = 'https://prod.xboard.com';
  static const String _stagingBaseUrl = 'https://staging.xboard.com';
  static const String _devBaseUrl = 'https://dev.xboard.com';
  
  static String get baseUrl {
    switch (const String.fromEnvironment('ENVIRONMENT', defaultValue: 'dev')) {
      case 'production':
        return _prodBaseUrl;
      case 'staging':
        return _stagingBaseUrl;
      default:
        return _devBaseUrl;
    }
  }
  
  static bool get isProduction => 
    const String.fromEnvironment('ENVIRONMENT') == 'production';
}

// 使用配置
await XBoardSDK.instance.initialize(AppConfig.baseUrl);
```

---

## 🧪 调试和测试

### 1. 启用调试模式

```dart
// 在开发环境中启用详细日志
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kDebugMode) {
    // 启用HTTP请求日志
    await XBoardSDK.instance.initialize(
      AppConfig.baseUrl,
      // 可以添加自定义配置来启用调试模式
    );
  }
  
  runApp(MyApp());
}
```

### 2. 测试用例示例

```dart
// test/xboard_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';

void main() {
  group('XBoard SDK Tests', () {
    setUp(() async {
      // 在测试环境中初始化SDK
      await XBoardSDK.instance.initialize('https://test.xboard.com');
    });
    
    test('用户登录测试', () async {
      final success = await XBoardSDK.instance.loginWithCredentials(
        'test@example.com',
        'testpassword',
      );
      
      expect(success, isTrue);
      expect(XBoardSDK.instance.isAuthenticated, isTrue);
    });
    
    test('获取用户信息测试', () async {
      // 先登录
      await XBoardSDK.instance.loginWithCredentials('test@example.com', 'testpassword');
      
      final response = await XBoardSDK.instance.userInfo.getUserInfo();
      
      expect(response.success, isTrue);
      expect(response.data, isNotNull);
      expect(response.data!.email, equals('test@example.com'));
    });
  });
}
```

### 3. 集成测试

```dart
// integration_test/xboard_integration_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:your_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('XBoard 集成测试', () {
    testWidgets('完整登录流程测试', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 找到登录表单
      final emailField = find.byKey(Key('email_field'));
      final passwordField = find.byKey(Key('password_field'));
      final loginButton = find.byKey(Key('login_button'));
      
      // 输入登录信息
      await tester.enterText(emailField, 'test@example.com');
      await tester.enterText(passwordField, 'testpassword');
      
      // 点击登录按钮
      await tester.tap(loginButton);
      await tester.pumpAndSettle();
      
      // 验证登录成功后的页面
      expect(find.text('欢迎'), findsOneWidget);
    });
  });
}
```

---

## ❓ 常见问题

### Q1: SDK初始化失败怎么办？

**A:** 检查以下几点：
1. 网络连接是否正常
2. baseUrl是否正确
3. 服务器是否可达

```dart
try {
  await XBoardSDK.instance.initialize('https://your-domain.com');
} on ConfigException catch (e) {
  print('配置错误: ${e.message}');
  // 检查URL格式
} on NetworkException catch (e) {
  print('网络错误: ${e.message}');
  // 检查网络连接
}
```

### Q2: Token自动刷新失败怎么处理？

**A:** 配置Token过期回调：

```dart
final config = TokenStorageConfig.custom(
  onTokenExpired: () {
    // 跳转到登录页面
    Navigator.pushNamedAndRemoveUntil(
      context, 
      '/login', 
      (route) => false
    );
  },
  onRefreshFailed: (error) {
    print('Token刷新失败: $error');
    // 清除本地状态并跳转登录
  },
);
```

### Q3: 如何处理网络超时？

**A:** SDK已内置超时配置，如需自定义：

```dart
// 可以通过HTTP服务访问Dio配置
XBoardSDK.instance.httpService.dio.options.connectTimeout = Duration(seconds: 10);
XBoardSDK.instance.httpService.dio.options.receiveTimeout = Duration(seconds: 30);
```

### Q4: 如何在不同环境使用不同配置？

**A:** 使用环境变量：

```dart
class Environment {
  static const String baseUrl = String.fromEnvironment(
    'XBOARD_BASE_URL',
    defaultValue: 'https://dev.xboard.com'
  );
}

// 使用方式
await XBoardSDK.instance.initialize(Environment.baseUrl);
```

### Q5: 数据模型序列化错误怎么办？

**A:** 检查API响应格式是否符合预期：

```dart
try {
  final response = await XBoardSDK.instance.userInfo.getUserInfo();
} on FormatException catch (e) {
  print('数据格式错误: $e');
  // API响应格式可能发生变化
} catch (e) {
  print('解析错误: $e');
}
```

---

## 📞 技术支持

### 获取帮助
- 查看[API文档](./README.md)
- 查看[测试报告](./TEST_REPORT.md)
- 查看[更新日志](./CHANGELOG.md)

### 问题反馈
如果遇到问题，请提供以下信息：
1. Flutter版本
2. SDK版本
3. 错误日志
4. 复现步骤
5. 设备/平台信息

---

## 🎉 总结

XBoard Flutter SDK 提供了完整的XBoard API集成方案，包括：

✅ **完整的认证系统** - 登录、注册、重置密码  
✅ **自动Token管理** - 自动刷新、安全存储  
✅ **类型安全** - 完整的类型定义  
✅ **错误处理** - 分层异常体系  
✅ **生产就绪** - 经过完整测试  

开始集成吧！🚀