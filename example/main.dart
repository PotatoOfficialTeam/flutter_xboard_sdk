import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';

void main() async {
  print('=== XBoard SDK 测试 ===');
  
  try {
    // 测试SDK功能集成
    await testBalanceIntegration();
    
    // 测试支付功能
    await testPaymentIntegration();
  } catch (e) {
    print('❌ 测试失败: $e');
  }
}

Future<void> testBalanceIntegration() async {
  print('=== XBoard SDK 功能集成测试 ===');
  
  try {
    // 初始化SDK
    await XBoardSDK.instance.initialize('https://example.com');
    print('✅ SDK初始化成功');
    
    // 验证各服务可访问
    print('✅ 认证服务: ${XBoardSDK.instance.auth.runtimeType}');
    print('✅ 订阅服务: ${XBoardSDK.instance.subscription.runtimeType}');
    print('✅ 余额服务: ${XBoardSDK.instance.balance.runtimeType}');
    print('✅ 优惠券服务: ${XBoardSDK.instance.coupon.runtimeType}');
    print('✅ 通知服务: ${XBoardSDK.instance.notice.runtimeType}');
    print('✅ 订单服务: ${XBoardSDK.instance.order.runtimeType}');
    print('✅ 支付服务: ${XBoardSDK.instance.payment.runtimeType}');
    
    // 设置测试token（实际使用时应该从登录获取）
    XBoardSDK.instance.setAuthToken('test_token_123');
    print('✅ Token设置成功');
    
    print('\n=== 数据模型测试 ===');
    
    // 测试数据模型
    testBalanceModels();
    testCouponModels();
    testNoticeModels();
    testOrderModels();
    
    print('\n✅ 功能集成测试完成');
    print('📱 可用的余额API:');
    print('  • transferCommission() - 佣金转账');
    print('  • withdrawFunds() - 申请提现');
    print('  • getSystemConfig() - 获取系统配置');
    print('  • getUserInfo() - 获取用户信息（含余额）');
    print('  • canWithdraw() - 检查是否可提现');
    print('  • getWithdrawMethods() - 获取提现方式');
    print('  • getWithdrawHistory() - 获取提现历史');
    print('  • getCommissionHistory() - 获取佣金历史');
    
    print('🎫 可用的优惠券API:');
    print('  • checkCoupon() - 验证优惠券');
    print('  • getAvailableCoupons() - 获取可用优惠券');
    print('  • getCouponHistory() - 获取优惠券使用历史');
    
    print('🔔 可用的通知API:');
    print('  • fetchNotices() - 获取通知列表');
    print('  • fetchAppNotices() - 获取应用通知');
    print('  • fetchVisibleNotices() - 获取可见通知');
    print('  • fetchNoticesByTag() - 根据标签筛选通知');
    print('  • getNoticeById() - 根据ID获取单个通知');
    
    print('📦 可用的订单API:');
    print('  • fetchUserOrders() - 获取用户订单列表');
    print('  • createOrder() - 创建订单');
    print('  • cancelOrder() - 取消订单');
    print('  • getOrderDetails() - 获取订单详情');
    print('  • submitPayment() - 提交支付');
    print('  • fetchPlans() - 获取套餐计划');
    print('  • getPaymentMethods() - 获取支付方式');
    print('  • handleSubscription() - 处理完整订阅流程');
    print('  • getPendingOrders() - 获取待支付订单');
    print('  • cancelPendingOrders() - 批量取消待支付订单');
    
  } catch (e) {
    print('❌ 集成测试失败: $e');
  }
}

