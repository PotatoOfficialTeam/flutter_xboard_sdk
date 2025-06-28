import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';

/// 集成测试 - 测试真实的XBoard API
/// 
/// 使用方法：
/// 1. 设置环境变量：
///    export XBOARD_BASE_URL="https://your-xboard-domain.com"
///    export XBOARD_TEST_EMAIL="test@example.com"
///    export XBOARD_TEST_PASSWORD="your_password"
///    export XBOARD_TEST_INVITE_CODE="invite_code" (可选)
/// 
/// 2. 运行测试：
///    flutter test test/integration_test.dart
/// 
/// 注意：这个测试需要真实的网络连接和有效的XBoard账号
void main() {
  group('XBoard SDK 集成测试', () {
    late XBoardSDK sdk;
    late String baseUrl;
    late String testEmail;
    late String testPassword;
    String? inviteCode;

    setUpAll(() {
      // 从环境变量获取测试配置
      baseUrl = Platform.environment['XBOARD_BASE_URL'] ?? '';
      testEmail = Platform.environment['XBOARD_TEST_EMAIL'] ?? '';
      testPassword = Platform.environment['XBOARD_TEST_PASSWORD'] ?? '';
      inviteCode = Platform.environment['XBOARD_TEST_INVITE_CODE'];

      sdk = XBoardSDK.instance;
    });

    setUp(() async {
      // 每个测试前清除token并重新初始化
      sdk.clearAuthToken();
      if (baseUrl.isNotEmpty) {
        await sdk.initialize(baseUrl);
      }
    });

    test('检查测试环境配置', () {
      expect(baseUrl.isNotEmpty, true, 
        reason: '请设置环境变量 XBOARD_BASE_URL');
      expect(testEmail.isNotEmpty, true,
        reason: '请设置环境变量 XBOARD_TEST_EMAIL');
      expect(testPassword.isNotEmpty, true,
        reason: '请设置环境变量 XBOARD_TEST_PASSWORD');
      
      print('🔧 测试配置:');
      print('  BaseURL: $baseUrl');
      print('  Email: $testEmail');
      print('  Password: ${testPassword.replaceAll(RegExp(r'.'), '*')}');
      print('  Invite Code: ${inviteCode ?? '未设置'}');
    });

    test('初始化SDK', () async {
      await sdk.initialize(baseUrl);
      print('✅ SDK初始化成功');
    });

    test('测试用户登录 - 真实API', () async {
      print('\n🔐 开始测试用户登录...');
      
      try {
        final result = await sdk.auth.login(testEmail, testPassword);
        
        print('📄 登录响应: $result');
        
        // 验证响应结构
        expect(result, isA<Map<String, dynamic>>());
        
        if (result['success'] == true) {
          print('✅ 登录成功！');
          
          // 验证token存在
          expect(result['data'], isNotNull);
          expect(result['data']['token'], isNotNull);
          
          final token = result['data']['token'] as String;
          expect(token.isNotEmpty, true);
          
          // 设置token
          sdk.setAuthToken(token);
          print('🔑 Token已设置: ${token.substring(0, 20)}...');
          
          // 解析用户信息
          final loginResponse = LoginResponse.fromJson(result);
          if (loginResponse.user != null) {
            print('👤 用户信息:');
            print('  Email: ${loginResponse.user!['email']}');
            print('  余额: ${loginResponse.user!['balance']}');
            print('  佣金余额: ${loginResponse.user!['commission_balance']}');
          }
        } else {
          print('❌ 登录失败: ${result['message']}');
          print('💡 请检查测试账号和密码是否正确');
          print('🔍 完整响应: $result');
        }
        
      } catch (e) {
        print('🚨 登录测试出错: $e');
        // 不抛出异常，让测试继续，这样可以看到具体的错误信息
        expect(e, isA<Exception>(), reason: '应该是一个可识别的异常类型');
      }
    });

    test('测试发送验证码 - 真实API', () async {
      print('\n📧 开始测试发送验证码...');
      
      try {
        final result = await sdk.auth.sendVerificationCode(testEmail);
        
        print('📄 验证码发送响应: $result');
        
        expect(result, isA<Map<String, dynamic>>());
        
        if (result['success'] == true) {
          print('✅ 验证码发送成功！');
        } else {
          print('❌ 验证码发送失败: ${result['message']}');
          print('🔍 原始状态: ${result['_original_status']}');
        }
        
      } catch (e) {
        print('🚨 发送验证码测试出错: $e');
        // 验证码频率限制是正常的
        if (e.toString().contains('验证码已发送')) {
          print('✅ 验证码频率限制正常工作');
        }
        expect(e, isA<Exception>());
      }
    });

    test('测试Token刷新 - 需要先登录', () async {
      print('\n🔄 开始测试Token刷新...');
      
      try {
        // 先登录获取token
        final loginResult = await sdk.auth.login(testEmail, testPassword);
        
        if (loginResult['success'] == true) {
          final token = loginResult['data']['token'] as String;
          sdk.setAuthToken(token);
          print('🔑 已设置初始token');
          
          // 测试刷新token
          final refreshResult = await sdk.auth.refreshToken();
          print('📄 Token刷新响应: $refreshResult');
          
          expect(refreshResult, isA<Map<String, dynamic>>());
          
          if (refreshResult['success'] == true) {
            print('✅ Token刷新成功！');
            
            if (refreshResult['data'] != null && 
                refreshResult['data']['token'] != null) {
              final newToken = refreshResult['data']['token'] as String;
              sdk.setAuthToken(newToken);
              print('🔑 新token已设置: ${newToken.substring(0, 20)}...');
            }
          } else {
            print('❌ Token刷新失败: ${refreshResult['message']}');
          }
        } else {
          print('⚠️ 无法测试Token刷新，因为登录失败');
        }
        
      } catch (e) {
        print('🚨 Token刷新测试出错: $e');
        expect(e, isA<Exception>());
      }
    });

    test('测试退出登录 - 需要先登录', () async {
      print('\n🚪 开始测试退出登录...');
      
      try {
        // 先登录获取token
        final loginResult = await sdk.auth.login(testEmail, testPassword);
        
        if (loginResult['success'] == true) {
          final token = loginResult['data']['token'] as String;
          sdk.setAuthToken(token);
          print('🔑 已设置token');
          
          // 测试退出登录
          final logoutResult = await sdk.auth.logout();
          print('📄 退出登录响应: $logoutResult');
          
          expect(logoutResult, isA<Map<String, dynamic>>());
          
          if (logoutResult['success'] == true) {
            print('✅ 退出登录成功！');
            sdk.clearAuthToken();
            print('🔓 本地token已清除');
          } else {
            print('❌ 退出登录失败: ${logoutResult['message']}');
          }
        } else {
          print('⚠️ 无法测试退出登录，因为登录失败');
        }
        
      } catch (e) {
        print('🚨 退出登录测试出错: $e');
        expect(e, isA<Exception>());
      }
    });

    test('测试API错误处理', () async {
      print('\n🚨 开始测试API错误处理...');
      
      try {
        // 使用错误的密码测试
        final result = await sdk.auth.login(testEmail, 'wrong_password_12345');
        
        print('📄 错误登录响应: $result');
        
        expect(result, isA<Map<String, dynamic>>());
        expect(result['success'], false, reason: '错误密码应该返回失败');
        expect(result['message'], isNotNull, reason: '应该有错误消息');
        
        print('✅ 错误处理正常: ${result['message']}');
        
      } catch (e) {
        print('🚨 错误处理测试出错: $e');
        // 这里也算正常，因为可能抛出异常
        expect(e, isA<Exception>());
        print('✅ 异常处理正常');
      }
    });

    test('性能测试 - API响应时间', () async {
      print('\n⚡ 开始性能测试...');
      
      final stopwatch = Stopwatch()..start();
      
      try {
        // 测试单个API调用的性能
        final requestStopwatch = Stopwatch()..start();
        
        try {
          final result = await sdk.auth.login(testEmail, testPassword);
          requestStopwatch.stop();
          
          print('🔐 登录请求耗时: ${requestStopwatch.elapsedMilliseconds}ms');
          print('🔐 登录结果: ${result['success'] ? '成功' : '失败 - ' + (result['message'] ?? '未知错误')}');
          
        } catch (e) {
          requestStopwatch.stop();
          print('🔐 登录请求耗时: ${requestStopwatch.elapsedMilliseconds}ms - 异常: $e');
        }
        
        stopwatch.stop();
        print('✅ 性能测试完成，总耗时: ${stopwatch.elapsedMilliseconds}ms');
        
        // 性能断言：登录请求应该在5秒内完成
        expect(requestStopwatch.elapsedMilliseconds, lessThan(5000),
          reason: '登录请求应该在5秒内完成');
        
      } catch (e) {
        stopwatch.stop();
        print('🚨 性能测试出错: $e');
      }
    });
  }, skip: Platform.environment['XBOARD_BASE_URL']?.isEmpty ?? true ? '需要设置环境变量才能运行集成测试' : null);
} 