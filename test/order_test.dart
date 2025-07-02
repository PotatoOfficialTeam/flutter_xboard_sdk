import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';

/// 订单功能测试示例
/// 
/// 本文件演示如何使用XBoard SDK的订单功能
void main() async {
  print('=== XBoard SDK 订单功能测试 ===');
  
  try {
    await testOrderFeatures();
  } catch (e) {
    print('❌ 订单测试失败: $e');
  }
}

Future<void> testOrderFeatures() async {
  // 初始化SDK
  await XBoardSDK.instance.initialize('https://your-xboard-domain.com');
  
  // 设置认证Token（实际使用时从登录获取）
  XBoardSDK.instance.setAuthToken('your_auth_token_here');
  
  print('\n=== 基础订单功能测试 ===');
  
  try {
    // 1. 获取所有套餐计划
    print('📋 获取所有套餐计划...');
    final allPlans = await XBoardSDK.instance.order.fetchPlans();
    print('✅ 成功获取 ${allPlans.plans.length} 个套餐计划');
    
    // 显示前3个套餐
    for (int i = 0; i < allPlans.plans.length && i < 3; i++) {
      final plan = allPlans.plans[i];
      print('   ${i + 1}. ${plan.name}');
      print('      流量: ${plan.transferEnableGB.toStringAsFixed(1)} GB');
      if (plan.monthPrice != null) {
        print('      月价格: ${plan.monthPrice} 元');
      }
    }
    
    // 2. 获取可用的套餐计划
    print('\n📦 获取可用的套餐计划...');
    final availablePlans = await XBoardSDK.instance.order.getAvailablePlans();
    print('✅ 成功获取 ${availablePlans.length} 个可用套餐计划');
    
    // 3. 获取用户订单列表
    print('\n📃 获取用户订单列表...');
    final userOrders = await XBoardSDK.instance.order.fetchUserOrders();
    print('✅ 成功获取 ${userOrders.orders.length} 个用户订单');
    
    // 显示订单状态统计
    print('   待支付订单: ${userOrders.pendingOrders.length} 个');
    print('   已支付订单: ${userOrders.paidOrders.length} 个');
    
    // 显示最近3个订单
    for (int i = 0; i < userOrders.orders.length && i < 3; i++) {
      final order = userOrders.orders[i];
      print('   ${i + 1}. 订单号: ${order.tradeNo}');
      print('      状态: ${order.statusDescription}');
      print('      金额: ${order.totalAmount} 元');
      print('      套餐: ${order.orderPlan?.name ?? "未知"}');
    }
    
    // 4. 获取支付方式
    print('\n💳 获取支付方式...');
    final paymentMethods = await XBoardSDK.instance.order.getPaymentMethods();
    print('✅ 成功获取 ${paymentMethods.length} 种支付方式');
    
    for (final method in paymentMethods) {
      print('   • ${method.name} (${method.id})');
    }
    
  } catch (e) {
    print('❌ 基础功能测试失败: $e');
  }
  
  print('\n=== 高级订单功能测试 ===');
  
  try {
    // 5. 获取待支付订单
    print('⏳ 获取待支付订单...');
    final pendingOrders = await XBoardSDK.instance.order.getPendingOrders();
    print('✅ 成功获取 ${pendingOrders.length} 个待支付订单');
    
    if (pendingOrders.isNotEmpty) {
      // 6. 批量取消待支付订单（演示用）
      print('❌ 批量取消待支付订单...');
      final canceledCount = await XBoardSDK.instance.order.cancelPendingOrders();
      print('✅ 成功取消 $canceledCount 个待支付订单');
    }
    
    // 7. 套餐计划详情查询
    print('\n🔍 查询套餐计划详情...');
    final planDetails = await XBoardSDK.instance.order.getPlanDetails(1);
    if (planDetails != null) {
      print('✅ 成功获取套餐计划详情');
      print('   名称: ${planDetails.name}');
      print('   流量: ${planDetails.transferEnableGB.toStringAsFixed(1)} GB');
      print('   内容: ${planDetails.content ?? "无描述"}');
    } else {
      print('⚠️ 未找到套餐计划 ID: 1');
    }
    
  } catch (e) {
    print('❌ 高级功能测试失败: $e');
  }
  
  print('\n=== 订单创建和支付流程演示 ===');
  
  try {
    // 8. 演示完整的订阅流程
    print('🛒 演示订阅流程（使用模拟数据）...');
    
    // 注意：这里使用模拟数据，实际使用时需要真实的套餐ID
    await demonstrateSubscriptionFlow();
    
  } catch (e) {
    print('❌ 订阅流程演示失败: $e');
  }
  
  print('\n=== 订单查询功能演示 ===');
  
  try {
    // 9. 根据订单号查找订单
    print('🔎 根据订单号查找订单...');
    final foundOrder = await XBoardSDK.instance.order.findOrderByTradeNo('TEST_ORDER_123');
    if (foundOrder != null) {
      print('✅ 成功找到订单: ${foundOrder.tradeNo}');
    } else {
      print('⚠️ 未找到订单号为 TEST_ORDER_123 的订单');
    }
    
  } catch (e) {
    print('❌ 订单查询演示失败: $e');
  }
  
  print('\n✅ 所有订单功能测试完成！');
  
  // 10. 显示可用的API列表
  print('\n📖 订单服务可用API列表:');
  printAvailableOrderAPIs();
}

