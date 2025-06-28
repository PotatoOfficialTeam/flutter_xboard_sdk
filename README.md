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

### 单元测试

运行基础的单元测试：

```bash
flutter test test/flutter_xboard_sdk_test.dart
```

### 集成测试

**⚠️ 重要提示：集成测试会连接真实的XBoard API，需要有效的测试账号**

#### 步骤1：设置环境变量

**macOS/Linux:**
```bash
export XBOARD_BASE_URL="https://your-xboard-domain.com"
export XBOARD_TEST_EMAIL="your-test@example.com"
export XBOARD_TEST_PASSWORD="your_test_password"
export XBOARD_TEST_INVITE_CODE="your_invite_code"  # 可选
```

**Windows:**
```cmd
set XBOARD_BASE_URL=https://your-xboard-domain.com
set XBOARD_TEST_EMAIL=your-test@example.com
set XBOARD_TEST_PASSWORD=your_test_password
set XBOARD_TEST_INVITE_CODE=your_invite_code
```

#### 步骤2：运行集成测试

```bash
# 使用Flutter命令
flutter test test/integration_test.dart

# 或使用提供的脚本（推荐）
./scripts/run_integration_test.sh
```

#### 集成测试内容

- ✅ 真实API登录测试
- ✅ 邮箱验证码发送测试
- ✅ Token刷新功能测试
- ✅ 退出登录测试
- ✅ API错误处理测试
- ✅ 性能基准测试

#### 测试输出示例

```
🚀 XBoard SDK 集成测试
======================
✅ 环境变量检查通过
📍 Base URL: https://demo.xboard.com
📧 Test Email: test@example.com
🔑 Password: ************

🔐 开始测试用户登录...
📄 登录响应: {success: true, data: {token: eyJ...}}
✅ 登录成功！
🔑 Token已设置: eyJhbGciOiJIUzI1NiIs...
👤 用户信息:
  ID: 123
  Email: test@example.com
  余额: 10000
  佣金余额: 500

📧 开始测试发送验证码...
✅ 验证码发送成功！

🎉 集成测试完成！
```

### 安全注意事项

- 🚨 **绝对不要**将真实的生产环境凭据提交到代码仓库
- 🧪 建议创建专门的测试账号用于集成测试
- 🔐 环境变量文件 `.env` 已被添加到 `.gitignore` 中
- 📝 可以复制 `.env.example` 文件来创建本地配置

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
- 🆕 添加集成测试支持

## ✨ 主要功能

### 🔐 认证功能
- **用户登录**: 支持邮箱/密码登录
- **用户注册**: 新用户注册功能  
- **验证码**: 发送和验证邮箱验证码
- **密码重置**: 通过验证码重置密码
- **Token管理**: 自动处理认证令牌

### 📱 订阅管理
- **获取订阅链接**: 获取用户专属订阅链接
- **重置订阅**: 重置订阅链接和安全信息
- **订阅统计**: 查看订阅使用统计数据
- **缓存机制**: 自动缓存订阅信息提升性能

### 💰 余额管理
- **余额查询**: 获取用户余额和佣金信息
- **佣金转账**: 将佣金转移到可用余额
- **提现申请**: 申请资金提现
- **系统配置**: 获取提现规则和系统设置
- **交易历史**: 查看提现和佣金历史记录

### 🛡️ 安全特性
- **类型安全**: 完整的TypeScript式类型定义
- **异常处理**: 完善的错误处理和异常捕获
- **数据验证**: 输入数据格式验证
- **安全传输**: HTTPS加密通信

### 🧪 测试支持
- **单元测试**: 完整的核心功能单元测试
- **集成测试**: 真实API环境集成测试
- **模拟数据**: 支持测试环境和生产环境

### 🎫 优惠券管理
- **优惠券验证**: 验证优惠码有效性和适用性
- **可用优惠券**: 获取用户可用的优惠券列表
- **使用历史**: 查看优惠券使用记录
- **纯数据API**: 只提供API调用，业务逻辑由应用层实现

## 🚀 快速开始

### 1. 添加依赖

在你的 `pubspec.yaml` 文件中添加：

```yaml
dependencies:
  flutter_xboard_sdk:
    path: ./path/to/flutter_xboard_sdk
```

### 2. 导入SDK

```dart
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';
```

### 3. 初始化SDK

```dart
void main() async {
  // 初始化SDK
  await XBoardSDK.instance.initialize('https://your-xboard-domain.com');
  
  runApp(MyApp());
}
```

## 📖 使用指南

### 认证功能

