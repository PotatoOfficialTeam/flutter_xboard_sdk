import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';
import 'package:flutter_xboard_sdk/src/core/token/memory_token_storage.dart';
import 'package:dio/dio.dart';

void main() {
  group('Token Management Integration Tests', () {
    late XBoardSDK sdk;
    late MockHttpServer mockServer;

    setUpAll(() async {
      // 启动模拟HTTP服务器
      mockServer = MockHttpServer();
      await mockServer.start();
    });

    tearDownAll(() async {
      await mockServer.stop();
    });

    setUp(() async {
      // 重置SDK实例
      sdk = XBoardSDK.instance;
      
      // 使用内存存储进行测试，避免文件系统依赖
      await sdk.initialize(
        mockServer.baseUrl,
        tokenConfig: TokenStorageConfig.test(),
      );
    });

    tearDown(() async {
      await sdk.clearTokens();
      sdk.dispose();
      mockServer.reset();
    });

    group('基本Token存储和读取', () {
      test('应该能保存和读取token', () async {
        // Arrange
        const accessToken = 'test_access_token';
        const refreshToken = 'test_refresh_token';
        final expiry = DateTime.now().add(const Duration(hours: 1));

        // Act
        await sdk.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
          expiry: expiry,
        );

        final retrievedToken = await sdk.getAuthToken();
        final isValid = await sdk.isTokenValid();

        // Assert
        expect(retrievedToken, equals(accessToken));
        expect(isValid, isTrue);
        expect(sdk.isAuthenticated, isTrue);
        expect(sdk.authState, equals(AuthState.authenticated));
      });

      test('应该能清除token', () async {
        // Arrange
        await sdk.saveTokens(
          accessToken: 'test_token',
          refreshToken: 'test_refresh',
          expiry: DateTime.now().add(const Duration(hours: 1)),
        );

        // Act
        await sdk.clearTokens();

        // Assert
        final token = await sdk.getAuthToken();
        expect(token, isNull);
        expect(sdk.isAuthenticated, isFalse);
        expect(sdk.authState, equals(AuthState.unauthenticated));
      });

      test('应该能检测过期token', () async {
        // Arrange
        const accessToken = 'expired_token';
        const refreshToken = 'refresh_token';
        final expiry = DateTime.now().subtract(const Duration(hours: 1)); // 已过期

        // Act
        await sdk.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
          expiry: expiry,
        );

        final isValid = await sdk.isTokenValid();

        // Assert
        expect(isValid, isFalse);
      });
    });

    group('便捷登录功能', () {
      test('登录成功应该自动保存token', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'password123';
        
        mockServer.mockLoginSuccess();

        // Act
        final success = await sdk.loginWithCredentials(email, password);

        // Assert
        expect(success, isTrue);
        expect(sdk.isAuthenticated, isTrue);
        
        final token = await sdk.getAuthToken();
        expect(token, isNotNull);
        expect(token, equals('mock_access_token'));
      });

      test('登录失败不应该保存token', () async {
        // Arrange
        const email = 'test@example.com';
        const password = 'wrong_password';
        
        mockServer.mockLoginFailure();

        // Act
        final success = await sdk.loginWithCredentials(email, password);

        // Assert
        expect(success, isFalse);
        expect(sdk.isAuthenticated, isFalse);
        
        final token = await sdk.getAuthToken();
        expect(token, isNull);
      });
    });

    group('Token自动刷新机制', () {
      test('即将过期的token应该自动刷新', () async {
        // Arrange
        const originalToken = 'original_token';
        const refreshToken = 'refresh_token';
        final expiry = DateTime.now().add(const Duration(minutes: 2)); // 即将过期
        
        await sdk.saveTokens(
          accessToken: originalToken,
          refreshToken: refreshToken,
          expiry: expiry,
        );
        
        mockServer.mockTokenRefreshSuccess();

        // Act
        final validToken = await sdk.tokenManager.getValidAccessToken();

        // Assert
        expect(validToken, isNotNull);
        expect(validToken, equals('new_access_token')); // 应该是刷新后的token
        expect(sdk.authState, equals(AuthState.authenticated));
      });

      test('刷新失败应该清除token', () async {
        // Arrange
        const originalToken = 'original_token';
        const refreshToken = 'invalid_refresh_token';
        final expiry = DateTime.now().add(const Duration(minutes: 2));
        
        await sdk.saveTokens(
          accessToken: originalToken,
          refreshToken: refreshToken,
          expiry: expiry,
        );
        
        mockServer.mockTokenRefreshFailure();

        // Act
        final validToken = await sdk.tokenManager.getValidAccessToken();

        // Assert
        expect(validToken, isNull);
        expect(sdk.authState, equals(AuthState.expired));
      });
    });

    group('HTTP拦截器认证', () {
      test('认证请求应该自动添加token', () async {
        // Arrange
        const accessToken = 'valid_token';
        await sdk.saveTokens(
          accessToken: accessToken,
          refreshToken: 'refresh_token',
          expiry: DateTime.now().add(const Duration(hours: 1)),
        );
        
        mockServer.mockProtectedEndpoint();

        // Act
        final response = await sdk.httpService.getRequest('/api/v1/user/info');

        // Assert
        expect(response['success'], isTrue);
        expect(mockServer.lastRequest?.headers.value('Authorization'), 
               equals('Bearer $accessToken'));
      });

      test('公开端点不应该添加token', () async {
        // Arrange
        mockServer.mockPublicEndpoint();

        // Act
        final response = await sdk.httpService.getRequest('/api/v1/guest/comm/config');

        // Assert
        expect(response['success'], isTrue);
        expect(mockServer.lastRequest?.headers.value('Authorization'), isNull);
      });

      test('401错误应该触发token刷新和重试', () async {
        // Arrange
        const expiredToken = 'expired_token';
        await sdk.saveTokens(
          accessToken: expiredToken,
          refreshToken: 'valid_refresh_token',
          expiry: DateTime.now().add(const Duration(hours: 1)),
        );
        
        mockServer.mockTokenRefreshSuccess();
        mockServer.mock401ThenSuccess();

        // Act
        final response = await sdk.httpService.getRequest('/api/v1/user/info');

        // Assert
        expect(response['success'], isTrue);
        expect(mockServer.requestCount, equals(3)); // 原请求 + 401 + 刷新token + 重试请求
      });
    });

    group('不同存储配置', () {
      test('内存存储应该正常工作', () async {
        // Arrange
        final memorySDK = XBoardSDK.instance;
        await memorySDK.initialize(
          mockServer.baseUrl,
          tokenConfig: TokenStorageConfig.test(),
        );

        // Act & Assert
        await memorySDK.saveTokens(
          accessToken: 'memory_token',
          refreshToken: 'memory_refresh',
          expiry: DateTime.now().add(const Duration(hours: 1)),
        );

        final token = await memorySDK.getAuthToken();
        expect(token, equals('memory_token'));

        memorySDK.dispose();
      });

      test('调试模式应该启用日志', () async {
        // Arrange
        final debugSDK = XBoardSDK.instance;
        await debugSDK.initialize(
          mockServer.baseUrl,
          tokenConfig: TokenStorageConfig.debug(enableLogging: true),
        );

        // Act
        await debugSDK.saveTokens(
          accessToken: 'debug_token',
          refreshToken: 'debug_refresh',
          expiry: DateTime.now().add(const Duration(hours: 1)),
        );

        // Assert
        final token = await debugSDK.getAuthToken();
        expect(token, equals('debug_token'));

        debugSDK.dispose();
      });
    });

    group('认证状态监听', () {
      test('应该能监听认证状态变化', () async {
        // Arrange
        final stateChanges = <AuthState>[];
        final subscription = sdk.authStateStream.listen(stateChanges.add);

        // Act
        await sdk.saveTokens(
          accessToken: 'test_token',
          refreshToken: 'test_refresh',
          expiry: DateTime.now().add(const Duration(hours: 1)),
        );

        await sdk.clearTokens();

        // Wait for state changes to propagate
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(stateChanges, contains(AuthState.authenticated));
        expect(stateChanges, contains(AuthState.unauthenticated));

        await subscription.cancel();
      });
    });

    group('错误处理和降级', () {
      test('存储错误应该被正确处理', () async {
        // 这个测试模拟存储失败的情况
        // 在实际应用中，如果secure storage不可用，应该有降级处理
        expect(() async {
          // 尝试使用不可用的存储
          final failingStorage = FailingTokenStorage();
          final tokenManager = TokenManager(storage: failingStorage);
          
          await tokenManager.saveTokens(
            accessToken: 'test',
            refreshToken: 'test',
            expiry: DateTime.now().add(const Duration(hours: 1)),
          );
        }, throwsA(isA<TokenStorageException>()));
      });

      test('网络错误应该有重试机制', () async {
        // Arrange
        await sdk.saveTokens(
          accessToken: 'valid_token',
          refreshToken: 'valid_refresh',
          expiry: DateTime.now().add(const Duration(hours: 1)),
        );
        
        mockServer.mockNetworkError();

        // Act & Assert
        expect(() async {
          await sdk.httpService.getRequest('/api/v1/user/info');
        }, throwsA(isA<NetworkException>()));
      });
    });
  });
}

