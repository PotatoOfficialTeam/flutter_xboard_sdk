import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'token_storage.dart';

/// 安全Token存储实现
/// 使用flutter_secure_storage提供系统级加密存储
class SecureTokenStorage implements TokenStorage {
  static const String _accessTokenKey = 'xboard_access_token';
  static const String _refreshTokenKey = 'xboard_refresh_token';
  static const String _expiryTimeKey = 'xboard_token_expiry';

  late final FlutterSecureStorage _secureStorage;
  
  /// 内存缓存，避免频繁IO操作
  String? _cachedAccessToken;
  String? _cachedRefreshToken;
  DateTime? _cachedExpiryTime;
  bool _cacheLoaded = false;

  SecureTokenStorage({
    AndroidOptions? androidOptions,
    IOSOptions? iosOptions,
    LinuxOptions? linuxOptions,
    WindowsOptions? windowsOptions,
    MacOsOptions? macOsOptions,
    WebOptions? webOptions,
  }) {
    _secureStorage = FlutterSecureStorage(
      aOptions: androidOptions ?? _defaultAndroidOptions,
      iOptions: iosOptions ?? _defaultIOSOptions,
      lOptions: linuxOptions ?? _defaultLinuxOptions,
      wOptions: windowsOptions ?? _defaultWindowsOptions,
      mOptions: macOsOptions ?? _defaultMacOSOptions,
      webOptions: webOptions ?? _defaultWebOptions,
    );
  }

  /// 默认Android安全选项
  static const AndroidOptions _defaultAndroidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
    keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
    storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
  );

  /// 默认iOS安全选项
  static const IOSOptions _defaultIOSOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
    synchronizable: false,
  );

  /// 默认Linux选项
  static const LinuxOptions _defaultLinuxOptions = LinuxOptions();

  /// 默认Windows选项
  static const WindowsOptions _defaultWindowsOptions = WindowsOptions();

  /// 默认macOS选项
  static const MacOsOptions _defaultMacOSOptions = MacOsOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
    synchronizable: false,
  );

  /// 默认Web选项
  static const WebOptions _defaultWebOptions = WebOptions();

  @override
  Future<void> saveAccessToken(String token) async {
    try {
      _cachedAccessToken = token;
      await _secureStorage.write(key: _accessTokenKey, value: token);
    } catch (e) {
      throw TokenStorageException('Failed to save access token', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      if (_cachedAccessToken != null && _cacheLoaded) {
        return _cachedAccessToken;
      }
      
      _cachedAccessToken = await _secureStorage.read(key: _accessTokenKey);
      return _cachedAccessToken;
    } catch (e) {
      throw TokenStorageException('Failed to get access token', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    try {
      _cachedRefreshToken = token;
      await _secureStorage.write(key: _refreshTokenKey, value: token);
    } catch (e) {
      throw TokenStorageException('Failed to save refresh token', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      if (_cachedRefreshToken != null && _cacheLoaded) {
        return _cachedRefreshToken;
      }
      
      _cachedRefreshToken = await _secureStorage.read(key: _refreshTokenKey);
      return _cachedRefreshToken;
    } catch (e) {
      throw TokenStorageException('Failed to get refresh token', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<void> saveTokenExpiry(DateTime expiry) async {
    try {
      _cachedExpiryTime = expiry;
      await _secureStorage.write(key: _expiryTimeKey, value: expiry.toIso8601String());
    } catch (e) {
      throw TokenStorageException('Failed to save token expiry', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<DateTime?> getTokenExpiry() async {
    try {
      if (_cachedExpiryTime != null && _cacheLoaded) {
        return _cachedExpiryTime;
      }
      
      final expiryString = await _secureStorage.read(key: _expiryTimeKey);
      if (expiryString != null) {
        _cachedExpiryTime = DateTime.parse(expiryString);
      }
      return _cachedExpiryTime;
    } catch (e) {
      throw TokenStorageException('Failed to get token expiry', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<void> clearTokens() async {
    try {
      // 清除内存缓存
      _cachedAccessToken = null;
      _cachedRefreshToken = null;
      _cachedExpiryTime = null;
      _cacheLoaded = false;
      
      // 清除持久化存储
      await Future.wait([
        _secureStorage.delete(key: _accessTokenKey),
        _secureStorage.delete(key: _refreshTokenKey),
        _secureStorage.delete(key: _expiryTimeKey),
      ]);
    } catch (e) {
      throw TokenStorageException('Failed to clear tokens', e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      // 尝试读写测试存储是否可用
      const testKey = 'xboard_storage_test';
      const testValue = 'test';
      
      await _secureStorage.write(key: testKey, value: testValue);
      final result = await _secureStorage.read(key: testKey);
      await _secureStorage.delete(key: testKey);
      
      return result == testValue;
    } catch (e) {
      return false;
    }
  }

  /// 预加载所有token到内存缓存
  Future<void> preloadCache() async {
    try {
      if (_cacheLoaded) return;
      
      final futures = await Future.wait([
        getAccessToken(),
        getRefreshToken(),
        getTokenExpiry(),
      ]);
      
      _cacheLoaded = true;
    } catch (e) {
      // 预加载失败不抛异常，保持功能可用
    }
  }

  /// 清除内存缓存（应用进入后台时调用）
  void clearMemoryCache() {
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    _cachedExpiryTime = null;
    _cacheLoaded = false;
  }

  /// 批量保存tokens
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiry,
  }) async {
    try {
      // 更新内存缓存
      _cachedAccessToken = accessToken;
      _cachedRefreshToken = refreshToken;
      _cachedExpiryTime = expiry;
      
      // 批量写入存储
      await Future.wait([
        _secureStorage.write(key: _accessTokenKey, value: accessToken),
        _secureStorage.write(key: _refreshTokenKey, value: refreshToken),
        _secureStorage.write(key: _expiryTimeKey, value: expiry.toIso8601String()),
      ]);
      
      _cacheLoaded = true;
    } catch (e) {
      throw TokenStorageException('Failed to save tokens', e is Exception ? e : Exception(e.toString()));
    }
  }
}