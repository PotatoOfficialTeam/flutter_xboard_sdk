import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ticket_models.dart';
import '../utils/subscription_cache.dart';

/// 工单服务
class TicketService {
  final String _baseUrl;
  final Map<String, String> _defaultHeaders;

  TicketService(this._baseUrl, this._defaultHeaders);

  /// 获取工单列表
  Future<List<Ticket>> fetchTickets() async {
    final accessToken = await SubscriptionCache.getAccessToken();
    if (accessToken == null) {
      throw Exception('未找到访问令牌，请先登录');
    }
    final response = await http.get(
      Uri.parse('$_baseUrl/api/v1/user/ticket/fetch'),
      headers: {
        ..._defaultHeaders,
        'Authorization': accessToken,
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] != 'success') {
        throw Exception(data['message'] ?? '获取工单失败');
      }
      return (data['data'] as List)
          .map((e) => Ticket.fromJson(e))
          .toList();
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  /// 创建工单
  Future<Ticket> createTicket({
    required String subject,
    required String message,
    required int level,
  }) async {
    final accessToken = await SubscriptionCache.getAccessToken();
    if (accessToken == null) {
      throw Exception('未找到访问令牌，请先登录');
    }
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/user/ticket/save'),
      headers: {
        ..._defaultHeaders,
        'Authorization': accessToken,
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'subject': subject,
        'message': message,
        'level': level,
      }),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        if (data['data'] is Map<String, dynamic>) {
          return Ticket.fromJson(data['data']);
        } else {
          // 兼容后端返回data为true时，重新拉取工单列表取最新一条
          final tickets = await fetchTickets();
          if (tickets.isNotEmpty) {
            return tickets.first;
          } else {
            throw Exception('创建工单成功，但无法获取新工单详情');
          }
        }
      } else {
        throw Exception(data['message'] ?? '创建工单失败');
      }
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  /// 获取工单详情（含消息）
  Future<TicketDetail> getTicketDetail(int ticketId) async {
    final accessToken = await SubscriptionCache.getAccessToken();
    if (accessToken == null) {
      throw Exception('未找到访问令牌，请先登录');
    }
    final response = await http.get(
      Uri.parse('$_baseUrl/api/v1/user/ticket/fetch?id=$ticketId'),
      headers: {
        ..._defaultHeaders,
        'Authorization': accessToken,
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success' && data['data'] != null) {
        return TicketDetail.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? '获取工单详情失败');
      }
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  /// 回复工单
  Future<bool> replyToTicket({
    required int ticketId,
    required String message,
  }) async {
    final accessToken = await SubscriptionCache.getAccessToken();
    if (accessToken == null) {
      throw Exception('未找到访问令牌，请先登录');
    }
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/user/ticket/reply'),
      headers: {
        ..._defaultHeaders,
        'Authorization': accessToken,
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'id': ticketId,
        'message': message,
      }),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['status'] == 'success';
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  /// 关闭工单
  Future<bool> closeTicket(int ticketId) async {
    final accessToken = await SubscriptionCache.getAccessToken();
    if (accessToken == null) {
      throw Exception('未找到访问令牌，请先登录');
    }
    final response = await http.post(
      Uri.parse('$_baseUrl/api/v1/user/ticket/close'),
      headers: {
        ..._defaultHeaders,
        'Authorization': accessToken,
        'Content-Type': 'application/json',
      },
      body: json.encode({'id': ticketId}),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['status'] == 'success';
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  }
} 