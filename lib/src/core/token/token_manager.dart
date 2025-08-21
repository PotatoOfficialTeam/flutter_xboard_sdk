import 'dart:async';
import 'token_storage.dart';
import 'shared_preferences_token_storage.dart';

/// 认证状态枚举
enum AuthState {
  /// 未认证
  unauthenticated,
  /// 已认证
  authenticated,
  /// Token已过期
  expired,
  /// 刷新中
  refreshing,
  /// 认证失败
  failed,
}

/// Token信息模型
class TokenInfo {
  final String accessToken;
  final String refreshToken;
  final DateTime expiry;

  const TokenInfo({
    required this.accessToken,
    required this.refreshToken,
    required this.expiry,
  });

  /// 检查token是否即将过期（默认5分钟缓冲时间）
  bool isExpiringSoon([Duration buffer = const Duration(minutes: 5)]) {
    return DateTime.now().isAfter(expiry.subtract(buffer));
  }

  /// 检查token是否已过期
  bool get isExpired => DateTime.now().isAfter(expiry);

  @override
  String toString() => 'TokenInfo(expiry: $expiry, isExpired: $isExpired)';
}

/// Token管理器
/// 负责token的存储、刷新、验证等所有生命周期管理
class TokenManager {
  final TokenStorage _storage;
  final Duration _refreshBuffer;
  final bool _autoRefresh;
  final void Function()? _onTokenExpired;
  final void Function()? _onRefreshFailed;

  /// 认证状态流控制器
  final StreamController<AuthState> _authStateController = StreamController<AuthState>.broadcast();

  /// 当前认证状态
  AuthState _currentState = AuthState.unauthenticated;

  /// 刷新操作的Completer，避免并发刷新
  Completer<String?>? _refreshCompleter;

  /// Token刷新回调函数
  Future<TokenInfo?> Function()? _tokenRefreshCallback;

  TokenManager({
    TokenStorage? storage,
    Duration refreshBuffer = const Duration(minutes: 5),
    bool autoRefresh = true,
    void Function()? onTokenExpired,
    void Function()? onRefreshFailed,
  })  : _storage = storage ?? SharedPreferencesTokenStorage(),
        _refreshBuffer = refreshBuffer,
        _autoRefresh = autoRefresh,
        _onTokenExpired = onTokenExpired,
        _onRefreshFailed = onRefreshFailed {
    
    // 初始化时检查已存储的token
    _initializeTokenState();
  }

  /// 认证状态流
  Stream<AuthState> get authStateStream => _authStateController.stream;

  /// 当前认证状态
  AuthState get currentState => _currentState;

  /// 是否已认证
  bool get isAuthenticated => _currentState == AuthState.authenticated;

  /// 设置token刷新回调
  void setTokenRefreshCallback(Future<TokenInfo?> Function() callback) {
    _tokenRefreshCallback = callback;
  }

  /// 保存token信息
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

  /// 获取有效的访问token
  /// 如果token即将过期或已过期，会自动尝试刷新
  Future<String?> getValidAccessToken() async {
    try {
      // 检查当前token状态
      final tokenInfo = await _getCurrentTokenInfo();
      if (tokenInfo == null) {
        _updateAuthState(AuthState.unauthenticated);
        return null;
      }

      // 如果token有效且未即将过期，直接返回
      if (!tokenInfo.isExpiringSoon(_refreshBuffer)) {
        _updateAuthState(AuthState.authenticated);
        return tokenInfo.accessToken;
      }

      // token即将过期或已过期，尝试刷新
      if (_autoRefresh && _tokenRefreshCallback != null) {
        final refreshedToken = await _refreshAccessToken();
        if (refreshedToken != null) {
          return refreshedToken;
        }
      }

      // 刷新失败，token已过期
      _updateAuthState(AuthState.expired);
      _onTokenExpired?.call();
      return null;
    } catch (e) {
      print('Failed to get valid access token: $e');
      _updateAuthState(AuthState.failed);
      return null;
    }
  }

  /// 获取访问token（不进行自动刷新）
  Future<String?> getAccessToken() async {
    try {
      return await _storage.getAccessToken();
    } catch (e) {
      print('Failed to get access token: $e');
      return null;
    }
  }

  /// 获取刷新token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.getRefreshToken();
    } catch (e) {
      print('Failed to get refresh token: $e');
      return null;
    }
  }

  /// 检查token是否有效
  Future<bool> isTokenValid() async {
    final tokenInfo = await _getCurrentTokenInfo();
    if (tokenInfo == null) return false;
    
    return !tokenInfo.isExpired;
  }

  /// 手动刷新token
  Future<String?> refreshToken() async {
    return await _refreshAccessToken();
  }

  /// 清除所有token
  Future<void> clearTokens() async {
    try {
      await _storage.clearTokens();
      _updateAuthState(AuthState.unauthenticated);
    } catch (e) {
      print('Failed to clear tokens: $e');
      rethrow;
    }
  }

  /// 释放资源
  void dispose() {
    _authStateController.close();
  }

  /// 初始化token状态
  Future<void> _initializeTokenState() async {
    try {
      // Storage initialization complete
      
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

  /// 获取当前token信息
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

  /// 刷新访问token
  Future<String?> _refreshAccessToken() async {
    // 如果已经在刷新中，等待之前的刷新完成
    if (_refreshCompleter != null) {
      return await _refreshCompleter!.future;
    }

    _refreshCompleter = Completer<String?>();
    _updateAuthState(AuthState.refreshing);

    try {
      if (_tokenRefreshCallback == null) {
        throw Exception('Token refresh callback not set');
      }

      final newTokenInfo = await _tokenRefreshCallback!();
      if (newTokenInfo != null) {
        await saveTokens(
          accessToken: newTokenInfo.accessToken,
          refreshToken: newTokenInfo.refreshToken,
          expiry: newTokenInfo.expiry,
        );
        
        _refreshCompleter!.complete(newTokenInfo.accessToken);
        return newTokenInfo.accessToken;
      } else {
        _updateAuthState(AuthState.expired);
        _onRefreshFailed?.call();
        _refreshCompleter!.complete(null);
        return null;
      }
    } catch (e) {
      print('Failed to refresh access token: $e');
      _updateAuthState(AuthState.failed);
      _onRefreshFailed?.call();
      _refreshCompleter!.complete(null);
      return null;
    } finally {
      _refreshCompleter = null;
    }
  }

  /// 更新认证状态
  void _updateAuthState(AuthState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      _authStateController.add(newState);
      print('Auth state changed to: $newState');
    }
  }
}