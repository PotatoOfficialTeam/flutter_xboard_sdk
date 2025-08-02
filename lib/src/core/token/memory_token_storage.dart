import 'token_storage.dart';

/// 内存Token存储实现
/// 仅在应用运行期间保存token，应用重启后丢失
/// 主要用于测试环境或临时存储场景
class MemoryTokenStorage implements TokenStorage {
  String? _accessToken;
  String? _refreshToken;
  DateTime? _tokenExpiry;

  @override
  Future<void> saveAccessToken(String token) async {
    _accessToken = token;
  }

  @override
  Future<String?> getAccessToken() async {
    return _accessToken;
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    _refreshToken = token;
  }

  @override
  Future<String?> getRefreshToken() async {
    return _refreshToken;
  }

  @override
  Future<void> saveTokenExpiry(DateTime expiry) async {
    _tokenExpiry = expiry;
  }

  @override
  Future<DateTime?> getTokenExpiry() async {
    return _tokenExpiry;
  }

  @override
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    _tokenExpiry = null;
  }

  @override
  Future<bool> isAvailable() async {
    return true; // 内存存储总是可用
  }

  /// 检查是否有token数据
  bool get hasTokens => _accessToken != null && _refreshToken != null && _tokenExpiry != null;

  /// 获取所有token信息（用于调试）
  Map<String, dynamic> get debugInfo => {
    'hasAccessToken': _accessToken != null,
    'hasRefreshToken': _refreshToken != null,
    'tokenExpiry': _tokenExpiry?.toIso8601String(),
    'isExpired': _tokenExpiry != null ? DateTime.now().isAfter(_tokenExpiry!) : null,
  };
}