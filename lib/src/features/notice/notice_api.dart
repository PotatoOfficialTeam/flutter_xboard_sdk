import 'package:flutter_xboard_sdk/src/services/http_service.dart';
import 'package:flutter_xboard_sdk/src/features/notice/notice_models.dart';
import 'package:flutter_xboard_sdk/src/exceptions/xboard_exceptions.dart';

class NoticeApi {
  final HttpService _httpService;

  NoticeApi(this._httpService);

  /// 获取通知列表
  /// 返回 [NoticeResponse] 对象，包含通知列表和总数
  Future<NoticeResponse> fetchNotices() async {
    try {
      final result = await _httpService.getRequest(
        "/api/v1/user/notice/fetch",
      );

      // Debug prints to inspect the structure
      print('Notice API raw result: $result');
      print('Notice API result type: ${result.runtimeType}');
      if (result.containsKey('data')) {
        print('Notice API result[\'data\'] type: ${result['data'].runtimeType}');
      }

      // Directly return fromJson, assuming the structure matches NoticeResponse
      return NoticeResponse.fromJson(result);
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('获取通知失败: $e');
    }
  }
}