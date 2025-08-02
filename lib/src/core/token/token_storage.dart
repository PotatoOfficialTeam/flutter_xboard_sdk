/// Token存储抽象接口
/// 允许不同的存储实现（安全存储、内存存储、自定义存储等）
abstract class TokenStorage {
  /// 保存访问令牌
  Future<void> saveAccessToken(String token);

  /// 获取访问令牌
  Future<String?> getAccessToken();

  /// 保存刷新令牌
  Future<void> saveRefreshToken(String token);

  /// 获取刷新令牌
  Future<String?> getRefreshToken();

  /// 保存令牌过期时间
  Future<void> saveTokenExpiry(DateTime expiry);

  /// 获取令牌过期时间
  Future<DateTime?> getTokenExpiry();

  /// 清除所有令牌数据
  Future<void> clearTokens();

  /// 检查存储是否可用
  Future<bool> isAvailable();
}

/// Token存储异常
class TokenStorageException implements Exception {
  final String message;
  final Exception? cause;

  const TokenStorageException(this.message, [this.cause]);

  @override
  String toString() => 'TokenStorageException: $message${cause != null ? ' (Caused by: $cause)' : ''}';
}