Future<void> testPaymentIntegration() async {
  print('\n=== 支付功能集成测试 ===');
  
  try {
    // 初始化SDK（如果尚未初始化）
    if (!XBoardSDK.instance.isInitialized) {
      await XBoardSDK.instance.initialize('https://example.com');
    }
    
    print('✅ 支付服务: ${XBoardSDK.instance.payment.runtimeType}');
    
    // 测试支付数据模型
    testPaymentModels();
    
    print('\n💳 可用的支付API:');
    print('  • getPaymentMethods() - 获取支付方式列表');
    print('  • getAvailablePaymentMethods(amount) - 获取适用于指定金额的支付方式');
    print('  • getPaymentMethodById(id) - 根据ID获取支付方式详情');
    print('  • submitOrderPayment(request) - 提交订单支付');
    print('  • checkPaymentStatus(tradeNo) - 查询支付状态');
    print('  • cancelPayment(tradeNo) - 取消支付');
    print('  • calculateTotalAmount(amount, methodId) - 计算总金额（含手续费）');
    print('  • validatePaymentAmount(amount, methodId) - 验证支付金额');
    print('  • processPayment(...) - 完整支付流程');
    print('  • pollPaymentStatus(...) - 轮询支付状态');
    print('  • getPaymentHistory() - 获取支付历史');
    print('  • getPaymentStats() - 获取支付统计');
    
    print('\n💰 支付工作流程示例:');
    print('  1. 获取支付方式: payment.getPaymentMethods()');
    print('  2. 创建订单: order.createOrder(...)');
    print('  3. 处理支付: payment.processPayment(tradeNo, methodId)');
    print('  4. 轮询状态: payment.pollPaymentStatus(tradeNo)');
    
  } catch (e) {
    print('❌ 支付功能测试失败: $e');
  }
}

void testBalanceModels() {
  print('\n--- 余额数据模型测试 ---');
  
  // 测试SystemConfig模型 - 使用真实API格式
  final configJson = {
    'withdraw_methods': ['alipay', 'wechat'],
    'withdraw_close': 0, // 0表示开启，1表示关闭
    'currency': 'CNY',
    'currency_symbol': '¥'
  };
  
  final config = SystemConfig.fromJson(configJson);
  print('✅ SystemConfig模型: ${config.currency}${config.currencySymbol}, 提现开启: ${config.withdrawEnabled}');
  print('   支持的提现方式: ${config.withdrawMethods.join(", ")}');
  
  // 测试UserInfo模型 - 包含余额信息
  final userInfoJson = {
    'email': 'test@example.com',
    'transfer_enable': 107374182400.0, // 100GB
    'created_at': 1640995200, // 2022-01-01
    'banned': 0,
    'remind_expire': 1,
    'remind_traffic': 1,
    'balance': 10050.0, // 100.50元，以分为单位
    'commission_balance': 5025.0, // 50.25元，以分为单位
    'plan_id': 1,
    'uuid': 'test-uuid-123',
    'avatar_url': 'https://example.com/avatar.png'
  };
  
  final userInfo = UserInfo.fromJson(userInfoJson);
  print('✅ UserInfo模型: ${userInfo.email}');
  print('   余额: ${userInfo.balanceInYuan}元 (原始: ${userInfo.balance}分)');
  print('   佣金: ${userInfo.commissionBalanceInYuan}元 (原始: ${userInfo.commissionBalance}分)');
  print('   总余额: ${userInfo.totalBalanceInYuan}元');
  
  // 测试TransferResult模型
  final transferJson = {
    'status': 'success',
    'message': '佣金转移成功',
    'data': userInfoJson,
  };
  
  final transferResult = TransferResult.fromJson(transferJson);
  print('✅ TransferResult模型: ${transferResult.success}, ${transferResult.message}');
  
  // 测试WithdrawResult模型
  final withdrawJson = {
    'status': 'success',
    'message': '提现申请成功',
    'data': {'withdraw_id': 'withdraw_123'},
  };
  
  final withdrawResult = WithdrawResult.fromJson(withdrawJson);
  print('✅ WithdrawResult模型: ${withdrawResult.success}, ID: ${withdrawResult.withdrawId}');
}

