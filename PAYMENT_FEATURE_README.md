# XBoard SDK 支付功能说明

## 概述

XBoard SDK的支付模块提供了完整的支付流程管理功能，支持多种支付方式，包含支付状态管理、错误处理、轮询查询等高级功能。

## 核心功能

### 🔍 支付方式管理
- 获取可用支付方式列表
- 根据金额筛选支付方式
- 计算手续费和总金额
- 支付方式可用性检查

### 💳 支付流程管理
- 预检查支付条件
- 提交支付请求
- 处理支付结果（成功/重定向/失败/取消）
- 完整的支付工作流程

### 📊 支付状态管理
- 实时查询支付状态
- 自动轮询支付状态
- 支付状态变更通知
- 支付超时处理

### 📈 支付数据分析
- 支付历史记录查询
- 支付统计信息
- 支付趋势分析

## 数据模型

### PaymentMethodInfo - 支付方式信息
```dart
class PaymentMethodInfo {
  final String id;                    // 支付方式ID
  final String name;                  // 显示名称
  final double feePercent;            // 手续费百分比
  final String? icon;                 // 图标URL
  final bool isAvailable;             // 是否可用
  final String? description;          // 描述信息
  final double? minAmount;            // 最小支付金额
  final double? maxAmount;            // 最大支付金额
  
  // 辅助方法
  double calculateFee(double amount);           // 计算手续费
  double calculateTotalAmount(double amount);   // 计算总金额
  bool isAmountValid(double amount);            // 验证金额范围
}
```

### PaymentStatus - 支付状态枚举
```dart
enum PaymentStatus {
  initial,      // 初始状态
  processing,   // 处理中
  success,      // 支付成功
  failed,       // 支付失败
  canceled,     // 已取消
  pending,      // 等待确认
  timeout,      // 超时
}
```

### PaymentResult - 支付结果 (Sealed Class)
```dart
sealed class PaymentResult {
  // 支付成功
  PaymentResultSuccess(String? transactionId, String? message);
  
  // 需要重定向
  PaymentResultRedirect(String url, String? method);
  
  // 支付失败
  PaymentResultFailed(String message, String? errorCode);
  
  // 支付取消
  PaymentResultCanceled(String? message);
}
```

### PaymentError - 支付错误类型
```dart
sealed class PaymentError implements Exception {
  NoTokenError                      // 无认证令牌
  NetworkError                      // 网络错误
  InvalidResponseError              // 响应格式错误
  PreCheckError                     // 预检查失败
  UrlLaunchError                    // URL启动错误
  PaymentTimeoutError               // 支付超时
  InvalidAmountError                // 金额无效
  PaymentMethodUnavailableError     // 支付方式不可用
  UnknownError                      // 未知错误
}
```

## API接口

### 支付方式管理

#### 获取支付方式列表
```dart
Future<List<PaymentMethodInfo>> getPaymentMethods()
```

#### 获取适用支付方式
```dart
Future<List<PaymentMethodInfo>> getAvailablePaymentMethods(double amount)
```

#### 根据ID获取支付方式
```dart
Future<PaymentMethodInfo?> getPaymentMethodById(String methodId)
```

### 支付流程管理

#### 完整支付流程
```dart
Future<PaymentResult> processPayment({
  required String tradeNo,
  required String methodId,
  String? callbackUrl,
  Map<String, dynamic>? extra,
})
```

#### 提交支付请求
```dart
Future<PaymentResponse> submitOrderPayment(PaymentRequest request)
```

#### 预检查支付条件
```dart
Future<void> preCheckPayment(PaymentRequest request)
```

### 支付状态管理

#### 查询支付状态
```dart
Future<PaymentStatusResult> checkPaymentStatus(String tradeNo)
```

#### 轮询支付状态
```dart
Future<PaymentStatusResult> pollPaymentStatus({
  required String tradeNo,
  int maxAttempts = 60,
  int intervalSeconds = 3,
})
```

#### 取消支付
```dart
Future<bool> cancelPayment(String tradeNo)
```

### 工具方法

#### 计算总金额
```dart
Future<double> calculateTotalAmount(double amount, String methodId)
```

#### 验证支付金额
```dart
Future<bool> validatePaymentAmount(double amount, String methodId)
```

### 数据查询

#### 获取支付历史
```dart
Future<List<Map<String, dynamic>>> getPaymentHistory({
  int limit = 20,
  int offset = 0,
})
```

#### 获取支付统计
```dart
Future<Map<String, dynamic>> getPaymentStats()
```

## 使用示例

### 基础支付流程

