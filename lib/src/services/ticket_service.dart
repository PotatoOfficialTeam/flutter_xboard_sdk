import 'http_service.dart';
import '../models/ticket_models.dart';
import '../exceptions/xboard_exceptions.dart';

/// 工单服务
class TicketService {
  final HttpService _httpService;

  TicketService(this._httpService);

  /// 获取工单列表
  Future<List<Ticket>> fetchTickets() async {
    try {
      final result = await _httpService.getRequest('/api/v1/user/ticket/fetch');
      
      if (result['success'] != true && result['status'] != 'success') {
        throw ApiException(result['message']?.toString() ?? '获取工单失败');
      }
      
      return (result['data'] as List)
          .map((e) => Ticket.fromJson(e))
          .toList();
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('获取工单列表时发生错误: $e');
    }
  }

  /// 创建工单
  Future<Ticket> createTicket({
    required String subject,
    required String message,
    required int level,
  }) async {
    try {
      final result = await _httpService.postRequest('/api/v1/user/ticket/save', {
        'subject': subject,
        'message': message,
        'level': level,
      });
      
      if (result['success'] != true && result['status'] != 'success') {
        throw ApiException(result['message']?.toString() ?? '创建工单失败');
      }
      
      if (result['data'] is Map<String, dynamic>) {
        return Ticket.fromJson(result['data']);
      } else {
        // 兼容后端返回data为true时，重新拉取工单列表取最新一条
        final tickets = await fetchTickets();
        if (tickets.isNotEmpty) {
          return tickets.first;
        } else {
          throw ApiException('创建工单成功，但无法获取新工单详情');
        }
      }
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('创建工单时发生错误: $e');
    }
  }

  /// 获取工单详情（含消息）
  Future<TicketDetail> getTicketDetail(int ticketId) async {
    try {
      final result = await _httpService.getRequest('/api/v1/user/ticket/fetch?id=$ticketId');
      
      if (result['success'] != true && result['status'] != 'success') {
        throw ApiException(result['message']?.toString() ?? '获取工单详情失败');
      }
      
      return TicketDetail.fromJson(result['data']);
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('获取工单详情时发生错误: $e');
    }
  }

  /// 回复工单
  Future<bool> replyTicket({
    required int ticketId,
    required String message,
  }) async {
    try {
      final result = await _httpService.postRequest('/api/v1/user/ticket/reply', {
        'id': ticketId,
        'message': message,
      });
      
      return result['success'] == true || result['status'] == 'success';
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('回复工单时发生错误: $e');
    }
  }

  /// 关闭工单
  Future<bool> closeTicket(int ticketId) async {
    try {
      final result = await _httpService.postRequest('/api/v1/user/ticket/close', {
        'id': ticketId,
      });
      
      return result['success'] == true || result['status'] == 'success';
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('关闭工单时发生错误: $e');
    }
  }
}