void testCouponModels() {
  print('\n--- 优惠券数据模型测试 ---');
  
  // 测试CouponData模型
  final couponJson = {
    'id': '123',
    'name': '新用户优惠',
    'code': 'NEWUSER20',
    'type': 2, // 百分比折扣
    'value': 20.0, // 20%折扣
    'limit_use': 100,
    'limit_use_with_user': 1,
    'started_at': 1703000000, // 时间戳
    'ended_at': 1735000000,
    'show': 1,
    'created_at': 1700000000,
    'updated_at': 1700000000,
  };
  
  final coupon = CouponData.fromJson(couponJson);
  print('✅ CouponData模型: ${coupon.code}, 类型: ${coupon.type}, 值: ${coupon.value}');
  
  // 测试CouponResponse模型
  final responseJson = {
    'success': true,
    'message': '优惠券验证成功',
    'data': couponJson,
  };
  
  final response = CouponResponse.fromJson(responseJson);
  print('✅ CouponResponse模型: ${response.success}, 消息: ${response.message}');
  
  // 测试AvailableCouponsResponse模型
  final listResponseJson = {
    'success': true,
    'message': '获取成功',
    'data': [couponJson],
    'total': 1,
  };
  
  final listResponse = AvailableCouponsResponse.fromJson(listResponseJson);
  print('✅ AvailableCouponsResponse模型: ${listResponse.success}, 数量: ${listResponse.total}');
}

void testNoticeModels() {
  print('\n--- 通知数据模型测试 ---');
  
  // 测试Notice模型
  final noticeJson = {
    'id': 1,
    'title': '系统维护通知',
    'content': '系统将于今晚22:00-24:00进行维护，届时服务可能暂时不可用。',
    'show': 1,
    'img_url': 'https://example.com/notice.png',
    'tags': ['system', 'maintenance'],
    'created_at': 1703000000,
    'updated_at': 1703000000,
  };
  
  final notice = Notice.fromJson(noticeJson);
  print('✅ Notice模型: ${notice.title}');
  print('   内容: ${notice.content}');
  print('   标签: ${notice.tags?.join(", ")}');
  print('   应该显示: ${notice.shouldShow}');
  print('   是否为应用通知: ${notice.isAppNotice}');
  
  // 测试应用通知
  final appNoticeJson = {
    'id': 2,
    'title': '新功能发布',
    'content': '我们很高兴地宣布新的功能已经上线！',
    'show': true,
    'img_url': null,
    'tags': ['app', 'feature'],
    'created_at': 1703100000,
    'updated_at': 1703100000,
  };
  
  final appNotice = Notice.fromJson(appNoticeJson);
  print('✅ 应用Notice模型: ${appNotice.title}');
  print('   是否为应用通知: ${appNotice.isAppNotice}');
  print('   应该显示: ${appNotice.shouldShow}');
  
  // 测试NoticeResponse模型
  final responseJson = {
    'data': [noticeJson, appNoticeJson],
    'total': 2,
  };
  
  final response = NoticeResponse.fromJson(responseJson);
  print('✅ NoticeResponse模型: 总数 ${response.total}');
  print('   通知数量: ${response.notices.length}');
  print('   应用通知数量: ${response.appNotices.length}');
  
  // 测试NoticesState模型
  final state = NoticesState(
    isLoading: false,
    noticeResponse: response,
    error: null,
  );
  
  final newState = state.copyWith(
    isLoading: true,
    error: '网络错误',
  );
  
  print('✅ NoticesState模型: 加载中 ${newState.isLoading}, 错误: ${newState.error}');
}

