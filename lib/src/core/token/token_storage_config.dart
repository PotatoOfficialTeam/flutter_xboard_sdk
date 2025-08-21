import 'token_storage.dart';
import 'memory_token_storage.dart';
import 'shared_preferences_token_storage.dart';

/// Token存储配置类
/// 
/// 使用 SharedPreferencesTokenStorage 作为默认实现，提供：
/// - 跨平台一致性
/// - 无需特殊权限
/// - 简单可靠的存储
/// 
/// 支持多种配置选项以适应不同使用场景。

/// Token存储配置类
/// 提供不同场景下的token存储配置选项
class TokenStorageConfig {
  /// Token存储实现
  final TokenStorage storage;

  /// 是否启用自动刷新
  final bool autoRefresh;

  /// Token刷新缓冲时间（在过期前多久开始刷新）
  final Duration refreshBuffer;

  /// Token过期回调
  final void Function()? onTokenExpired;

  /// Token刷新失败回调
  final void Function()? onRefreshFailed;

  const TokenStorageConfig({
    required this.storage,
    this.autoRefresh = true,
    this.refreshBuffer = const Duration(minutes: 5),
    this.onTokenExpired,
    this.onRefreshFailed,
  });

  /// 默认配置 - 使用SharedPreferences存储（简单可靠）
  factory TokenStorageConfig.defaultConfig() {
    return TokenStorageConfig(
      storage: SharedPreferencesTokenStorage(),
      autoRefresh: true,
      refreshBuffer: const Duration(minutes: 5),
    );
  }

  /// 生产环境配置 - 使用SharedPreferences（简单可靠）
  factory TokenStorageConfig.production({
    void Function()? onTokenExpired,
    void Function()? onRefreshFailed,
  }) {
    return TokenStorageConfig(
      storage: SharedPreferencesTokenStorage(),
      autoRefresh: true,
      refreshBuffer: const Duration(minutes: 3),
      onTokenExpired: onTokenExpired,
      onRefreshFailed: onRefreshFailed,
    );
  }

  /// 开发环境配置 - 调试友好
  factory TokenStorageConfig.debug({
    bool enableLogging = true,
    void Function()? onTokenExpired,
    void Function()? onRefreshFailed,
  }) {
    return TokenStorageConfig(
      storage: enableLogging 
        ? DebugTokenStorage(SharedPreferencesTokenStorage())
        : SharedPreferencesTokenStorage(),
      autoRefresh: true,
      refreshBuffer: const Duration(minutes: 10),
      onTokenExpired: onTokenExpired,
      onRefreshFailed: onRefreshFailed,
    );
  }

  /// 测试环境配置 - 内存存储
  factory TokenStorageConfig.test({
    void Function()? onTokenExpired,
    void Function()? onRefreshFailed,
  }) {
    return TokenStorageConfig(
      storage: MemoryTokenStorage(),
      autoRefresh: true,
      refreshBuffer: const Duration(minutes: 1),
      onTokenExpired: onTokenExpired,
      onRefreshFailed: onRefreshFailed,
    );
  }

  /// 手动管理配置 - 不自动刷新
  factory TokenStorageConfig.manual({
    TokenStorage? storage,
    void Function()? onTokenExpired,
  }) {
    return TokenStorageConfig(
      storage: storage ?? SharedPreferencesTokenStorage(),
      autoRefresh: false,
      refreshBuffer: Duration.zero,
      onTokenExpired: onTokenExpired,
    );
  }

  /// 自定义配置
  factory TokenStorageConfig.custom({
    required TokenStorage storage,
    bool autoRefresh = true,
    Duration refreshBuffer = const Duration(minutes: 5),
    void Function()? onTokenExpired,
    void Function()? onRefreshFailed,
  }) {
    return TokenStorageConfig(
      storage: storage,
      autoRefresh: autoRefresh,
      refreshBuffer: refreshBuffer,
      onTokenExpired: onTokenExpired,
      onRefreshFailed: onRefreshFailed,
    );
  }

  @override
  String toString() {
    return 'TokenStorageConfig('
        'storage: ${storage.runtimeType}, '
        'autoRefresh: $autoRefresh, '
        'refreshBuffer: $refreshBuffer'
        ')';
  }
}

/// 调试用的Token存储装饰器
/// 包装其他存储实现，添加日志功能
class DebugTokenStorage implements TokenStorage {
  final TokenStorage _delegate;

  DebugTokenStorage(this._delegate);

  @override
  Future<void> saveAccessToken(String token) async {
    print('[TokenStorage] Saving access token: ${token.substring(0, 10)}...');
    return _delegate.saveAccessToken(token);
  }

  @override
  Future<String?> getAccessToken() async {
    final token = await _delegate.getAccessToken();
    print('[TokenStorage] Retrieved access token: ${token != null ? '${token.substring(0, 10)}...' : 'null'}');
    return token;
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    print('[TokenStorage] Saving refresh token: ${token.substring(0, 10)}...');
    return _delegate.saveRefreshToken(token);
  }

  @override
  Future<String?> getRefreshToken() async {
    final token = await _delegate.getRefreshToken();
    print('[TokenStorage] Retrieved refresh token: ${token != null ? '${token.substring(0, 10)}...' : 'null'}');
    return token;
  }

  @override
  Future<void> saveTokenExpiry(DateTime expiry) async {
    print('[TokenStorage] Saving token expiry: $expiry');
    return _delegate.saveTokenExpiry(expiry);
  }

  @override
  Future<DateTime?> getTokenExpiry() async {
    final expiry = await _delegate.getTokenExpiry();
    print('[TokenStorage] Retrieved token expiry: $expiry');
    return expiry;
  }

  @override
  Future<void> clearTokens() async {
    print('[TokenStorage] Clearing all tokens');
    return _delegate.clearTokens();
  }

  @override
  Future<bool> isAvailable() async {
    final available = await _delegate.isAvailable();
    print('[TokenStorage] Storage available: $available');
    return available;
  }
}