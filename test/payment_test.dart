import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';

/// 支付功能测试示例
/// 
/// 展示如何使用XBoard SDK的支付服务
void main() async {
  print('=== 支付服务测试 ===');
  
  await testPaymentFeatures();
}

Future<void> testPaymentFeatures() async {
  try {
    // 初始化SDK
    await XBoardSDK.instance.initialize('https://your-xboard-domain.com');
    
    // 设置认证Token（实际使用时从登录获取）
    XBoardSDK.instance.setAuthToken('your_access_token_here');
    
    final paymentService = XBoardSDK.instance.payment;
    
    // === 1. 获取支付方式 ===
    print('\n=== 1. 获取支付方式 ===');
    
    try {
      final paymentMethods = await paymentService.getPaymentMethods();
      print('✅ 获取到 ${paymentMethods.length} 种支付方式:');
      
      for (final method in paymentMethods) {
        print('  • ${method.name} (${method.id})');
        print('    手续费: ${method.feePercent}%');
        print('    状态: ${method.isAvailable ? '可用' : '不可用'}');
        if (method.description != null) {
          print('    描述: ${method.description}');
        }
        if (method.minAmount != null || method.maxAmount != null) {
          print('    金额限制: ${method.minAmount ?? '无下限'} - ${method.maxAmount ?? '无上限'}');
        }
        print('');
      }
      
      // 获取适用于特定金额的支付方式
      if (paymentMethods.isNotEmpty) {
        final amount = 100.0;
        final availableMethods = await paymentService.getAvailablePaymentMethods(amount);
        print('适用于 $amount 元的支付方式: ${availableMethods.length} 种');
      }
      
    } catch (e) {
      print('❌ 获取支付方式失败: $e');
    }
    
    // === 2. 计算支付金额 ===
    print('\n=== 2. 计算支付金额 ===');
    
    try {
      final methods = await paymentService.getPaymentMethods();
      if (methods.isNotEmpty) {
        final method = methods.first;
        final amount = 100.0;
        
        final totalAmount = await paymentService.calculateTotalAmount(amount, method.id);
        print('使用 ${method.name} 支付 $amount 元:');
        print('  手续费: ${method.calculateFee(amount)} 元');
        print('  总计: $totalAmount 元');
        
        // 验证金额
        final isValid = await paymentService.validatePaymentAmount(amount, method.id);
        print('  金额有效性: ${isValid ? '有效' : '无效'}');
      }
    } catch (e) {
      print('❌ 计算支付金额失败: $e');
    }
    
    // === 3. 支付流程示例 ===
    print('\n=== 3. 支付流程示例 ===');
    
    try {
      // 首先需要创建订单（使用OrderService）
      final orderService = XBoardSDK.instance.order;
      
      print('📝 创建订单示例:');
      print('  1. 选择套餐: await order.fetchPlans()');
      print('  2. 创建订单: await order.createOrder(planId: 1, period: "month")');
      print('  3. 获取交易号: order.tradeNo');
      
      // 模拟订单已创建的情况
      const tradeNo = 'EXAMPLE_TRADE_NO_123';
      const methodId = 'alipay';
      
      print('\n💳 支付流程示例:');
      
      // 预检查支付条件
      print('  1. 预检查支付条件...');
      final paymentRequest = PaymentRequest(
        tradeNo: tradeNo,
        method: methodId,
        callbackUrl: 'https://your-app.com/payment-callback',
      );
      
      try {
        await paymentService.preCheckPayment(paymentRequest);
        print('     ✅ 预检查通过');
      } catch (e) {
        print('     ❌ 预检查失败: $e');
      }
      
      // 完整支付流程
      print('  2. 处理支付...');
      try {
        final result = await paymentService.processPayment(
          tradeNo: tradeNo,
          methodId: methodId,
          callbackUrl: 'https://your-app.com/payment-callback',
          extra: {'user_id': '123', 'source': 'mobile_app'},
        );
        
        // 根据支付结果类型处理
        switch (result) {
          case PaymentResultSuccess():
            print('     ✅ 支付成功');
            if (result.transactionId != null) {
              print('     交易ID: ${result.transactionId}');
            }
            break;
            
          case PaymentResultRedirect():
            print('     🔄 需要重定向到支付页面');
            print('     支付URL: ${result.url}');
            print('     请求方法: ${result.method ?? 'GET'}');
            break;
            
          case PaymentResultFailed():
            print('     ❌ 支付失败: ${result.message}');
            if (result.errorCode != null) {
              print('     错误代码: ${result.errorCode}');
            }
            break;
            
          case PaymentResultCanceled():
            print('     ⏹️ 支付已取消: ${result.message ?? '用户取消'}');
            break;
        }
        
      } catch (e) {
        print('     ❌ 支付处理失败: $e');
      }
      
    } catch (e) {
      print('❌ 支付流程示例失败: $e');
    }
    
    // === 4. 支付状态查询 ===
    print('\n=== 4. 支付状态查询 ===');
    
    try {
      const tradeNo = 'EXAMPLE_TRADE_NO_123';
      
      // 单次查询
      print('📊 查询支付状态...');
      final statusResult = await paymentService.checkPaymentStatus(tradeNo);
      
      if (statusResult.isSuccess) {
        print('  ✅ 支付成功: ${statusResult.message ?? ''}');
      } else if (statusResult.isCanceled) {
        print('  ⏹️ 支付已取消: ${statusResult.message ?? ''}');
      } else if (statusResult.isPending) {
        print('  ⏳ 支付处理中: ${statusResult.message ?? ''}');
      } else {
        print('  ❌ 支付失败: ${statusResult.message ?? ''}');
      }
      
      // 轮询查询示例
      print('\n🔄 轮询支付状态示例:');
      print('  await payment.pollPaymentStatus(');
      print('    tradeNo: "$tradeNo",');
      print('    maxAttempts: 60,    // 最多尝试60次');
      print('    intervalSeconds: 3, // 每3秒查询一次');
      print('  );');
      
    } catch (e) {
      print('❌ 查询支付状态失败: $e');
    }
    
    // === 5. 支付历史和统计 ===
    print('\n=== 5. 支付历史和统计 ===');
    
    try {
      // 获取支付历史
      print('📈 获取支付历史...');
      final paymentHistory = await paymentService.getPaymentHistory(limit: 10);
      print('  获取到 ${paymentHistory.length} 条支付记录');
      
      // 获取支付统计
      print('📊 获取支付统计...');
      final paymentStats = await paymentService.getPaymentStats();
      print('  支付统计信息: $paymentStats');
      
    } catch (e) {
      print('❌ 获取支付数据失败: $e');
    }
    
    // === 6. 取消支付 ===
    print('\n=== 6. 取消支付 ===');
    
    try {
      const tradeNo = 'EXAMPLE_TRADE_NO_123';
      
      print('⏹️ 取消支付...');
      final cancelled = await paymentService.cancelPayment(tradeNo);
      
      if (cancelled) {
        print('  ✅ 支付已取消');
      } else {
        print('  ❌ 取消支付失败');
      }
      
    } catch (e) {
      print('❌ 取消支付操作失败: $e');
    }
    
    print('\n=== 完整的电商购买流程示例 ===');
    print('```dart');
    print('// 1. 获取可用套餐');
    print('final plans = await sdk.order.fetchPlans();');
    print('');
    print('// 2. 获取支付方式');
    print('final paymentMethods = await sdk.payment.getPaymentMethods();');
    print('');
    print('// 3. 创建订单');
    print('final order = await sdk.order.createOrder(');
    print('  planId: selectedPlan.id,');
    print('  period: "month",');
    print('  couponCode: "DISCOUNT20",');
    print(');');
    print('');
    print('// 4. 处理支付');
    print('final paymentResult = await sdk.payment.processPayment(');
    print('  tradeNo: order.tradeNo,');
    print('  methodId: selectedMethod.id,');
    print('  callbackUrl: "https://your-app.com/payment-callback",');
    print(');');
    print('');
    print('// 5. 根据结果处理');
    print('switch (paymentResult) {');
    print('  case PaymentResultRedirect():');
    print('    // 跳转到支付页面');
    print('    await launchUrl(Uri.parse(paymentResult.url));');
    print('    // 轮询支付状态');
    print('    final status = await sdk.payment.pollPaymentStatus(');
    print('      tradeNo: order.tradeNo,');
    print('    );');
    print('    break;');
    print('  case PaymentResultSuccess():');
    print('    // 支付成功，更新UI');
    print('    break;');
    print('  // ... 其他情况');
    print('}');
    print('```');
    
    print('\n✅ 支付功能测试完成');
    
  } catch (e) {
    print('❌ 支付功能测试失败: $e');
  }
}

