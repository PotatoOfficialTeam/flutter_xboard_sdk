import 'http_service.dart';
import '../exceptions/xboard_exceptions.dart';

/// 用户信息服务
class UserInfoService {
  final HttpService _httpService;

  UserInfoService(this._httpService);

  /// 获取用户信息
  Future<Map<String, dynamic>> getUserInfo() async {
    try {
      final result = await _httpService.getRequest('/api/v1/user/info');
      
      if (result['success'] != true) {
        throw ApiException(result['message']?.toString() ?? '获取用户信息失败');
      }
      
      return result['data'] as Map<String, dynamic>;
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('获取用户信息失败: $e');
    }
  }

  /// 校验Token是否有效
  Future<bool> validateToken(String token) async {
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
      
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'] as Map<String, dynamic>;
        return data.containsKey('subscribe_url') && data['subscribe_url'] != null;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 获取订阅链接
  Future<String?> getSubscriptionLink() async {
    try {
      final result = await _httpService.getRequest('/api/v1/user/getSubscribe');
      
      if (result['success'] != true) {
        throw ApiException(result['message']?.toString() ?? '获取订阅链接失败');
      }
      
      return result['data']?['subscribe_url'] as String?;
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('获取订阅链接失败: $e');
    }
  }

  /// 重置订阅链接
  Future<String?> resetSubscriptionLink() async {
    try {
      final result = await _httpService.getRequest('/api/v1/user/resetSecurity');
      
      if (result['success'] != true) {
        throw ApiException(result['message']?.toString() ?? '重置订阅链接失败');
      }
      
      return result['data'] as String?;
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('重置订阅链接失败: $e');
    }
  }

  /// 切换流量提醒
  Future<bool> toggleTrafficReminder(int value) async {
    try {
      final result = await _httpService.postRequest('/api/v1/user/update', {
        'remind_traffic': value,
      });
      
      return result['success'] == true || result['status'] == 'success';
    } catch (e) {
      return false;
    }
  }

  /// 切换到期提醒
  Future<bool> toggleExpireReminder(int value) async {
    try {
      final result = await _httpService.postRequest('/api/v1/user/update', {
        'remind_expire': value,
      });
      
      return result['success'] == true || result['status'] == 'success';
    } catch (e) {
      return false;
    }
  }
} 