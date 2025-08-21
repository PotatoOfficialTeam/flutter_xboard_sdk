import 'package:flutter_xboard_sdk/src/services/http_service.dart';
import 'package:flutter_xboard_sdk/src/features/notice/notice_models.dart';
import 'package:flutter_xboard_sdk/src/common/models/api_response.dart';
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

      // Directly return fromJson, assuming the structure matches NoticeResponse
      final apiResponse = ApiResponse.fromJson(result, (json) => json); // Pass a dummy function for T
      if (apiResponse.success && apiResponse.data != null) {
        return NoticeResponse.fromJson(apiResponse.data as Map<String, dynamic>);
      } else {
        throw ApiException(apiResponse.message ?? 'Failed to fetch notices');
      }
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('获取通知失败: $e');
    }
  }
}