```dart
// 1. 初始化SDK并设置认证
await XBoardSDK.instance.initialize('https://your-domain.com');
XBoardSDK.instance.setAuthToken('your_access_token');

final paymentService = XBoardSDK.instance.payment;

// 2. 获取支付方式
final paymentMethods = await paymentService.getPaymentMethods();
print('可用支付方式: ${paymentMethods.length} 种');

// 3. 选择支付方式并计算费用
final selectedMethod = paymentMethods.first;
final amount = 100.0;
final totalAmount = await paymentService.calculateTotalAmount(amount, selectedMethod.id);
print('支付总额: $totalAmount 元（含手续费）');

// 4. 创建订单（使用OrderService）
final order = await XBoardSDK.instance.order.createOrder(
  planId: 1,
  period: 'month',
);

// 5. 处理支付
final paymentResult = await paymentService.processPayment(
  tradeNo: order.tradeNo,
  methodId: selectedMethod.id,
  callbackUrl: 'https://your-app.com/payment-callback',
);

// 6. 处理支付结果
switch (paymentResult) {
  case PaymentResultRedirect():
    // 重定向到支付页面
    await launchUrl(Uri.parse(paymentResult.url));
    
    // 轮询支付状态
    final status = await paymentService.pollPaymentStatus(
      tradeNo: order.tradeNo,
      maxAttempts: 60,
      intervalSeconds: 3,
    );
    
    if (status.isSuccess) {
      print('支付成功！');
    }
    break;
    
  case PaymentResultSuccess():
    print('支付立即成功！');
    break;
    
  case PaymentResultFailed():
    print('支付失败: ${paymentResult.message}');
    break;
    
  case PaymentResultCanceled():
    print('支付已取消');
    break;
}
```

### 高级用法示例

#### 支付方式筛选
```dart
// 获取适用于特定金额的支付方式
final amount = 500.0;
final availableMethods = await paymentService.getAvailablePaymentMethods(amount);

// 按手续费排序
availableMethods.sort((a, b) => a.feePercent.compareTo(b.feePercent));

print('最优支付方式: ${availableMethods.first.name}');
```

#### 支付状态监控
```dart
// 自定义轮询策略
Future<void> monitorPayment(String tradeNo) async {
  for (int i = 0; i < 120; i++) { // 最多等待10分钟
    final status = await paymentService.checkPaymentStatus(tradeNo);
    
    if (status.isSuccess) {
      print('支付成功！');
      return;
    } else if (status.isCanceled) {
      print('支付已取消');
      return;
    }
    
    // 等待5秒后重试
    await Future.delayed(Duration(seconds: 5));
  }
  
  print('支付监控超时');
}
```

#### 批量支付管理
```dart
// 批量查询支付状态
Future<Map<String, PaymentStatusResult>> batchCheckStatus(
  List<String> tradeNos,
) async {
  final results = <String, PaymentStatusResult>{};
  
  for (final tradeNo in tradeNos) {
    try {
      results[tradeNo] = await paymentService.checkPaymentStatus(tradeNo);
    } catch (e) {
      results[tradeNo] = PaymentStatusResult.failed('查询失败: $e');
    }
  }
  
  return results;
}
```

## 错误处理

### 错误类型及处理策略

| 错误类型 | 处理策略 |
|---------|----------|
| `NoTokenError` | 重新登录获取认证令牌 |
| `NetworkError` | 检查网络连接并重试 |
| `InvalidResponseError` | 服务器错误，稍后重试 |
| `PreCheckError` | 检查支付参数和条件 |
| `UrlLaunchError` | 检查支付URL或更新应用 |
| `PaymentTimeoutError` | 查询支付状态或重新发起 |
| `InvalidAmountError` | 检查并修正支付金额 |
| `PaymentMethodUnavailableError` | 选择其他支付方式 |

### 错误处理示例
```dart
try {
  final result = await paymentService.processPayment(
    tradeNo: tradeNo,
    methodId: methodId,
  );
  // 处理支付结果
} on PaymentError catch (e) {
  switch (e.runtimeType) {
    case NoTokenError:
      // 跳转到登录页面
      await Navigator.pushNamed(context, '/login');
      break;
      
    case NetworkError:
      // 显示网络错误提示
      showErrorDialog('网络连接失败，请检查网络后重试');
      break;
      
    case PaymentMethodUnavailableError:
      // 更新支付方式列表
      await refreshPaymentMethods();
      break;
      
    default:
      // 显示通用错误信息
      showErrorDialog('支付失败: ${e.message}');
  }
} catch (e) {
  // 处理其他未知错误
  showErrorDialog('未知错误: $e');
}
```

## 最佳实践

### 1. 支付安全
- 始终在HTTPS环境下进行支付操作
- 妥善保管用户认证令牌
- 及时清理过期的支付会话

### 2. 用户体验
- 提供清晰的支付状态反馈
- 支持支付过程中的取消操作
- 实现支付超时的友好提示

### 3. 错误处理
- 实现完整的错误处理机制
- 提供用户友好的错误信息
- 支持支付失败后的重试机制

### 4. 性能优化
- 合理设置轮询间隔和超时时间
- 缓存支付方式信息
- 避免频繁的网络请求

## 集成测试

运行支付功能测试：
```bash
dart test/payment_test.dart
```

测试涵盖：
- 支付方式获取和筛选
- 支付流程完整性
- 状态查询和轮询
- 错误处理机制
- 数据模型序列化

## 注意事项

1. **认证要求**: 所有支付相关API都需要有效的访问令牌
2. **网络依赖**: 支付操作依赖稳定的网络连接
3. **状态一致性**: 支付状态可能存在延迟，建议使用轮询查询
4. **金额精度**: 金额计算使用双精度浮点数，注意精度问题
5. **超时处理**: 设置合理的超时时间，避免长时间等待

## 版本兼容性

- Flutter SDK: >=3.0.0
- Dart: >=3.0.0
- HTTP Package: ^1.0.0

## 更新日志

### v1.0.0
- 初始支付功能实现
- 支持多种支付方式
- 完整的状态管理
- 错误处理机制
- 轮询查询功能 