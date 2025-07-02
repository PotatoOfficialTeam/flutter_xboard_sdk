# XBoard SDK 订单功能

## 概述

基于原有的 p2hiddify 项目中的订单实现，我们已成功将订单管理API功能集成到 XBoard SDK 中。此功能提供了完整的电商订单流程，包括套餐浏览、订单创建、支付处理等。

## 新增文件

### 模型文件
- `lib/src/models/order_models.dart` - 订单相关的数据模型

### 服务文件  
- `lib/src/services/order_service.dart` - 订单服务API接口

### 测试文件
- `test/order_test.dart` - 订单功能完整测试示例
- `validate_order_api.dart` - 模型验证脚本

## 功能特性

### 1. 核心数据模型

#### Order (订单模型)
```dart
class Order {
  final int? planId;               // 套餐计划ID
  final String? tradeNo;           // 订单号
  final double? totalAmount;       // 订单总金额
  final String? period;            // 订阅周期
  final int? status;               // 订单状态
  final int? createdAt;            // 创建时间戳
  final OrderPlan? orderPlan;      // 关联的套餐信息
  
  // 辅助方法
  bool get isPending;              // 是否待支付
  bool get isPaid;                 // 是否已支付
  bool get isCancelled;            // 是否已取消
  String get statusDescription;    // 状态描述
  DateTime? get createdDateTime;   // 创建时间
}
```

#### Plan (套餐计划模型)
```dart
class Plan {
  final int id;                    // 套餐ID
  final int groupId;               // 分组ID
  final double transferEnable;     // 流量配额（字节）
  final String name;               // 套餐名称
  final int speedLimit;            // 速度限制
  final bool show;                 // 是否显示
  final String? content;           // 套餐描述
  final double? monthPrice;        // 月价格
  final double? quarterPrice;      // 季价格
  final double? halfYearPrice;     // 半年价格
  final double? yearPrice;         // 年价格
  final double? twoYearPrice;      // 两年价格
  final double? threeYearPrice;    // 三年价格
  
  // 辅助方法
  double get transferEnableGB;     // 流量配额（GB）
  double? getPriceForPeriod(String period); // 获取指定周期价格
}
```

#### PaymentMethod (支付方式模型)
```dart
class PaymentMethod {
  final String id;                 // 支付方式ID
  final String name;               // 支付方式名称
  final String? icon;              // 图标URL
  final bool isAvailable;          // 是否可用
  final Map<String, dynamic>? config; // 配置信息
}
```

### 2. 请求/响应模型

#### CreateOrderRequest (创建订单请求)
```dart
class CreateOrderRequest {
  final int planId;                // 套餐ID
  final String period;             // 订阅周期
  final String? couponCode;        // 优惠券代码
}
```

#### PaymentResponse (支付响应)
```dart
class PaymentResponse {
  final List<PaymentMethod> paymentMethods; // 可用支付方式
  final String tradeNo;                     // 订单号
}
```

#### OrderResponse (订单列表响应)
```dart
class OrderResponse {
  final List<Order> orders;        // 订单列表
  final int? total;                // 总数量
  
  // 便捷访问
  List<Order> get pendingOrders;   // 待支付订单
  List<Order> get paidOrders;      // 已支付订单
}
```

### 3. API接口

#### 基础订单操作
```dart
// 获取用户订单列表
Future<OrderResponse> fetchUserOrders();

// 创建订单
Future<Map<String, dynamic>> createOrder({
  required int planId,
  required String period,
  String? couponCode,
});

// 取消订单
Future<Map<String, dynamic>> cancelOrder(String tradeNo);

// 获取订单详情
Future<Map<String, dynamic>> getOrderDetails(String tradeNo);

// 提交支付
Future<Map<String, dynamic>> submitPayment({
  required String tradeNo,
  required String method,
});
```

#### 套餐管理
```dart
// 获取所有套餐计划
Future<PlanResponse> fetchPlans();

// 获取套餐详情
Future<Plan?> getPlanDetails(int planId);

// 获取可用套餐
Future<List<Plan>> getAvailablePlans();
```

#### 支付管理
```dart
// 获取支付方式
Future<List<PaymentMethod>> getPaymentMethods();
```

#### 高级功能
```dart
// 获取待支付订单
Future<List<Order>> getPendingOrders();

// 获取已支付订单
Future<List<Order>> getPaidOrders();

// 批量取消待支付订单
Future<int> cancelPendingOrders();

// 根据订单号查找订单
Future<Order?> findOrderByTradeNo(String tradeNo);

// 处理完整订阅流程
Future<PaymentResponse> handleSubscription({
  required int planId,
  required String period,
  String? couponCode,
});
```

