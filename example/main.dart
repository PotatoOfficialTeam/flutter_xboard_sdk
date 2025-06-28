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

Future<void> testBalanceIntegration() async {
  print('=== XBoard SDK 余额功能集成测试 ===');
  
  try {
    // 初始化SDK
    await XBoardSDK.instance.initialize('https://example.com');
    print('✅ SDK初始化成功');
    
    // 验证余额服务可访问
    print('✅ 余额服务创建成功: ${XBoardSDK.instance.balance.runtimeType}');
    
    // 验证优惠券服务可访问
    print('✅ 优惠券服务创建成功: ${XBoardSDK.instance.coupon.runtimeType}');
    
    // 设置测试token（实际使用时应该从登录获取）
    XBoardSDK.instance.setAuthToken('test_token_123');
    print('✅ Token设置成功');
    
    print('\n=== 余额服务API方法测试 ===');
    
    // 测试数据模型
    testBalanceModels();
    
    print('\n=== 优惠券服务API方法测试 ===');
    
    // 测试优惠券数据模型
    testCouponModels();
    
    print('\n✅ 功能集成测试完成');
    print('📱 可用的余额API:');
    print('  • transferCommission() - 佣金转账');
    print('  • withdrawFunds() - 申请提现');
    print('  • getSystemConfig() - 获取系统配置');
    print('  • getBalanceInfo() - 获取余额信息');
    print('  • getWithdrawHistory() - 获取提现历史');
    print('  • getCommissionHistory() - 获取佣金历史');
    
    print('🎫 可用的优惠券API:');
    print('  • checkCoupon() - 验证优惠券');
    print('  • getAvailableCoupons() - 获取可用优惠券');
    print('  • getCouponHistory() - 获取优惠券使用历史');
    
  } catch (e) {
    print('❌ 集成测试失败: $e');
  }
}

void testBalanceModels() {
  print('\n--- 数据模型测试 ---');
  
  // 测试SystemConfig模型
  final configJson = {
    'currency': 'CNY',
    'withdraw_enable': 1,
    'min_withdraw_amount': 100,
    'max_withdraw_amount': 10000,
    'withdraw_fee_rate': 0.05,
    'withdraw_methods': ['alipay', 'wechat'],
    'withdraw_notice': '提现须知'
  };
  
  final config = SystemConfig.fromJson(configJson);
  print('✅ SystemConfig模型: ${config.currency}, 提现开启: ${config.withdrawEnabled}');
  
  // 测试BalanceInfo模型
  final balanceJson = {
    'balance': 100.5,
    'commission_balance': 50.25,
    'total_balance': 150.75,
    'currency': 'CNY'
  };
  
  final balance = BalanceInfo.fromJson(balanceJson);
  print('✅ BalanceInfo模型: 余额 ${balance.balance}, 佣金 ${balance.commissionBalance}');
  
  // 测试TransferResult模型
  final transferResult = TransferResult(
    success: true,
    message: '转账成功',
    transferAmount: 50.0,
    newBalance: 150.0,
  );
  print('✅ TransferResult模型: ${transferResult.success}, ${transferResult.message}');
  
  // 测试WithdrawResult模型
  final withdrawResult = WithdrawResult(
    success: true,
    message: '提现申请成功',
    withdrawId: 'withdraw_123',
    status: 'pending',
  );
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

// 使用示例（注释掉，避免在测试时执行实际网络请求）
/*
Future<void> exampleUsage() async {
  // 初始化SDK
  await XBoardSDK.instance.initialize('https://your-xboard-domain.com');
  
  // 用户登录获取token
  final loginResult = await XBoardSDK.instance.auth.login('user@example.com', 'password');
  if (loginResult.success) {
    XBoardSDK.instance.setAuthToken(loginResult.data!.token);
    
    // === 余额功能 ===
    
    // 获取系统配置
    final config = await XBoardSDK.instance.balance.getSystemConfig();
    print('系统货币: ${config.currency}');
    print('提现开启: ${config.withdrawEnabled}');
    
    // 获取余额信息
    final balanceInfo = await XBoardSDK.instance.balance.getBalanceInfo();
    print('当前余额: ${balanceInfo.balance}');
    print('佣金余额: ${balanceInfo.commissionBalance}');
    
    // 转移佣金到余额
    final transferResult = await XBoardSDK.instance.balance.transferCommission(1000); // 10.00元
    if (transferResult.success) {
      print('佣金转移成功: ${transferResult.message}');
    }
    
    // 申请提现
    final withdrawResult = await XBoardSDK.instance.balance.withdrawFunds(
      'alipay',
      'your_alipay_account@example.com'
    );
    if (withdrawResult.success) {
      print('提现申请成功: ${withdrawResult.withdrawId}');
    }
    
    // === 优惠券功能 ===
    
    // 验证优惠券
    final couponResponse = await XBoardSDK.instance.coupon.checkCoupon('SAVE20', 123);
    if (couponResponse.success && couponResponse.data != null) {
      final coupon = couponResponse.data!;
      print('优惠券名称: ${coupon.name}');
      print('折扣类型: ${coupon.type}'); // 1: 金额折扣, 2: 百分比折扣
      print('折扣值: ${coupon.value}');
      
      // 应用层计算折扣逻辑
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
    final couponHistory = await XBoardSDK.instance.coupon.getCouponHistory(page: 1, pageSize: 10);
    if (couponHistory['success']) {
      print('优惠券使用记录数量: ${couponHistory['data'].length}');
    }
  }
}
*/ 