```dart
// 用户登录
final loginResult = await XBoardSDK.instance.auth.login(
  'user@example.com', 
  'password'
);

if (loginResult.success) {
  // 设置认证令牌
  XBoardSDK.instance.setAuthToken(loginResult.data!.token);
  print('登录成功: ${loginResult.data!.user?.email}');
} else {
  print('登录失败: ${loginResult.message}');
}

// 发送验证码
final codeResult = await XBoardSDK.instance.auth.sendVerificationCode(
  'user@example.com'
);

// 用户注册
final registerResult = await XBoardSDK.instance.auth.register(
  'user@example.com',
  'password',
  '123456', // 验证码
  'inviteCode' // 可选的邀请码
);
```

### 订阅管理

```dart
// 获取订阅信息
final subscriptionInfo = await XBoardSDK.instance.subscription.getSubscriptionInfo();
print('订阅链接: ${subscriptionInfo.subscribeUrl}');

// 重置订阅链接
final resetResult = await XBoardSDK.instance.subscription.resetSubscription();
if (resetResult.success) {
  print('订阅链接已重置');
}

// 获取订阅统计
final stats = await XBoardSDK.instance.subscription.getSubscriptionStats();
print('总流量: ${stats.totalTraffic}');
print('已用流量: ${stats.usedTraffic}');
```

### 余额管理

```dart
// 获取系统配置
final config = await XBoardSDK.instance.balance.getSystemConfig();
print('系统货币: ${config.currency}');
print('提现开启: ${config.withdrawEnabled}');
print('最小提现金额: ${config.minWithdrawAmount}');

// 获取余额信息
final balanceInfo = await XBoardSDK.instance.balance.getBalanceInfo();
print('当前余额: ${balanceInfo.balance}');
print('佣金余额: ${balanceInfo.commissionBalance}');

// 转移佣金到余额
final transferResult = await XBoardSDK.instance.balance.transferCommission(1000); // 10.00元 (分为单位)
if (transferResult.success) {
  print('佣金转移成功: ${transferResult.message}');
  print('新余额: ${transferResult.newBalance}');
}

// 申请提现
final withdrawResult = await XBoardSDK.instance.balance.withdrawFunds(
  'alipay', // 提现方式
  'your_alipay_account@example.com' // 提现账户
);
if (withdrawResult.success) {
  print('提现申请成功: ${withdrawResult.withdrawId}');
}

// 获取提现历史
final withdrawHistory = await XBoardSDK.instance.balance.getWithdrawHistory(
  page: 1,
  pageSize: 20
);
if (withdrawHistory['success']) {
  print('提现记录数量: ${withdrawHistory['data'].length}');
}

// 获取佣金历史
final commissionHistory = await XBoardSDK.instance.balance.getCommissionHistory(
  page: 1,
  pageSize: 20
);
if (commissionHistory['success']) {
  print('佣金记录数量: ${commissionHistory['data'].length}');
}
```

### 优惠券管理

```dart
// 验证优惠券
final response = await XBoardSDK.instance.coupon.checkCoupon('SAVE20', 123);
if (response.success && response.data != null) {
  final coupon = response.data!;
  print('优惠券名称: ${coupon.name}');
  print('折扣类型: ${coupon.type}'); // 1: 金额折扣, 2: 百分比折扣
  print('折扣值: ${coupon.value}');
  
  // 应用层计算折扣逻辑（SDK不包含业务逻辑）
  if (coupon.type == 1) {
    print('减免金额: ¥${coupon.value}');
  } else if (coupon.type == 2) {
    print('折扣比例: ${coupon.value}%');
  }
}

// 获取可用优惠券列表
final availableCoupons = await XBoardSDK.instance.coupon.getAvailableCoupons(planId: 123);
if (availableCoupons.success && availableCoupons.data != null) {
  print('可用优惠券数量: ${availableCoupons.data!.length}');
  for (final coupon in availableCoupons.data!) {
    print('- ${coupon.code}: ${coupon.name}');
  }
}

// 获取优惠券使用历史
final history = await XBoardSDK.instance.coupon.getCouponHistory(page: 1, pageSize: 20);
if (history['success']) {
  print('使用记录数量: ${history['data'].length}');
}
```

### 异常处理

```dart
try {
  final result = await XBoardSDK.instance.auth.login('user@example.com', 'password');
  // 处理结果
} on AuthException catch (e) {
  print('认证异常: ${e.message}');
} on NetworkException catch (e) {
  print('网络异常: ${e.message}');
} on XBoardException catch (e) {
  print('SDK异常: ${e.message}');
} catch (e) {
  print('未知异常: $e');
}
```

## 📊 API 参考

### XBoardSDK 主类