## 使用示例

### 1. 浏览套餐
```dart
// 初始化SDK
await XBoardSDK.instance.initialize('https://your-domain.com');
XBoardSDK.instance.setAuthToken('your_token');

// 获取可用套餐
final plans = await XBoardSDK.instance.order.getAvailablePlans();
for (final plan in plans) {
  print('${plan.name}: ${plan.monthPrice}元/月');
  print('流量: ${plan.transferEnableGB.toStringAsFixed(1)} GB');
}
```

### 2. 创建订单并支付
```dart
// 处理完整订阅流程
final paymentResponse = await XBoardSDK.instance.order.handleSubscription(
  planId: 1,
  period: 'month',
  couponCode: 'DISCOUNT20',
);

// 显示支付方式
print('可用支付方式:');
for (final method in paymentResponse.paymentMethods) {
  print('• ${method.name}');
}

// 提交支付
final result = await XBoardSDK.instance.order.submitPayment(
  tradeNo: paymentResponse.tradeNo,
  method: 'alipay',
);
```

### 3. 订单管理
```dart
// 获取所有订单
final orders = await XBoardSDK.instance.order.fetchUserOrders();
print('总订单数: ${orders.orders.length}');
print('待支付: ${orders.pendingOrders.length}个');
print('已支付: ${orders.paidOrders.length}个');

// 取消待支付订单
final canceledCount = await XBoardSDK.instance.order.cancelPendingOrders();
print('已取消${canceledCount}个待支付订单');

// 查找特定订单
final order = await XBoardSDK.instance.order.findOrderByTradeNo('ORDER123');
if (order != null) {
  print('订单状态: ${order.statusDescription}');
  print('创建时间: ${order.createdDateTime}');
}
```

### 4. 错误处理
```dart
try {
  final paymentResponse = await XBoardSDK.instance.order.handleSubscription(
    planId: 1,
    period: 'month',
  );
  // 处理成功
} catch (e) {
  if (e.toString().contains('unauthorized')) {
    print('认证失败，请重新登录');
  } else if (e.toString().contains('insufficient')) {
    print('余额不足，请充值');
  } else {
    print('订单创建失败: $e');
  }
}
```

## 订单状态说明

| 状态码 | 状态描述 | 说明 |
|--------|----------|------|
| 0 | 待支付 | 订单已创建但未支付 |
| 1 | 已开通 | 订单已支付并激活服务 |
| 2 | 已取消 | 订单已被取消 |
| 3 | 已完成 | 订单已完成 |
| 4 | 已折抵 | 订单已用于折抵 |

## 支付周期说明

| 周期标识 | 说明 |
|----------|------|
| `onetime` | 一次性付费 |
| `month` | 月付 |
| `quarter` | 季付（3个月） |
| `half_year` | 半年付（6个月） |
| `year` | 年付（12个月） |
| `two_year` | 两年付（24个月） |
| `three_year` | 三年付（36个月） |

## 原始API支持

除了结构化的API外，SDK还提供原始API访问：

```dart
// 获取原始订单数据
final rawOrders = await XBoardSDK.instance.order.fetchUserOrdersRaw();

// 获取原始套餐数据
final rawPlans = await XBoardSDK.instance.order.fetchPlansRaw();

// 获取原始支付方式数据
final rawMethods = await XBoardSDK.instance.order.getPaymentMethodsRaw();
```

## 集成要点

1. **认证要求**: 所有订单API都需要有效的认证Token
2. **错误处理**: 建议使用try-catch处理网络和业务异常
3. **数据验证**: 所有模型都包含完整的JSON序列化/反序列化
4. **类型安全**: 使用强类型模型确保数据一致性
5. **缓存策略**: 可以缓存套餐列表等相对静态的数据

## 测试验证

运行测试以验证功能：

```bash
# 运行模型验证
dart validate_order_api.dart

# 运行完整测试（需要网络连接）
dart test/order_test.dart
```

## 依赖的API端点

- `GET /api/v1/user/order/fetch` - 获取用户订单
- `POST /api/v1/user/order/save` - 创建订单
- `POST /api/v1/user/order/cancel` - 取消订单
- `GET /api/v1/user/order/detail` - 获取订单详情
- `GET /api/v1/user/plan/fetch` - 获取套餐计划
- `GET /api/v1/user/order/getPaymentMethod` - 获取支付方式
- `POST /api/v1/user/payment/submit` - 提交支付

这些API端点都遵循XBoard的标准接口规范，确保与现有系统的兼容性。 