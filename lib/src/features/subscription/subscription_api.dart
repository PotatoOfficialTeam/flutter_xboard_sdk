import 'package:flutter_xboard_sdk/src/services/http_service.dart';
import 'package:flutter_xboard_sdk/src/features/subscription/subscription_models.dart';
import 'package:flutter_xboard_sdk/src/exceptions/xboard_exceptions.dart';

class SubscriptionApi {
  final HttpService _httpService;

  SubscriptionApi(this._httpService);

  /// 获取订阅链接
  /// 返回包含订阅信息的结果
  /// 注意：需要先通过SDK设置token才能调用此方法
  Future<SubscriptionResponse> getSubscriptionLink() async {
    try {
      final result = await _httpService.getRequest("/api/v1/user/getSubscribe");
      final response = SubscriptionResponse.fromJson(result);

      if (response.success == true && response.data != null) {
        return response;
      } else {
        throw ApiException(response.message ?? '获取订阅链接失败');
      }
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('获取订阅链接失败: $e');
    }
  }

  /// 重置订阅链接
  /// 返回重置后的订阅链接
  /// 注意：需要先通过SDK设置token才能调用此方法
  Future<String> resetSubscriptionLink() async {
    try {
      final result = await _httpService.getRequest("/api/v1/user/resetSecurity");
      
      if (result['success'] == true && result.containsKey("data")) {
        final data = result["data"];
        if (data is String) {
          return data;
        }
      }
      
      throw ApiException("Failed to reset subscription link: ${result['message'] ?? 'Unknown error'}");
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('重置订阅链接失败: $e');
    }
  }

  /// 获取用户计划信息
  /// 返回计划名称
  /// 注意：需要先通过SDK设置token才能调用此方法
  Future<String?> getPlanName() async {
    try {
      final subscriptionInfoResponse = await getSubscriptionLink();
      return subscriptionInfoResponse.data?.planName;
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
      if (e is XBoardException) rethrow;
      throw ApiException('获取订阅统计信息失败: $e');
    }
  }
}