void testOrderModels() {
  print('\n--- 订单数据模型测试 ---');
  
  try {
    // 测试Order模型
    final orderJson = {
      'plan_id': 1,
      'trade_no': 'TEST_ORDER_123',
      'total_amount': 29.99,
      'period': 'month',
      'status': 0,
      'created_at': 1703000000,
      'plan': {
        'id': 1,
        'name': '基础套餐',
        'onetime_price': 29.99,
        'content': '基础套餐描述',
      }
    };
    
    final order = Order.fromJson(orderJson);
    print('✅ Order模型: ${order.tradeNo}, 状态: ${order.statusDescription}');
    print('   金额: ${order.totalAmount}元, 周期: ${order.period}');
    print('   是否待支付: ${order.isPending}, 是否已支付: ${order.isPaid}');
    print('   套餐名称: ${order.orderPlan?.name}');
    
    // 测试Plan模型
    final planJson = {
      'id': 1,
      'group_id': 1,
      'transfer_enable': 107374182400, // 100GB
      'name': '标准套餐',
      'speed_limit': 0,
      'show': 1,
      'content': '标准套餐内容',
      'month_price': 2999, // 29.99元，以分为单位
      'year_price': 29999, // 299.99元
      'created_at': 1703000000,
      'updated_at': 1703000000,
    };
    
    final plan = Plan.fromJson(planJson);
    print('✅ Plan模型: ${plan.name}, 流量: ${plan.transferEnableGB.toStringAsFixed(1)}GB');
    print('   月价格: ${plan.monthPrice}元, 年价格: ${plan.yearPrice}元');
    print('   月周期价格: ${plan.getPriceForPeriod('month')}元');
    
    // 测试PaymentMethod模型
    final paymentMethodJson = {
      'id': 'alipay',
      'name': '支付宝',
      'icon': 'alipay.png',
      'is_available': true,
    };
    
    final paymentMethod = PaymentMethod.fromJson(paymentMethodJson);
    print('✅ PaymentMethod模型: ${paymentMethod.name}, 可用: ${paymentMethod.isAvailable}');
    
    // 测试CreateOrderRequest模型
    final createOrderRequest = CreateOrderRequest(
      planId: 1,
      period: 'month',
      couponCode: 'DISCOUNT20',
    );
    print('✅ CreateOrderRequest模型: ${createOrderRequest.toJson()}');
    
    // 测试SubmitOrderRequest模型
    final submitOrderRequest = SubmitOrderRequest(
      tradeNo: 'TEST_ORDER_123',
      method: 'alipay',
    );
    print('✅ SubmitOrderRequest模型: ${submitOrderRequest.toJson()}');
    
    // 测试OrderResponse模型
    final orderResponseJson = {
      'data': [orderJson],
      'total': 1,
    };
    
    final orderResponse = OrderResponse.fromJson(orderResponseJson);
    print('✅ OrderResponse模型: 共${orderResponse.orders.length}个订单');
    print('   待支付订单: ${orderResponse.pendingOrders.length}个');
    print('   已支付订单: ${orderResponse.paidOrders.length}个');
    
    // 测试PlanResponse模型
    final planResponseJson = {
      'data': [planJson],
      'total': 1,
    };
    
    final planResponse = PlanResponse.fromJson(planResponseJson);
    print('✅ PlanResponse模型: 共${planResponse.plans.length}个计划');
    print('   可用计划: ${planResponse.availablePlans.length}个');
    
    // 测试PaymentResponse模型
    final paymentResponseJson = {
      'payment_methods': [paymentMethodJson],
      'trade_no': 'TEST_ORDER_123',
    };
    
    final paymentResponse = PaymentResponse.fromJson(paymentResponseJson);
    print('✅ PaymentResponse模型: 订单号 ${paymentResponse.tradeNo}');
    print('   支付方式数量: ${paymentResponse.paymentMethods.length}个');
    
    print('✅ 所有订单模型测试通过！');
    
  } catch (e) {
    print('❌ 订单模型测试失败: $e');
  }
}

