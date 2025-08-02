import 'dart:async';
import '../lib/src/core/token/memory_token_storage.dart';
import '../lib/src/core/token/token_storage.dart';

/// 认证状态枚举 - 复制以避免Flutter依赖
enum AuthState {
  unauthenticated,
  authenticated,
  expired,
  refreshing,
  failed,
}

/// Token信息模型 - 复制以避免Flutter依赖
class TokenInfo {
  final String accessToken;
  final String refreshToken;
  final DateTime expiry;

  const TokenInfo({
    required this.accessToken,
    required this.refreshToken,
    required this.expiry,
  });

  bool isExpiringSoon([Duration buffer = const Duration(minutes: 5)]) {
    return DateTime.now().isAfter(expiry.subtract(buffer));
  }

  bool get isExpired => DateTime.now().isAfter(expiry);
}

/// 简化的TokenManager - 不依赖Flutter
class SimpleTokenManager {
  final TokenStorage _storage;
  final Duration _refreshBuffer;
  final bool _autoRefresh;

  final StreamController<AuthState> _authStateController = StreamController<AuthState>.broadcast();
  AuthState _currentState = AuthState.unauthenticated;
  Future<TokenInfo?> Function()? _tokenRefreshCallback;

  SimpleTokenManager({
    TokenStorage? storage,
    Duration refreshBuffer = const Duration(minutes: 5),
    bool autoRefresh = true,
  })  : _storage = storage ?? MemoryTokenStorage(),
        _refreshBuffer = refreshBuffer,
        _autoRefresh = autoRefresh {
    _initializeTokenState();
  }

  Stream<AuthState> get authStateStream => _authStateController.stream;
  AuthState get currentState => _currentState;
  bool get isAuthenticated => _currentState == AuthState.authenticated;

  void setTokenRefreshCallback(Future<TokenInfo?> Function() callback) {
    _tokenRefreshCallback = callback;
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiry,
  }) async {
    try {
      await Future.wait([
        _storage.saveAccessToken(accessToken),
        _storage.saveRefreshToken(refreshToken),
        _storage.saveTokenExpiry(expiry),
      ]);
      _updateAuthState(AuthState.authenticated);
    } catch (e) {
      print('Failed to save tokens: $e');
      _updateAuthState(AuthState.failed);
      rethrow;
    }
  }

  Future<String?> getAccessToken() async {
    try {
      return await _storage.getAccessToken();
    } catch (e) {
      print('Failed to get access token: $e');
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.getRefreshToken();
    } catch (e) {
      print('Failed to get refresh token: $e');
      return null;
    }
  }

  Future<bool> isTokenValid() async {
    final tokenInfo = await _getCurrentTokenInfo();
    if (tokenInfo == null) return false;
    return !tokenInfo.isExpired;
  }

  Future<void> clearTokens() async {
    try {
      await _storage.clearTokens();
      _updateAuthState(AuthState.unauthenticated);
    } catch (e) {
      print('Failed to clear tokens: $e');
      rethrow;
    }
  }

  void dispose() {
    _authStateController.close();
  }

  Future<void> _initializeTokenState() async {
    try {
      final tokenInfo = await _getCurrentTokenInfo();
      if (tokenInfo == null) {
        _updateAuthState(AuthState.unauthenticated);
      } else if (tokenInfo.isExpired) {
        _updateAuthState(AuthState.expired);
      } else {
        _updateAuthState(AuthState.authenticated);
      }
    } catch (e) {
      print('Failed to initialize token state: $e');
      _updateAuthState(AuthState.failed);
    }
  }

  Future<TokenInfo?> _getCurrentTokenInfo() async {
    try {
      final futures = await Future.wait([
        _storage.getAccessToken(),
        _storage.getRefreshToken(),
        _storage.getTokenExpiry(),
      ]);

      final accessToken = futures[0] as String?;
      final refreshToken = futures[1] as String?;
      final expiry = futures[2] as DateTime?;

      if (accessToken != null && refreshToken != null && expiry != null) {
        return TokenInfo(
          accessToken: accessToken,
          refreshToken: refreshToken,
          expiry: expiry,
        );
      }
      return null;
    } catch (e) {
      print('Failed to get current token info: $e');
      return null;
    }
  }

  void _updateAuthState(AuthState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      _authStateController.add(newState);
      print('Auth state changed to: $newState');
    }
  }
}