/// 演示完整的订阅流程
Future<void> demonstrateSubscriptionFlow() async {
  print('\n--- 订阅流程演示 ---');
  
  try {
    // 步骤1: 获取可用套餐
    final availablePlans = await XBoardSDK.instance.order.getAvailablePlans();
    if (availablePlans.isEmpty) {
      print('⚠️ 没有可用的套餐计划');
      return;
    }
    
    final selectedPlan = availablePlans.first;
    print('📦 选择套餐: ${selectedPlan.name}');
    
    // 步骤2: 处理订阅流程
    print('🔄 处理订阅流程...');
    final paymentResponse = await XBoardSDK.instance.order.handleSubscription(
      planId: selectedPlan.id,
      period: 'month',
      couponCode: null, // 可选的优惠券代码
    );
    
    print('✅ 订阅流程处理成功！');
    print('   订单号: ${paymentResponse.tradeNo}');
    print('   可用支付方式:');
    for (final method in paymentResponse.paymentMethods) {
      print('   • ${method.name}');
    }
    
    // 步骤3: 模拟选择支付方式并提交
    if (paymentResponse.paymentMethods.isNotEmpty) {
      final selectedMethod = paymentResponse.paymentMethods.first;
      print('💳 选择支付方式: ${selectedMethod.name}');
      
      // 提交支付（实际环境中这会跳转到支付页面）
      print('🚀 提交支付请求...');
      final paymentResult = await XBoardSDK.instance.order.submitPayment(
        tradeNo: paymentResponse.tradeNo,
        method: selectedMethod.id,
      );
      
      print('✅ 支付请求提交成功！');
      print('   结果: ${paymentResult.toString()}');
    }
    
  } catch (e) {
    print('❌ 订阅流程演示失败: $e');
    // 在实际应用中，这里应该处理具体的错误情况
    if (e.toString().contains('unauthorized')) {
      print('💡 提示: 请确保已设置有效的认证Token');
    } else if (e.toString().contains('network')) {
      print('💡 提示: 请检查网络连接和服务器地址');
    }
  }
}

/// 打印可用的订单API列表
void printAvailableOrderAPIs() {
  print('');
  print('📋 订单管理:');
  print('  • fetchUserOrders() - 获取用户订单列表');
  print('  • getOrderDetails(tradeNo) - 获取订单详情');
  print('  • cancelOrder(tradeNo) - 取消订单');
  print('  • findOrderByTradeNo(tradeNo) - 根据订单号查找订单');
  
  print('');
  print('🛒 订单创建:');
  print('  • createOrder(planId, period, [couponCode]) - 创建订单');
  print('  • handleSubscription(planId, period, [couponCode]) - 处理完整订阅流程');
  
  print('');
  print('💳 支付管理:');
  print('  • getPaymentMethods() - 获取支付方式');
  print('  • submitPayment(tradeNo, method) - 提交支付');
  
  print('');
  print('📦 套餐管理:');
  print('  • fetchPlans() - 获取所有套餐计划');
  print('  • getPlanDetails(planId) - 获取套餐详情');
  print('  • getAvailablePlans() - 获取可用套餐计划');
  
  print('');
  print('🔍 便捷查询:');
  print('  • getPendingOrders() - 获取待支付订单');
  print('  • getPaidOrders() - 获取已支付订单');
  print('  • cancelPendingOrders() - 批量取消待支付订单');
  
  print('');
  print('📡 原始API:');
  print('  • fetchUserOrdersRaw() - 获取原始订单数据');
  print('  • fetchPlansRaw() - 获取原始套餐数据');
  print('  • getPaymentMethodsRaw() - 获取原始支付方式数据');
}

/// 订单状态说明
void printOrderStatusHelp() {
  print('\n📊 订单状态说明:');
  print('  • 0 - 待支付');
  print('  • 1 - 已开通');
  print('  • 2 - 已取消');
  print('  • 3 - 已完成');
  print('  • 4 - 已折抵');
}

/// 支付周期说明
void printPeriodHelp() {
  print('\n📅 支付周期说明:');
  print('  • onetime - 一次性');
  print('  • month - 月付');
  print('  • quarter - 季付');
  print('  • half_year - 半年付');
  print('  • year - 年付');
  print('  • two_year - 两年付');
  print('  • three_year - 三年付');
} 