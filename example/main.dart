import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';

void main() async {
  print('=== XBoard SDK 测试 ===');
  
  try {
    // 测试SDK功能集成
    await testBalanceIntegration();
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
    
    // 设置测试token（实际使用时应该从登录获取）
    XBoardSDK.instance.setAuthToken('test_token_123');
    print('✅ Token设置成功');
    
    print('\n=== 数据模型测试 ===');
    
    // 测试数据模型
    testBalanceModels();
    testCouponModels();
    
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
    
  } catch (e) {
    print('❌ 集成测试失败: $e');
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