void main() async {
  print('🚀 Starting Token Management Tests...\n');

  await testBasicTokenStorage();
  await testTokenManager();
  await testTokenValidation();
  
  print('\n✅ All tests completed successfully!');
}

/// 测试基本token存储功能
Future<void> testBasicTokenStorage() async {
  print('📦 Testing Basic Token Storage...');
  
  final storage = MemoryTokenStorage();
  
  // 测试存储和读取
  const accessToken = 'test_access_token';
  const refreshToken = 'test_refresh_token';
  final expiry = DateTime.now().add(const Duration(hours: 1));
  
  await storage.saveAccessToken(accessToken);
  await storage.saveRefreshToken(refreshToken);
  await storage.saveTokenExpiry(expiry);
  
  final retrievedAccessToken = await storage.getAccessToken();
  final retrievedRefreshToken = await storage.getRefreshToken();
  final retrievedExpiry = await storage.getTokenExpiry();
  
  myAssert(retrievedAccessToken == accessToken, 'Access token mismatch');
  myAssert(retrievedRefreshToken == refreshToken, 'Refresh token mismatch');
  myAssert(retrievedExpiry?.millisecondsSinceEpoch == expiry.millisecondsSinceEpoch, 'Expiry time mismatch');
  
  // 测试清除
  await storage.clearTokens();
  final clearedToken = await storage.getAccessToken();
  myAssert(clearedToken == null, 'Token should be null after clearing');
  
  print('✅ Basic Token Storage: PASSED');
}

/// 测试TokenManager功能
Future<void> testTokenManager() async {
  print('🔧 Testing Token Manager...');
  
  final storage = MemoryTokenStorage();
  final tokenManager = SimpleTokenManager(
    storage: storage,
    refreshBuffer: const Duration(minutes: 5),
    autoRefresh: true,
  );
  
  // 测试状态变化
  final stateChanges = <AuthState>[];
  final subscription = tokenManager.authStateStream.listen(stateChanges.add);
  
  // 测试保存token
  await tokenManager.saveTokens(
    accessToken: 'test_token',
    refreshToken: 'test_refresh',
    expiry: DateTime.now().add(const Duration(hours: 1)),
  );
  
  myAssert(tokenManager.isAuthenticated, 'Should be authenticated after saving tokens');
  myAssert(tokenManager.currentState == AuthState.authenticated, 'State should be authenticated');
  
  // 测试token有效性
  final isValid = await tokenManager.isTokenValid();
  myAssert(isValid, 'Token should be valid');
  
  // 测试获取token
  final token = await tokenManager.getAccessToken();
  myAssert(token == 'test_token', 'Retrieved token should match saved token');
  
  // 测试清除token
  await tokenManager.clearTokens();
  myAssert(!tokenManager.isAuthenticated, 'Should not be authenticated after clearing');
  myAssert(tokenManager.currentState == AuthState.unauthenticated, 'State should be unauthenticated');
  
  await subscription.cancel();
  tokenManager.dispose();
  
  print('✅ Token Manager: PASSED');
}

/// 测试token有效性检查
Future<void> testTokenValidation() async {
  print('⏰ Testing Token Validation...');
  
  final storage = MemoryTokenStorage();
  final tokenManager = SimpleTokenManager(storage: storage);
  
  // 测试过期token
  final pastExpiry = DateTime.now().subtract(const Duration(hours: 1));
  await tokenManager.saveTokens(
    accessToken: 'expired_token',
    refreshToken: 'expired_refresh',
    expiry: pastExpiry,
  );
  
  final isExpiredValid = await tokenManager.isTokenValid();
  myAssert(!isExpiredValid, 'Expired token should not be valid');
  
  // 测试有效token
  final futureExpiry = DateTime.now().add(const Duration(hours: 1));
  await tokenManager.saveTokens(
    accessToken: 'valid_token',
    refreshToken: 'valid_refresh',
    expiry: futureExpiry,
  );
  
  final isValidValid = await tokenManager.isTokenValid();
  myAssert(isValidValid, 'Valid token should be valid');
  
  tokenManager.dispose();
  
  print('✅ Token Validation: PASSED');
}

/// 简单的断言函数
void myAssert(bool condition, String message) {
  if (!condition) {
    throw Exception('Assertion failed: $message');
  }
}