/// 模拟HTTP服务器，用于测试
class MockHttpServer {
  static const int port = 8888;
  String get baseUrl => 'http://localhost:$port';
  
  int requestCount = 0;
  HttpRequest? lastRequest;
  
  final Map<String, dynamic> _responses = {};
  final List<String> _errors = [];

  Future<void> start() async {
    // 模拟服务器启动
    print('Mock server started at $baseUrl');
  }

  Future<void> stop() async {
    // 模拟服务器停止
    print('Mock server stopped');
  }

  void reset() {
    requestCount = 0;
    lastRequest = null;
    _responses.clear();
    _errors.clear();
  }

  void mockLoginSuccess() {
    _responses['/api/v1/passport/auth/login'] = {
      'success': true,
      'data': {
        'token': 'mock_access_token',
        'refresh_token': 'mock_refresh_token',
        'expired_at': DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
      }
    };
  }

  void mockLoginFailure() {
    _responses['/api/v1/passport/auth/login'] = {
      'success': false,
      'message': 'Invalid credentials'
    };
  }

  void mockTokenRefreshSuccess() {
    _responses['/api/v1/passport/auth/token'] = {
      'success': true,
      'data': {
        'access_token': 'new_access_token',
        'refresh_token': 'new_refresh_token',
        'expires_in': 3600,
      }
    };
  }

