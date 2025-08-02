# XBoard SDK API 参考文档

## 📚 目录
- [SDK 主类](#sdk-主类)
- [认证相关 API](#认证相关-api)
- [用户信息 API](#用户信息-api)
- [订阅管理 API](#订阅管理-api)
- [余额管理 API](#余额管理-api)
- [套餐管理 API](#套餐管理-api)
- [订单管理 API](#订单管理-api)
- [优惠券 API](#优惠券-api)
- [支付相关 API](#支付相关-api)
- [系统配置 API](#系统配置-api)
- [数据模型](#数据模型)
- [异常类型](#异常类型)

---

## 🔧 SDK 主类

### XBoardSDK

XBoard SDK 的主入口类，提供单例模式访问。

#### 属性

```dart
class XBoardSDK {
  // 获取SDK单例实例
  static XBoardSDK get instance;
  
  // 检查SDK是否已初始化
  bool get isInitialized;
  
  // 检查用户是否已认证
  bool get isAuthenticated;
  
  // 获取当前认证状态
  AuthState get authState;
  
  // 认证状态变化流
  Stream<AuthState> get authStateStream;
  
  // 获取基础URL
  String? get baseUrl;
  
  // 获取HTTP服务实例（高级用法）
  HttpService get httpService;
  
  // 获取Token管理器实例（高级用法）
  TokenManager get tokenManager;
}
```

#### 方法

```dart
// 初始化SDK
Future<void> initialize(
  String baseUrl, {
  TokenStorageConfig? tokenConfig,
});

// 保存Token信息
Future<void> saveTokens({
  required String accessToken,
  required String refreshToken,
  required DateTime expiry,
});

// 获取当前认证Token
Future<String?> getAuthToken();

// 清除所有Token
Future<void> clearTokens();

// 检查Token是否有效
Future<bool> isTokenValid();

// 手动刷新Token
Future<String?> refreshToken();

// 便捷登录方法
Future<bool> loginWithCredentials(String email, String password);

// 释放SDK资源
void dispose();

// 已废弃的方法（向后兼容）
@Deprecated('Use saveTokens instead')
void setAuthToken(String token);

@Deprecated('Use clearTokens instead')
void clearAuthToken();
```

#### 服务访问器

```dart
// 认证相关
LoginApi get login;
RegisterApi get register;
SendEmailCodeApi get sendEmailCode;
ResetPasswordApi get resetPassword;
RefreshTokenApi get refreshTokenApi;

// 用户和订阅
UserInfoApi get userInfo;
SubscriptionApi get subscription;

// 商业功能
PlanApi get plan;
OrderApi get orderApi;
PaymentApi get payment;
BalanceApi get balanceApi;
CouponApi get couponApi;

// 系统功能
ConfigApi get config;
NoticeApi get noticeApi;
TicketApi get ticket;
InviteApi get inviteApi;
AppApi get appApi;
```

---

## 🔐 认证相关 API

### LoginApi

用户登录功能。

```dart
// 用户登录
Future<ApiResponse<LoginData>> login(String email, String password);
```

**参数：**
- `email`: 用户邮箱
- `password`: 用户密码

**返回：** `ApiResponse<LoginData>`

**示例：**
```dart
final response = await XBoardSDK.instance.login.login(
  'user@example.com',
  'password123'
);

if (response.success && response.data != null) {
  print('登录成功: ${response.data!.token}');
}
```

### RegisterApi

用户注册功能。

```dart
// 用户注册
Future<ApiResponse<RegisterData>> register({
  required String email,
  required String password,
  required String emailCode,
  String? inviteCode,
});
```

**参数：**
- `email`: 用户邮箱
- `password`: 用户密码
- `emailCode`: 邮箱验证码
- `inviteCode`: 邀请码（可选）

### SendEmailCodeApi

发送邮箱验证码。

```dart
// 发送邮箱验证码
Future<ApiResponse<SendEmailCodeData>> sendEmailCode(String email);
```

### ResetPasswordApi

重置密码功能。

```dart
// 重置密码
Future<ApiResponse<void>> resetPassword({
  required String email,
  required String password,
  required String emailCode,
});
```

### RefreshTokenApi

Token刷新功能。

```dart
// 刷新Token
Future<ApiResponse<dynamic>> refreshToken();
```

---

## 👤 用户信息 API

### UserInfoApi

获取用户信息。

```dart
// 获取用户详细信息
Future<ApiResponse<UserInfo>> getUserInfo();
```

**返回：** `ApiResponse<UserInfo>`

**示例：**
```dart
final response = await XBoardSDK.instance.userInfo.getUserInfo();

if (response.success && response.data != null) {
  final user = response.data!;
  print('用户邮箱: ${user.email}');
  print('余额: ${user.balance}');
  print('到期时间: ${user.expiredAt}');
}
```

---

## 📡 订阅管理 API

### SubscriptionApi

订阅信息管理。

```dart
// 获取订阅信息
Future<ApiResponse<SubscriptionInfo>> getSubscriptionInfo();

// 重置订阅链接
Future<ApiResponse<void>> resetSubscription();
```

**示例：**
```dart
// 获取订阅信息
final response = await XBoardSDK.instance.subscription.getSubscriptionInfo();
if (response.success && response.data != null) {
  final subscription = response.data!;
  print('订阅链接: ${subscription.subscribeUrl}');
  print('已用流量: ${subscription.usedTraffic}');
  print('总流量: ${subscription.totalTraffic}');
}

// 重置订阅
final resetResponse = await XBoardSDK.instance.subscription.resetSubscription();
if (resetResponse.success) {
  print('订阅链接已重置');
}
```

---

## 💰 余额管理 API

### BalanceApi

余额和佣金管理。

```dart
// 获取用户信息（包含余额）
Future<ApiResponse<UserInfo>> getUserInfo();

// 佣金转账到余额
Future<ApiResponse<TransferResult>> transferCommission(int transferAmount);

// 申请提现
Future<ApiResponse<WithdrawResult>> withdrawFunds(
  String withdrawMethod,
  String withdrawAccount,
);

// 检查是否可以提现
Future<bool> canWithdraw();

// 获取支持的提现方式
Future<List<String>> getWithdrawMethods();

// 获取提现历史
Future<Map<String, dynamic>> getWithdrawHistory({
  int page = 1,
  int pageSize = 20,
});

// 获取佣金历史
Future<Map<String, dynamic>> getCommissionHistory({
  int page = 1,
  int pageSize = 20,
});
```

**示例：**
```dart
// 转移佣金（金额以分为单位）
final transferResult = await XBoardSDK.instance.balanceApi.transferCommission(1000); // 10.00元
if (transferResult.success) {
  print('转移成功: ${transferResult.message}');
}

// 申请提现
final withdrawResult = await XBoardSDK.instance.balanceApi.withdrawFunds(
  'alipay',
  'your_account@example.com'
);
if (withdrawResult.success) {
  print('提现申请已提交: ${withdrawResult.withdrawId}');
}
```

---

## 📦 套餐管理 API

### PlanApi

套餐信息管理。

```dart
// 获取可用套餐列表
Future<ApiResponse<List<Plan>>> getPlans();

// 获取指定套餐详情
Future<ApiResponse<Plan>> getPlan(int planId);
```

**示例：**
```dart
final response = await XBoardSDK.instance.plan.getPlans();
if (response.success && response.data != null) {
  for (final plan in response.data!) {
    print('套餐: ${plan.name} - 价格: ${plan.price}');
  }
}
```

---

## 🛒 订单管理 API

### OrderApi

订单相关操作。

```dart
// 获取订单列表
Future<ApiResponse<List<Order>>> getOrders({
  int page = 1,
  int pageSize = 20,
});

// 获取指定订单详情
Future<ApiResponse<Order>> getOrder(int orderId);

// 创建订单
Future<ApiResponse<Order>> createOrder({
  required int planId,
  int? period,
  String? couponCode,
});

// 取消订单
Future<ApiResponse<void>> cancelOrder(int orderId);
```

---

## 🎫 优惠券 API

### CouponApi

优惠券管理。

```dart
// 验证优惠券
Future<ApiResponse<Coupon>> checkCoupon(String code, int planId);

// 获取可用优惠券列表
Future<ApiResponse<List<Coupon>>> getAvailableCoupons({int? planId});

// 获取优惠券使用历史
Future<Map<String, dynamic>> getCouponHistory({
  int page = 1,
  int pageSize = 20,
});
```

**示例：**
```dart
// 验证优惠券
final response = await XBoardSDK.instance.couponApi.checkCoupon('SAVE20', 123);
if (response.success && response.data != null) {
  final coupon = response.data!;
  print('优惠券: ${coupon.name}');
  print('折扣类型: ${coupon.type}'); // 1: 金额折扣, 2: 百分比折扣
  print('折扣值: ${coupon.value}');
}
```

---

## 💳 支付相关 API

### PaymentApi

支付功能管理。

```dart
// 获取支付方式列表
Future<ApiResponse<List<PaymentMethod>>> getPaymentMethods();

// 创建支付订单
Future<ApiResponse<PaymentOrder>> createPaymentOrder({
  required int orderId,
  required String paymentMethod,
});

// 查询支付状态
Future<ApiResponse<PaymentStatus>> getPaymentStatus(String paymentId);
```

---

## ⚙️ 系统配置 API

### ConfigApi

系统配置信息。

```dart
// 获取系统配置
Future<ApiResponse<SystemConfig>> getConfig();
```

### AppApi

应用信息接口。

```dart
// 获取应用信息
Future<ApiResponse<AppInfo>> getAppInfo();
```

### NoticeApi

系统通知管理。

```dart
// 获取通知列表
Future<ApiResponse<List<Notice>>> getNotices({
  int page = 1,
  int pageSize = 20,
});

// 标记通知为已读
Future<ApiResponse<void>> markNoticeAsRead(int noticeId);
```

### TicketApi

工单系统。

```dart
// 获取工单列表
Future<ApiResponse<List<Ticket>>> getTickets({
  int page = 1,
  int pageSize = 20,
});

// 创建工单
Future<ApiResponse<Ticket>> createTicket({
  required String subject,
  required String message,
  int? level,
});

// 回复工单
Future<ApiResponse<void>> replyTicket({
  required int ticketId,
  required String message,
});

// 关闭工单
Future<ApiResponse<void>> closeTicket(int ticketId);
```

### InviteApi

邀请系统。

```dart
// 获取邀请信息
Future<ApiResponse<InviteInfo>> getInviteInfo();

// 获取邀请历史
Future<ApiResponse<List<InviteRecord>>> getInviteHistory({
  int page = 1,
  int pageSize = 20,
});
```

---

## 📊 数据模型

### 认证相关模型

```dart
// 登录数据
@freezed
class LoginData with _$LoginData {
  const factory LoginData({
    String? token,
    String? authData,
    bool? isAdmin,
  }) = _LoginData;
}

// 注册数据
@freezed
class RegisterData with _$RegisterData {
  const factory RegisterData({
    String? token,
    String? message,
  }) = _RegisterData;
}

// 发送验证码数据
@freezed
class SendEmailCodeData with _$SendEmailCodeData {
  const factory SendEmailCodeData({
    String? message,
  }) = _SendEmailCodeData;
}
```

### 用户信息模型

```dart
@freezed
class UserInfo with _$UserInfo {
  const factory UserInfo({
    required String email,
    required double transferEnable,
    int? lastLoginAt,
    required int createdAt,
    required bool banned,
    required bool remindExpire,
    required bool remindTraffic,
    int? expiredAt,
    required double balance,           // 余额（分为单位）
    required double commissionBalance, // 佣金（分为单位）
    required int planId,
    double? discount,
    double? commissionRate,
    String? telegramId,
    required String uuid,
    required String avatarUrl,
  }) = _UserInfo;
  
  // 便捷的单位转换
  double get balanceInYuan => balance / 100;
  double get commissionBalanceInYuan => commissionBalance / 100;
  double get totalBalanceInYuan => balanceInYuan + commissionBalanceInYuan;
}
```

### 订阅信息模型

```dart
@freezed
class SubscriptionInfo with _$SubscriptionInfo {
  const factory SubscriptionInfo({
    required String subscribeUrl,
    required String token,
    required double usedTraffic,
    required double totalTraffic,
    int? expiredAt,
  }) = _SubscriptionInfo;
  
  // 便捷属性
  double get remainingTraffic => totalTraffic - usedTraffic;
  double get usagePercentage => totalTraffic > 0 ? (usedTraffic / totalTraffic) * 100 : 0;
}
```

### 套餐模型

```dart
@freezed
class Plan with _$Plan {
  const factory Plan({
    required int id,
    required String name,
    required String content,
    required double price,
    required int trafficLimit,
    int? speedLimit,
    required bool show,
    required bool renew,
    int? resetTrafficMethod,
  }) = _Plan;
}
```

### 订单模型

```dart
@freezed
class Order with _$Order {
  const factory Order({
    required int id,
    required int userId,
    required int planId,
    required double totalAmount,
    required int status,
    int? createdAt,
    int? updatedAt,
  }) = _Order;
}
```

### 余额相关模型

```dart
// 转账结果
@freezed
class TransferResult with _$TransferResult {
  const factory TransferResult({
    required bool success,
    String? message,
    UserInfo? updatedUserInfo,
  }) = _TransferResult;
}

// 提现结果
@freezed
class WithdrawResult with _$WithdrawResult {
  const factory WithdrawResult({
    required bool success,
    String? message,
    String? withdrawId,
  }) = _WithdrawResult;
}
```

### 系统配置模型

```dart
@freezed
class SystemConfig with _$SystemConfig {
  const factory SystemConfig({
    required List<String> withdrawMethods,
    required bool withdrawEnabled,
    required String currency,
    required String currencySymbol,
  }) = _SystemConfig;
}
```

### 通用响应模型

```dart
@freezed
class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse({
    required bool success,
    String? message,
    T? data,
    int? total,
  }) = _ApiResponse<T>;
}
```

---

## ⚠️ 异常类型

### XBoardException 基类

```dart
abstract class XBoardException implements Exception {
  final String message;
  final int? code;
  
  XBoardException(this.message, [this.code]);
}
```

### 具体异常类型

```dart
// 网络异常
class NetworkException extends XBoardException {
  NetworkException(String message, [int? code]) : super(message, code);
}

// 认证异常
class AuthException extends XBoardException {
  AuthException(String message, [int? code]) : super(message, code);
}

// API异常
class ApiException extends XBoardException {
  ApiException(String message, [int? code]) : super(message, code);
}

// 配置异常
class ConfigException extends XBoardException {
  ConfigException(String message, [int? code]) : super(message, code);
}

// 参数异常
class ParameterException extends XBoardException {
  ParameterException(String message, [int? code]) : super(message, code);
}
```

### 异常处理示例

```dart
try {
  final response = await XBoardSDK.instance.userInfo.getUserInfo();
  // 处理成功响应
} on AuthException catch (e) {
  print('认证失败: ${e.message}');
  // 跳转到登录页面
} on NetworkException catch (e) {
  print('网络错误: ${e.message}');
  // 显示重试选项
} on ApiException catch (e) {
  print('API错误: ${e.message} (代码: ${e.code})');
  // 根据错误代码进行处理
} on XBoardException catch (e) {
  print('SDK错误: ${e.message}');
  // 通用错误处理
} catch (e) {
  print('未知错误: $e');
  // 兜底处理
}
```

---

## 🔧 Token 管理

### TokenStorageConfig

Token存储配置。

```dart
@freezed
class TokenStorageConfig with _$TokenStorageConfig {
  const factory TokenStorageConfig({
    required TokenStorage storage,
    @Default(Duration(minutes: 5)) Duration refreshBuffer,
    @Default(true) bool autoRefresh,
    VoidCallback? onTokenExpired,
    void Function(dynamic error)? onRefreshFailed,
  }) = _TokenStorageConfig;
  
  // 预定义配置
  factory TokenStorageConfig.defaultConfig() = _TokenStorageConfig;
  factory TokenStorageConfig.production() = _TokenStorageConfig;
}
```

### AuthState 枚举

```dart
enum AuthState {
  unauthenticated,  // 未认证
  authenticated,    // 已认证
  refreshing,       // 正在刷新Token
  expired,          // Token已过期
}
```

这份API参考文档涵盖了XBoard SDK的所有公开接口，可以作为开发时的参考手册使用。