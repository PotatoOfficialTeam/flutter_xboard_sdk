import 'dart:io';
import 'http_service.dart';
import '../models/subscription_models.dart';
import '../utils/subscription_cache.dart';

class SubscriptionService {
  final HttpService _httpService;

  SubscriptionService(this._httpService);

  /// 获取订阅链接
  /// 返回包含订阅信息的结果
  /// 注意：需要先通过SDK设置token才能调用此方法
  Future<SubscriptionInfo> getSubscriptionLink() async {
    final result = await _httpService.getRequest("/api/v1/user/getSubscribe");

    if (result['success'] == true && result.containsKey("data")) {
      final data = result["data"];
      if (data is Map<String, dynamic>) {
        final subscriptionInfo = SubscriptionInfo.fromJson(data);
        
        // 更新计划名称缓存
        if (subscriptionInfo.planName != null) {
          await SubscriptionCache.setPlanName(subscriptionInfo.planName!);
        }
        
        return subscriptionInfo;
      }
    }
    
    throw Exception("Failed to retrieve subscription link: ${result['message'] ?? 'Unknown error'}");
  }

  /// 重置订阅链接
  /// 返回重置后的订阅链接
  /// 注意：需要先通过SDK设置token才能调用此方法
  Future<String> resetSubscriptionLink() async {
    final result = await _httpService.getRequest("/api/v1/user/resetSecurity");

    if (result['success'] == true && result.containsKey("data")) {
      final data = result["data"];
      if (data is String) {
        final resetLink = _appendPlatformSuffix(data);
        
        // 重置后重新获取订阅信息
        try {
          await getSubscriptionLink();
        } catch (e) {
          // 忽略获取错误，只返回重置链接
        }
        
        return resetLink;
      }
    }
    
    throw Exception("Failed to reset subscription link: ${result['message'] ?? 'Unknown error'}");
  }

  /// 获取用户计划信息
  /// 返回计划名称
  /// 注意：需要先通过SDK设置token才能调用此方法
  Future<String?> getPlanName() async {
    try {
      final subscriptionInfo = await getSubscriptionLink();
      return subscriptionInfo.planName;
    } catch (e) {
      return null;
    }
  }

  /// 获取订阅统计信息
  /// 返回订阅统计数据
  /// 注意：需要先通过SDK设置token才能调用此方法
  Future<SubscriptionStats?> getSubscriptionStats() async {
    try {
      final result = await _httpService.getRequest("/api/v1/user/getStat");

      if (result['success'] == true && result.containsKey("data")) {
        return SubscriptionStats.fromJson(result["data"]);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 动态判断平台并添加后缀
  String _appendPlatformSuffix(String? url) {
    if (url == null) return '';

    final platform = _getPlatform();
    if (platform != null) {
      final separator = url.contains('?') ? '&' : '?';
      return '$url${separator}platform=$platform';
    }
    return url;
  }

  /// 判断当前运行的操作系统
  String? _getPlatform() {
    if (Platform.isAndroid) {
      return 'Android';
    } else if (Platform.isIOS) {
      return 'iOS';
    } else if (Platform.isWindows) {
      return 'Windows';
    } else if (Platform.isLinux) {
      return 'Linux';
    } else if (Platform.isMacOS) {
      return 'macOS';
    } else {
      return null; // 无法判断平台时返回 null
    }
  }
} 