  void mockTokenRefreshFailure() {
    _responses['/api/v1/passport/auth/token'] = {
      'success': false,
      'message': 'Invalid refresh token'
    };
  }

  void mockProtectedEndpoint() {
    _responses['/api/v1/user/info'] = {
      'success': true,
      'data': {
        'id': 1,
        'email': 'test@example.com',
        'name': 'Test User'
      }
    };
  }

  void mockPublicEndpoint() {
    _responses['/api/v1/guest/comm/config'] = {
      'success': true,
      'data': {
        'app_name': 'XBoard',
        'version': '1.0.0'
      }
    };
  }

  void mock401ThenSuccess() {
    // 模拟第一次返回401，第二次成功
    _errors.add('401');
    _responses['/api/v1/user/info'] = {
      'success': true,
      'data': {
        'id': 1,
        'email': 'test@example.com',
        'name': 'Test User'
      }
    };
  }

  void mockNetworkError() {
    _errors.add('network_error');
  }
}

/// 模拟失败的存储实现，用于测试错误处理
class FailingTokenStorage implements TokenStorage {
  @override
  Future<void> saveAccessToken(String token) async {
    throw TokenStorageException('Storage not available');
  }

  @override
  Future<String?> getAccessToken() async {
    throw TokenStorageException('Storage not available');
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    throw TokenStorageException('Storage not available');
  }

  @override
  Future<String?> getRefreshToken() async {
    throw TokenStorageException('Storage not available');
  }

  @override
  Future<void> saveTokenExpiry(DateTime expiry) async {
    throw TokenStorageException('Storage not available');
  }

  @override
  Future<DateTime?> getTokenExpiry() async {
    throw TokenStorageException('Storage not available');
  }

  @override
  Future<void> clearTokens() async {
    throw TokenStorageException('Storage not available');
  }

  @override
  Future<bool> isAvailable() async {
    return false;
  }
}