import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_info_models.dart';
import '../utils/subscription_cache.dart';

/// 用户信息服务
class UserInfoService {
  final String _baseUrl;
  final Map<String, String> _defaultHeaders;

  UserInfoService(this._baseUrl, this._defaultHeaders);

  /// 获取用户信息
  Future<UserInfo?> fetchUserInfo() async {
    final accessToken = await SubscriptionCache.getAccessToken();
    if (accessToken == null) {
      throw Exception('未找到访问令牌，请先登录');
    }
    final response = await http.get(
      Uri.parse('$_baseUrl/api/v1/user/info'),
      headers: {
        ..._defaultHeaders,
        'Authorization': accessToken,
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['data'] != null) {
        return UserInfo.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? '获取用户信息失败');
      }
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  /// 校验Token是否有效
  Future<bool> validateToken(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/v1/user/getSubscribe'),
      headers: {
        ..._defaultHeaders,
        'Authorization': token,
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['data'] != null) {
        final d = data['data'] as Map<String, dynamic>;
        return d.containsKey('subscribe_url') && d['subscribe_url'] != null;
      }
      return false;
    } else {
      return false;
    }
  }

  /// 获取订阅链接
  Future<String?> getSubscriptionLink() async {
    final accessToken = await SubscriptionCache.getAccessToken();
    if (accessToken == null) {
      throw Exception('未找到访问令牌，请先登录');
    }
    final response = await http.get(
      Uri.parse('$_baseUrl/api/v1/user/getSubscribe'),
      headers: {
        ..._defaultHeaders,
        'Authorization': accessToken,
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data']?['subscribe_url'] as String?;
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  /// 重置订阅链接
  Future<String?> resetSubscriptionLink() async {
    final accessToken = await SubscriptionCache.getAccessToken();
    if (accessToken == null) {
      throw Exception('未找到访问令牌，请先登录');
    }
    final response = await http.get(
      Uri.parse('$_baseUrl/api/v1/user/resetSecurity'),
      headers: {
        ..._defaultHeaders,
        'Authorization': accessToken,
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] as String?;
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  /// 切换流量提醒
  Future<bool> toggleTrafficReminder(int value) async {
    final accessToken = await SubscriptionCache.getAccessToken();
    if (accessToken == null) {
      throw Exception('未找到访问令牌，请先登录');
    }
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/user/update'),
      headers: {
        ..._defaultHeaders,
        'Authorization': accessToken,
        'Content-Type': 'application/json',
      },
      body: json.encode({'remind_traffic': value}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['status'] == 'success';
    } else {
      return false;
    }
  }

  /// 切换到期提醒
  Future<bool> toggleExpireReminder(int value) async {
    final accessToken = await SubscriptionCache.getAccessToken();
    if (accessToken == null) {
      throw Exception('未找到访问令牌，请先登录');
    }
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/user/update'),
      headers: {
        ..._defaultHeaders,
        'Authorization': accessToken,
        'Content-Type': 'application/json',
      },
      body: json.encode({'remind_expire': value}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['status'] == 'success';
    } else {
      return false;
    }
  }
} 