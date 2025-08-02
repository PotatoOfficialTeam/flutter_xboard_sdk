import 'package:flutter_xboard_sdk/src/services/http_service.dart';
import 'package:flutter_xboard_sdk/src/features/ticket/ticket_models.dart';
import 'package:flutter_xboard_sdk/src/common/models/api_response.dart';
import 'package:flutter_xboard_sdk/src/exceptions/xboard_exceptions.dart';

class TicketApi {
  final HttpService _httpService;

  TicketApi(this._httpService);

  /// 获取工单列表
  Future<ApiResponse<List<Ticket>>> fetchTickets() async {
    try {
      final result = await _httpService.getRequest('/api/v1/user/ticket/fetch');
      return ApiResponse.fromJson(result, (json) => (json as List<dynamic>).map((e) => Ticket.fromJson(e as Map<String, dynamic>)).toList());
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('获取工单列表时发生错误: $e');
    }
  }

  /// 创建工单
  Future<ApiResponse<Ticket>> createTicket({
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
      return ApiResponse.fromJson(result, (json) => Ticket.fromJson(json as Map<String, dynamic>));
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('创建工单时发生错误: $e');
    }
  }

  /// 获取工单详情（含消息）
  Future<ApiResponse<TicketDetail>> getTicketDetail(int ticketId) async {
    try {
      final result = await _httpService.getRequest('/api/v1/user/ticket/fetch?id=$ticketId');
      return ApiResponse.fromJson(result, (json) => TicketDetail.fromJson(json as Map<String, dynamic>));
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('获取工单详情时发生错误: $e');
    }
  }

  /// 回复工单
  Future<ApiResponse<void>> replyTicket({
    required int ticketId,
    required String message,
  }) async {
    try {
      final result = await _httpService.postRequest('/api/v1/user/ticket/reply', {
        'id': ticketId,
        'message': message,
      });
      return ApiResponse.fromJson(result, (json) => null);
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('回复工单时发生错误: $e');
    }
  }

  /// 关闭工单
  Future<ApiResponse<void>> closeTicket(int ticketId) async {
    try {
      final result = await _httpService.postRequest('/api/v1/user/ticket/close', {
        'id': ticketId,
      });
      return ApiResponse.fromJson(result, (json) => null);
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('关闭工单时发生错误: $e');
    }
  }
}
