import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_xboard_sdk/src/core/token/token_manager.dart';
import 'package:flutter_xboard_sdk/src/core/token/memory_token_storage.dart';
import 'package:flutter_xboard_sdk/src/core/token/token_storage.dart';

void main() {
  group('TokenManager Unit Tests', () {
    late TokenManager tokenManager;
    late MemoryTokenStorage storage;

    setUp(() {
      storage = MemoryTokenStorage();
      tokenManager = TokenManager(
        storage: storage,
        refreshBuffer: const Duration(minutes: 5),
        autoRefresh: true,
      );
    });

    tearDown(() {
      tokenManager.dispose();
    });

    group('Token存储基础功能', () {
      test('应该能保存和读取token信息', () async {
        // Arrange
        const accessToken = 'test_access_token';
        const refreshToken = 'test_refresh_token';
        final expiry = DateTime.now().add(const Duration(hours: 1));

        // Act
        await tokenManager.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
          expiry: expiry,
        );

        final retrievedAccessToken = await tokenManager.getAccessToken();
        final retrievedRefreshToken = await tokenManager.getRefreshToken();

        // Assert
        expect(retrievedAccessToken, equals(accessToken));
        expect(retrievedRefreshToken, equals(refreshToken));
        expect(tokenManager.isAuthenticated, isTrue);
        expect(tokenManager.currentState, equals(AuthState.authenticated));
      });

      test('应该能清除所有token', () async {
        // Arrange
        await tokenManager.saveTokens(
          accessToken: 'test_token',
          refreshToken: 'test_refresh',
          expiry: DateTime.now().add(const Duration(hours: 1)),
        );

        // Act
        await tokenManager.clearTokens();

        // Assert
        final accessToken = await tokenManager.getAccessToken();
        final refreshToken = await tokenManager.getRefreshToken();
        
        expect(accessToken, isNull);
        expect(refreshToken, isNull);
        expect(tokenManager.isAuthenticated, isFalse);
        expect(tokenManager.currentState, equals(AuthState.unauthenticated));
      });
    });

    group('Token有效性验证', () {
      test('有效token应该返回true', () async {
        // Arrange
        final futureExpiry = DateTime.now().add(const Duration(hours: 2));
        await tokenManager.saveTokens(
          accessToken: 'valid_token',
          refreshToken: 'valid_refresh',
          expiry: futureExpiry,
        );

        // Act
        final isValid = await tokenManager.isTokenValid();

        // Assert
        expect(isValid, isTrue);
      });

      test('过期token应该返回false', () async {
        // Arrange
        final pastExpiry = DateTime.now().subtract(const Duration(hours: 1));
        await tokenManager.saveTokens(
          accessToken: 'expired_token',
          refreshToken: 'expired_refresh',
          expiry: pastExpiry,
        );

        // Act
        final isValid = await tokenManager.isTokenValid();

        // Assert
        expect(isValid, isFalse);
      });

      test('即将过期的token应该被认为需要刷新', () async {
        // Arrange
        final soonExpiry = DateTime.now().add(const Duration(minutes: 3)); // 3分钟后过期，小于5分钟缓冲
        await tokenManager.saveTokens(
          accessToken: 'soon_expired_token',
          refreshToken: 'soon_expired_refresh',
          expiry: soonExpiry,
        );

        // 模拟刷新回调
        bool refreshCalled = false;
        tokenManager.setTokenRefreshCallback(() async {
          refreshCalled = true;
          return TokenInfo(
            accessToken: 'new_token',
            refreshToken: 'new_refresh',
            expiry: DateTime.now().add(const Duration(hours: 1)),
          );
        });

        // Act
        final validToken = await tokenManager.getValidAccessToken();

        // Assert
        expect(refreshCalled, isTrue);
        expect(validToken, equals('new_token'));
      });
    });

    group('Token自动刷新', () {
      test('成功刷新应该更新token', () async {
        // Arrange
        final soonExpiry = DateTime.now().add(const Duration(minutes: 3));
        await tokenManager.saveTokens(
          accessToken: 'old_token',
          refreshToken: 'old_refresh',
          expiry: soonExpiry,
        );

        const newAccessToken = 'new_access_token';
        const newRefreshToken = 'new_refresh_token';
        final newExpiry = DateTime.now().add(const Duration(hours: 1));

        tokenManager.setTokenRefreshCallback(() async {
          return TokenInfo(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
            expiry: newExpiry,
          );
        });

        // Act
        final validToken = await tokenManager.getValidAccessToken();

        // Assert
        expect(validToken, equals(newAccessToken));
        expect(await tokenManager.getAccessToken(), equals(newAccessToken));
        expect(await tokenManager.getRefreshToken(), equals(newRefreshToken));
        expect(tokenManager.currentState, equals(AuthState.authenticated));
      });

      test('刷新失败应该清除token并更新状态', () async {
        // Arrange
        final soonExpiry = DateTime.now().add(const Duration(minutes: 3));
        await tokenManager.saveTokens(
          accessToken: 'old_token',
          refreshToken: 'invalid_refresh',
          expiry: soonExpiry,
        );

        tokenManager.setTokenRefreshCallback(() async {
          return null; // 模拟刷新失败
        });

        // Act
        final validToken = await tokenManager.getValidAccessToken();

        // Assert
        expect(validToken, isNull);
        expect(tokenManager.currentState, equals(AuthState.expired));
      });

      test('应该避免并发刷新', () async {
        // Arrange
        final soonExpiry = DateTime.now().add(const Duration(minutes: 3));
        await tokenManager.saveTokens(
          accessToken: 'old_token',
          refreshToken: 'old_refresh',
          expiry: soonExpiry,
        );

        int refreshCallCount = 0;
        tokenManager.setTokenRefreshCallback(() async {
          refreshCallCount++;
          await Future.delayed(const Duration(milliseconds: 100)); // 模拟网络延迟
          return TokenInfo(
            accessToken: 'new_token_$refreshCallCount',
            refreshToken: 'new_refresh_$refreshCallCount',
            expiry: DateTime.now().add(const Duration(hours: 1)),
          );
        });

        // Act - 同时发起多个请求
        final futures = List.generate(3, (_) => tokenManager.getValidAccessToken());
        final results = await Future.wait(futures);

        // Assert
        expect(refreshCallCount, equals(1)); // 应该只调用一次刷新
        expect(results.every((token) => token == 'new_token_1'), isTrue); // 所有请求都应该得到相同的新token
      });
    });

    group('认证状态管理', () {
      test('应该正确触发状态变化事件', () async {
        // Arrange
        final stateChanges = <AuthState>[];
        final subscription = tokenManager.authStateStream.listen(stateChanges.add);

        // Act
        await tokenManager.saveTokens(
          accessToken: 'test_token',
          refreshToken: 'test_refresh',
          expiry: DateTime.now().add(const Duration(hours: 1)),
        );

        await tokenManager.clearTokens();

        // Wait for async operations
        await Future.delayed(const Duration(milliseconds: 50));

        // Assert
        expect(stateChanges, contains(AuthState.authenticated));
        expect(stateChanges, contains(AuthState.unauthenticated));

        await subscription.cancel();
      });

      test('刷新过程中应该显示正确状态', () async {
        // Arrange
        final stateChanges = <AuthState>[];
        final subscription = tokenManager.authStateStream.listen(stateChanges.add);

        final soonExpiry = DateTime.now().add(const Duration(minutes: 3));
        await tokenManager.saveTokens(
          accessToken: 'old_token',
          refreshToken: 'old_refresh',
          expiry: soonExpiry,
        );

        tokenManager.setTokenRefreshCallback(() async {
          await Future.delayed(const Duration(milliseconds: 100));
          return TokenInfo(
            accessToken: 'new_token',
            refreshToken: 'new_refresh',
            expiry: DateTime.now().add(const Duration(hours: 1)),
          );
        });

        // Act
        await tokenManager.getValidAccessToken();
        await Future.delayed(const Duration(milliseconds: 150));

        // Assert
        expect(stateChanges, contains(AuthState.refreshing));
        expect(stateChanges.last, equals(AuthState.authenticated));

        await subscription.cancel();
      });
    });

    group('错误处理', () {
      test('存储错误应该被正确处理', () async {
        // Arrange
        final failingStorage = FailingTokenStorage();
        final failingTokenManager = TokenManager(storage: failingStorage);

        // Act & Assert
        expect(
          () async => await failingTokenManager.saveTokens(
            accessToken: 'test',
            refreshToken: 'test',
            expiry: DateTime.now().add(const Duration(hours: 1)),
          ),
          throwsA(isA<TokenStorageException>()),
        );

        failingTokenManager.dispose();
      });

      test('获取token时的存储错误应该返回null', () async {
        // Arrange
        final failingStorage = FailingTokenStorage();
        final failingTokenManager = TokenManager(storage: failingStorage);

        // Act
        final token = await failingTokenManager.getAccessToken();

        // Assert
        expect(token, isNull);
        expect(failingTokenManager.currentState, equals(AuthState.failed));

        failingTokenManager.dispose();
      });

      test('无刷新回调时应该正确处理', () async {
        // Arrange
        final soonExpiry = DateTime.now().add(const Duration(minutes: 3));
        await tokenManager.saveTokens(
          accessToken: 'old_token',
          refreshToken: 'old_refresh',
          expiry: soonExpiry,
        );

        // 不设置刷新回调

        // Act
        final validToken = await tokenManager.getValidAccessToken();

        // Assert
        expect(validToken, isNull);
        expect(tokenManager.currentState, equals(AuthState.expired));
      });
    });

    group('配置选项', () {
      test('禁用自动刷新时不应该刷新token', () async {
        // Arrange
        final noAutoRefreshManager = TokenManager(
          storage: storage,
          autoRefresh: false,
        );

        final soonExpiry = DateTime.now().add(const Duration(minutes: 3));
        await noAutoRefreshManager.saveTokens(
          accessToken: 'old_token',
          refreshToken: 'old_refresh',
          expiry: soonExpiry,
        );

        bool refreshCalled = false;
        noAutoRefreshManager.setTokenRefreshCallback(() async {
          refreshCalled = true;
          return null;
        });

        // Act
        final validToken = await noAutoRefreshManager.getValidAccessToken();

        // Assert
        expect(refreshCalled, isFalse);
        expect(validToken, isNull);

        noAutoRefreshManager.dispose();
      });

      test('自定义刷新缓冲时间应该生效', () async {
        // Arrange
        final customBufferManager = TokenManager(
          storage: storage,
          refreshBuffer: const Duration(minutes: 10), // 10分钟缓冲
        );

        final expiry = DateTime.now().add(const Duration(minutes: 8)); // 8分钟后过期
        await customBufferManager.saveTokens(
          accessToken: 'token',
          refreshToken: 'refresh',
          expiry: expiry,
        );

        bool refreshCalled = false;
        customBufferManager.setTokenRefreshCallback(() async {
          refreshCalled = true;
          return TokenInfo(
            accessToken: 'new_token',
            refreshToken: 'new_refresh',
            expiry: DateTime.now().add(const Duration(hours: 1)),
          );
        });

        // Act
        await customBufferManager.getValidAccessToken();

        // Assert
        expect(refreshCalled, isTrue); // 应该刷新，因为8分钟 < 10分钟缓冲

        customBufferManager.dispose();
      });
    });
  });
}

/// 模拟失败的存储实现
class FailingTokenStorage implements TokenStorage {
  @override
  Future<void> saveAccessToken(String token) async {
    throw TokenStorageException('Storage operation failed');
  }

  @override
  Future<String?> getAccessToken() async {
    throw TokenStorageException('Storage operation failed');
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    throw TokenStorageException('Storage operation failed');
  }

  @override
  Future<String?> getRefreshToken() async {
    throw TokenStorageException('Storage operation failed');
  }

  @override
  Future<void> saveTokenExpiry(DateTime expiry) async {
    throw TokenStorageException('Storage operation failed');
  }

  @override
  Future<DateTime?> getTokenExpiry() async {
    throw TokenStorageException('Storage operation failed');
  }

  @override
  Future<void> clearTokens() async {
    throw TokenStorageException('Storage operation failed');
  }

  @override
  Future<bool> isAvailable() async {
    return false;
  }
}