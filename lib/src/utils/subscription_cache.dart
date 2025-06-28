import 'package:shared_preferences/shared_preferences.dart';

/// 订阅信息缓存工具类
class SubscriptionCache {
  static const String _keyPlanName = 'subscription_plan_name';
  static const String _keySubscribeUrl = 'subscription_url';
  static const String _keyExpiredAt = 'subscription_expired_at';
  static const String _keyLastUpdate = 'subscription_last_update';
  
  static SharedPreferences? _prefs;

  /// 初始化缓存
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// 设置计划名称
  static Future<void> setPlanName(String? name) async {
    await _ensureInitialized();
    if (name == null) {
      await _prefs?.remove(_keyPlanName);
    } else {
      await _prefs?.setString(_keyPlanName, name);
    }
  }

  /// 获取计划名称
  static String? getPlanName() {
    return _prefs?.getString(_keyPlanName);
  }

  /// 设置订阅链接
  static Future<void> setSubscribeUrl(String? url) async {
    await _ensureInitialized();
    if (url == null) {
      await _prefs?.remove(_keySubscribeUrl);
    } else {
      await _prefs?.setString(_keySubscribeUrl, url);
    }
  }

  /// 获取订阅链接
  static String? getSubscribeUrl() {
    return _prefs?.getString(_keySubscribeUrl);
  }

  /// 设置过期时间
  static Future<void> setExpiredAt(DateTime? expiredAt) async {
    await _ensureInitialized();
    if (expiredAt == null) {
      await _prefs?.remove(_keyExpiredAt);
    } else {
      await _prefs?.setInt(_keyExpiredAt, expiredAt.millisecondsSinceEpoch);
    }
  }

  /// 获取过期时间
  static DateTime? getExpiredAt() {
    final timestamp = _prefs?.getInt(_keyExpiredAt);
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  /// 设置最后更新时间
  static Future<void> setLastUpdate() async {
    await _ensureInitialized();
    await _prefs?.setInt(_keyLastUpdate, DateTime.now().millisecondsSinceEpoch);
  }

  /// 获取最后更新时间
  static DateTime? getLastUpdate() {
    final timestamp = _prefs?.getInt(_keyLastUpdate);
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  /// 检查缓存是否过期（默认1小时）
  static bool isCacheExpired({Duration maxAge = const Duration(hours: 1)}) {
    final lastUpdate = getLastUpdate();
    if (lastUpdate == null) return true;
    
    return DateTime.now().difference(lastUpdate) > maxAge;
  }

  /// 清除所有订阅缓存
  static Future<void> clearAll() async {
    await _ensureInitialized();
    await Future.wait([
      _prefs!.remove(_keyPlanName),
      _prefs!.remove(_keySubscribeUrl),
      _prefs!.remove(_keyExpiredAt),
      _prefs!.remove(_keyLastUpdate),
    ]);
  }

  /// 确保SharedPreferences已初始化
  static Future<void> _ensureInitialized() async {
    if (_prefs == null) {
      await init();
    }
  }

  /// 缓存订阅信息
  static Future<void> cacheSubscriptionInfo({
    String? planName,
    String? subscribeUrl,
    DateTime? expiredAt,
  }) async {
    await Future.wait([
      setPlanName(planName),
      setSubscribeUrl(subscribeUrl),
      setExpiredAt(expiredAt),
      setLastUpdate(),
    ]);
  }

  /// 获取缓存的订阅信息
  static Map<String, dynamic> getCachedSubscriptionInfo() {
    return {
      'planName': getPlanName(),
      'subscribeUrl': getSubscribeUrl(),
      'expiredAt': getExpiredAt(),
      'lastUpdate': getLastUpdate(),
      'isExpired': isCacheExpired(),
    };
  }
} 