void testPaymentModels() {
  print('\n--- 支付数据模型测试 ---');
  
  try {
    // 测试PaymentMethodInfo模型
    final paymentMethodJson = {
      'id': 'alipay',
      'name': '支付宝',
      'handling_fee_percent': 2.5,
      'icon': 'alipay.png',
      'is_available': true,
      'description': '支付宝在线支付',
      'min_amount': 1.0,
      'max_amount': 10000.0,
    };
    
    final paymentMethod = PaymentMethodInfo.fromJson(paymentMethodJson);
    print('✅ PaymentMethodInfo模型: ${paymentMethod.name}');
    print('   手续费: ${paymentMethod.feePercent}%');
    print('   金额范围: ${paymentMethod.minAmount} - ${paymentMethod.maxAmount}');
    print('   100元手续费: ${paymentMethod.calculateFee(100)}元');
    print('   100元总计: ${paymentMethod.calculateTotalAmount(100)}元');
    print('   50元是否有效: ${paymentMethod.isAmountValid(50)}');
    
    // 测试PaymentOrderInfo模型
    final orderInfoJson = {
      'trade_no': 'ORDER_20240101_001',
      'original_amount': 100.0,
      'final_amount': 85.0,
      'coupon_code': 'DISCOUNT15',
      'discount_amount': 15.0,
      'currency': 'CNY',
      'expire_time': 1735000000,
    };
    
    final orderInfo = PaymentOrderInfo.fromJson(orderInfoJson);
    print('✅ PaymentOrderInfo模型: ${orderInfo.tradeNo}');
    print('   原价: ${orderInfo.originalAmount}元, 实付: ${orderInfo.finalAmount}元');
    print('   折扣: ${orderInfo.actualDiscountAmount}元 (${orderInfo.discountPercent.toStringAsFixed(1)}%)');
    print('   是否过期: ${orderInfo.isExpired}');
    
    // 测试PaymentStatus枚举
    final status = PaymentStatus.processing;
    print('✅ PaymentStatus枚举: ${status.description}');
    print('   是否最终状态: ${status.isFinal}');
    print('   是否成功: ${status.isSuccess}');
    
    // 测试PaymentStatusResult模型
    final successResult = PaymentStatusResult.success('支付成功');
    final pendingResult = PaymentStatusResult.pending('等待支付');
    final failedResult = PaymentStatusResult.failed('支付失败');
    
    print('✅ PaymentStatusResult模型:');
    print('   成功: ${successResult.isSuccess}, 消息: ${successResult.message}');
    print('   等待: ${pendingResult.isPending}, 消息: ${pendingResult.message}');
    print('   失败: ${!failedResult.isSuccess && !failedResult.isPending}, 消息: ${failedResult.message}');
    
    // 测试PaymentResult sealed class
    final redirectResult = PaymentResult.redirect(url: 'https://pay.example.com/checkout');
    final successPaymentResult = PaymentResult.success(transactionId: 'TXN_123');
    final failedPaymentResult = PaymentResult.failed(message: '余额不足');
    
    print('✅ PaymentResult sealed class:');
    print('   重定向: ${redirectResult is PaymentResultRedirect}');
    print('   成功: ${successPaymentResult is PaymentResultSuccess}');
    print('   失败: ${failedPaymentResult is PaymentResultFailed}');
    
    // 测试PaymentRequest模型
    final paymentRequest = PaymentRequest(
      tradeNo: 'ORDER_20240101_001',
      method: 'alipay',
      callbackUrl: 'https://app.example.com/callback',
      extra: {'user_id': '123'},
    );
    
    print('✅ PaymentRequest模型: ${paymentRequest.toJson()}');
    
    // 测试PaymentResponse模型
    final paymentResponseJson = {
      'success': true,
      'message': '支付处理成功',
      'data': {
        'redirect_url': 'https://pay.example.com/checkout',
        'method': 'GET',
      },
    };
    
    final paymentResponse = PaymentResponse.fromJson(paymentResponseJson);
    print('✅ PaymentResponse模型: ${paymentResponse.success}');
    print('   结果类型: ${paymentResponse.result.runtimeType}');
    
    // 测试PaymentState模型
    final paymentState = PaymentState(
      orderInfo: orderInfo,
      status: PaymentStatus.processing,
      paymentMethods: [paymentMethod],
      isLoading: false,
    );
    
    print('✅ PaymentState模型: 状态 ${paymentState.status.description}');
    print('   可以支付: ${paymentState.canPay}');
    print('   支付完成: ${paymentState.isCompleted}');
    
    // 测试PaymentError类型
    final errors = [
      PaymentError.noToken(),
      PaymentError.networkError('网络超时'),
      PaymentError.invalidAmount('金额必须大于0'),
      PaymentError.paymentMethodUnavailable('支付宝暂不可用'),
      PaymentError.timeout('支付超时'),
    ];
    
    print('✅ PaymentError类型:');
    for (final error in errors) {
      print('   ${error.runtimeType}: ${error.message} [${error.errorCode}]');
    }
    
    print('✅ 所有支付模型测试通过！');
    
  } catch (e) {
    print('❌ 支付模型测试失败: $e');
  }
} 