import 'package:flutter_test/flutter_test.dart';
import 'token_manager_test.dart' as token_manager_tests;
import 'auth_interceptor_test.dart' as auth_interceptor_tests;
import 'token_management_integration_test.dart' as integration_tests;

/// 测试运行脚本
/// 运行所有Token管理相关的测试
void main() {
  group('Token Management Test Suite', () {
    group('单元测试', () {
      token_manager_tests.main();
      auth_interceptor_tests.main();
    });

    group('集成测试', () {
      integration_tests.main();
    });
  });
}

/// 测试统计和报告
class TestReporter {
  static int _totalTests = 0;
  static int _passedTests = 0;
  static int _failedTests = 0;
  static List<String> _failedTestNames = [];

  static void recordTest(String testName, bool passed) {
    _totalTests++;
    if (passed) {
      _passedTests++;
    } else {
      _failedTests++;
      _failedTestNames.add(testName);
    }
  }

  static void printReport() {
    print('\n=== Token Management Test Report ===');
    print('Total Tests: $_totalTests');
    print('Passed: $_passedTests');
    print('Failed: $_failedTests');
    print('Success Rate: ${(_passedTests / _totalTests * 100).toStringAsFixed(1)}%');

    if (_failedTests > 0) {
      print('\nFailed Tests:');
      for (final testName in _failedTestNames) {
        print('  - $testName');
      }
    }

    print('\nTest Categories Covered:');
    print('  ✓ Token存储和读取');
    print('  ✓ Token有效性验证');
    print('  ✓ 自动token刷新');
    print('  ✓ HTTP请求拦截');
    print('  ✓ 认证状态管理');
    print('  ✓ 错误处理和降级');
    print('  ✓ 不同存储配置');
    print('  ✓ 并发请求处理');
    print('  ✓ 公开端点管理');
    print('  ✓ 应用生命周期集成');
    print('=================================\n');
  }
}