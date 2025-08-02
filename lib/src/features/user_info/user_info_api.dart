import 'package:flutter_xboard_sdk/src/services/http_service.dart';
import 'package:flutter_xboard_sdk/src/features/user_info/user_info_models.dart';
import 'package:flutter_xboard_sdk/src/common/models/api_response.dart';
import 'package:flutter_xboard_sdk/src/exceptions/xboard_exceptions.dart';

class UserInfoApi {
  final HttpService _httpService;

  UserInfoApi(this._httpService);

  /// 获取用户信息
  Future<ApiResponse<UserInfo>> getUserInfo() async {
    try {
      final result = await _httpService.getRequest('/api/v1/user/info');
      return ApiResponse.fromJson(result, (json) => UserInfo.fromJson(json as Map<String, dynamic>));
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('获取用户信息失败: $e');
    }
  }

  /// 校验Token是否有效
  Future<ApiResponse<bool>> validateToken(String token) async {
    try {
      // 临时设置token用于验证
      final originalToken = _httpService.getAuthToken();
      _httpService.setAuthToken(token);
      
      final result = await _httpService.getRequest('/api/v1/user/getSubscribe');
      
      // 恢复原token
      if (originalToken != null) {
        _httpService.setAuthToken(originalToken);
      } else {
        _httpService.clearAuthToken();
      }
      
      return ApiResponse.fromJson(result, (json) => json['subscribe_url'] != null);
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('校验Token失败: $e');
    }
  }

  /// 获取订阅链接
  Future<ApiResponse<String?>> getSubscriptionLink() async {
    try {
      final result = await _httpService.getRequest('/api/v1/user/getSubscribe');
      return ApiResponse.fromJson(result, (json) => json['subscribe_url'] as String?);
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('获取订阅链接失败: $e');
    }
  }

  /// 重置订阅链接
  Future<ApiResponse<String?>> resetSubscriptionLink() async {
    try {
      final result = await _httpService.getRequest('/api/v1/user/resetSecurity');
      return ApiResponse.fromJson(result, (json) => json as String?);
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('重置订阅链接失败: $e');
    }
  }

  /// 切换流量提醒
  Future<ApiResponse<void>> toggleTrafficReminder(bool value) async {
    try {
      final result = await _httpService.postRequest('/api/v1/user/update', {
        'remind_traffic': value ? 1 : 0,
      });
      return ApiResponse.fromJson(result, (json) => null);
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('切换流量提醒失败: $e');
    }
  }

  /// 切换到期提醒
  Future<ApiResponse<void>> toggleExpireReminder(bool value) async {
    try {
      final result = await _httpService.postRequest('/api/v1/user/update', {
        'remind_expire': value ? 1 : 0,
      });
      return ApiResponse.fromJson(result, (json) => null);
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('切换到期提醒失败: $e');
    }
  }
}
