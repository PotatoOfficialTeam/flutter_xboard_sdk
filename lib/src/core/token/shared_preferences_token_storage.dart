import 'package:shared_preferences/shared_preferences.dart';
import 'token_storage.dart';

/// SharedPreferences-based token storage implementation
/// Provides simple, reliable token storage without requiring special permissions
class SharedPreferencesTokenStorage implements TokenStorage {
  static const String _accessTokenKey = 'xboard_access_token';
  static const String _refreshTokenKey = 'xboard_refresh_token';
  static const String _expiryTimeKey = 'xboard_token_expiry';

  @override
  Future<void> saveAccessToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accessTokenKey, token);
    } catch (e) {
      throw TokenStorageException(
        'Failed to save access token to SharedPreferences',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_accessTokenKey);
    } catch (e) {
      throw TokenStorageException(
        'Failed to get access token from SharedPreferences',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_refreshTokenKey, token);
    } catch (e) {
      throw TokenStorageException(
        'Failed to save refresh token to SharedPreferences',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<String?> getRefreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_refreshTokenKey);
    } catch (e) {
      throw TokenStorageException(
        'Failed to get refresh token from SharedPreferences',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<void> saveTokenExpiry(DateTime expiry) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_expiryTimeKey, expiry.toIso8601String());
    } catch (e) {
      throw TokenStorageException(
        'Failed to save token expiry to SharedPreferences',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<DateTime?> getTokenExpiry() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final expiryString = prefs.getString(_expiryTimeKey);
      return expiryString != null ? DateTime.parse(expiryString) : null;
    } catch (e) {
      throw TokenStorageException(
        'Failed to get token expiry from SharedPreferences',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<void> clearTokens() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.remove(_accessTokenKey),
        prefs.remove(_refreshTokenKey),
        prefs.remove(_expiryTimeKey),
      ]);
    } catch (e) {
      throw TokenStorageException(
        'Failed to clear tokens from SharedPreferences',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      // SharedPreferences is always available
      await SharedPreferences.getInstance();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Batch save all tokens for better performance
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiry,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setString(_accessTokenKey, accessToken),
        prefs.setString(_refreshTokenKey, refreshToken),
        prefs.setString(_expiryTimeKey, expiry.toIso8601String()),
      ]);
    } catch (e) {
      throw TokenStorageException(
        'Failed to save tokens to SharedPreferences',
        e is Exception ? e : Exception(e.toString()),
      );
    }
  }
}