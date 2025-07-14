import 'dart:convert';
import 'package:http/http.dart' as http;

/// 用户信息服务
class UserInfoService {
  final String _baseUrl;
  final Map<String, String> _headers;

  UserInfoService(this._baseUrl, this._headers);

  /// 获取用户信息
  Future<Map<String, dynamic>> getUserInfo() async {
    final client = http.Client();
    try {
      final response = await client.get(
        Uri.parse('$_baseUrl/api/v1/user/info'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          return data['data'];
        } else {
          throw Exception(data['message'] ?? '获取用户信息失败');
        }
      } else {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    } finally {
      client.close();
    }
  }

  /// 校验Token是否有效
  Future<bool> validateToken(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/api/v1/user/getSubscribe'),
      headers: {
        ..._headers,
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
    final response = await http.get(
      Uri.parse('$_baseUrl/api/v1/user/getSubscribe'),
      headers: _headers,
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
    final response = await http.get(
      Uri.parse('$_baseUrl/api/v1/user/resetSecurity'),
      headers: _headers,
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
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/user/update'),
      headers: {
        ..._headers,
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
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/user/update'),
      headers: {
        ..._headers,
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