/// 支付错误处理示例
void demonstrateErrorHandling() {
  print('\n=== 支付错误处理示例 ===');
  
  // 演示各种支付错误类型
  final errors = [
    PaymentError.noToken(),
    PaymentError.networkError('网络连接超时'),
    PaymentError.invalidResponse('服务器返回格式错误'),
    PaymentError.preCheckFailed('支付前检查失败'),
    PaymentError.cannotLaunchUrl('https://invalid-payment-url.com'),
    PaymentError.timeout('支付处理超时'),
    PaymentError.invalidAmount('支付金额必须大于0'),
    PaymentError.paymentMethodUnavailable('所选支付方式暂不可用'),
  ];
  
  print('常见支付错误类型及处理:');
  for (final error in errors) {
    print('  ${error.runtimeType}: ${error.message}');
    print('    错误代码: ${error.errorCode}');
    print('    处理建议: ${_getErrorHandlingSuggestion(error)}');
    print('');
  }
}

String _getErrorHandlingSuggestion(PaymentError error) {
  switch (error.runtimeType) {
    case NoTokenError:
      return '请重新登录获取认证令牌';
    case NetworkError:
      return '检查网络连接并重试';
    case InvalidResponseError:
      return '服务器错误，请稍后重试';
    case PreCheckError:
      return '检查支付条件和参数';
    case UrlLaunchError:
      return '检查支付URL或更新应用';
    case PaymentTimeoutError:
      return '查询支付状态或重新发起支付';
    case InvalidAmountError:
      return '检查并修正支付金额';
    case PaymentMethodUnavailableError:
      return '选择其他可用的支付方式';
    default:
      return '查看详细错误信息并联系技术支持';
  }
} 