```dart
class XBoardSDK {
  // 获取SDK单例
  static XBoardSDK get instance;
  
  // 初始化SDK
  Future<void> initialize(String baseUrl);
  
  // 设置认证Token
  void setAuthToken(String token);
  
  // 获取认证Token
  String? getAuthToken();
  
  // 清除认证Token
  void clearAuthToken();
  
  // 服务访问器
  AuthService get auth;           // 认证服务
  SubscriptionService get subscription;  // 订阅服务
  BalanceService get balance;     // 余额服务
  
  // 状态检查
  bool get isInitialized;
  String? get baseUrl;
}
```

### AuthService 认证服务

```dart
class AuthService {
  // 用户登录
  Future<ApiResponse<LoginResponse>> login(String email, String password);
  
  // 用户注册
  Future<ApiResponse<LoginResponse>> register(String email, String password, String verificationCode, [String? inviteCode]);
  
  // 发送验证码
  Future<ApiResponse<VerificationCodeResponse>> sendVerificationCode(String email);
  
  // 重置密码
  Future<ApiResponse<void>> resetPassword(String email, String newPassword, String verificationCode);
}
```

### SubscriptionService 订阅服务

```dart
class SubscriptionService {
  // 获取订阅信息
  Future<SubscriptionInfo> getSubscriptionInfo();
  
  // 重置订阅
  Future<ApiResponse<void>> resetSubscription();
  
  // 获取订阅统计
  Future<SubscriptionStats> getSubscriptionStats();
}
```

### BalanceService 余额服务

```dart
class BalanceService {
  // 获取系统配置
  Future<SystemConfig> getSystemConfig();
  
  // 获取余额信息
  Future<BalanceInfo> getBalanceInfo();
  
  // 佣金转账
  Future<TransferResult> transferCommission(int transferAmount);
  
  // 申请提现
  Future<WithdrawResult> withdrawFunds(String withdrawMethod, String withdrawAccount);
  
  // 获取提现历史
  Future<Map<String, dynamic>> getWithdrawHistory({int page = 1, int pageSize = 20});
  
  // 获取佣金历史
  Future<Map<String, dynamic>> getCommissionHistory({int page = 1, int pageSize = 20});
}
```

### 数据模型

#### 系统配置模型

```dart
class SystemConfig {
  final String? currency;              // 系统货币
  final bool withdrawEnabled;          // 提现是否开启
  final int? minWithdrawAmount;        // 最小提现金额
  final int? maxWithdrawAmount;        // 最大提现金额
  final double? withdrawFeeRate;       // 提现手续费率
  final List<String>? withdrawMethods; // 支持的提现方式
  final String? withdrawNotice;        // 提现须知
}
```

#### 余额信息模型

```dart
class BalanceInfo {
  final double? balance;            // 可用余额
  final double? commissionBalance;  // 佣金余额
  final double? totalBalance;       // 总余额
  final String? currency;           // 货币类型
}
```

#### 转账结果模型

```dart
class TransferResult {
  final bool success;           // 是否成功
  final String? message;        // 结果消息
  final double? newBalance;     // 转账后新余额
  final double? transferAmount; // 转账金额
}
```

#### 提现结果模型

```dart
class WithdrawResult {
  final bool success;         // 是否成功
  final String? message;      // 结果消息
  final String? withdrawId;   // 提现订单ID
  final String? status;       // 提现状态
}
```

#### 优惠券数据模型

```dart
class CouponData {
  final String? id;                // 优惠券ID
  final String? name;              // 优惠券名称
  final String? code;              // 优惠码
  final int? type;                 // 折扣类型 (1: 金额折扣, 2: 百分比折扣)
  final double? value;             // 折扣值
  final int? limitUse;             // 使用限制次数
  final int? limitUseWithUser;     // 单用户使用限制
  final DateTime? startedAt;       // 开始时间
  final DateTime? endedAt;         // 结束时间
  final bool? show;                // 是否显示
}
```

#### 优惠券响应模型

```dart
class CouponResponse {
  final bool success;              // 是否成功
  final String? message;           // 响应消息
  final CouponData? data;          // 优惠券数据
  final Map<String, dynamic>? errors; // 错误信息
}
```

#### 优惠券列表响应模型

```dart
class AvailableCouponsResponse {
  final bool success;              // 是否成功
  final String? message;           // 响应消息
  final List<CouponData>? data;    // 优惠券列表
  final int? total;                // 总数量
}
```

### CouponService 优惠券服务

```dart
class CouponService {
  // 验证优惠券
  Future<CouponResponse> checkCoupon(String code, int planId);
  
  // 获取可用优惠券列表
  Future<AvailableCouponsResponse> getAvailableCoupons({int? planId});
  
  // 获取优惠券使用历史
  Future<Map<String, dynamic>> getCouponHistory({int page = 1, int pageSize = 20});
}
```
