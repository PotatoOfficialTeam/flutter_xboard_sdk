import 'http_service.dart';
import '../models/notice_models.dart';

/// 通知服务类
/// 
/// 提供通知相关的API接口
class NoticeService {
  final HttpService _httpService;

  NoticeService(this._httpService);

  /// 获取通知列表
  /// 
  /// 返回包含通知列表的原始响应数据
  Future<Map<String, dynamic>> fetchNoticesRaw() async {
    return await _httpService.getRequest(
      "/api/v1/user/notice/fetch",
    );
  }

  /// 获取通知列表（结构化返回）
  /// 
  /// 返回 [NoticeResponse] 对象，包含通知列表和总数
  /// 
  /// 示例：
  /// ```dart
  /// final response = await sdk.notice.fetchNotices();
  /// print('共有${response.total}条通知');
  /// for (final notice in response.notices) {
  ///   print('${notice.title}: ${notice.content}');
  /// }
  /// ```
  Future<NoticeResponse> fetchNotices() async {
    final result = await fetchNoticesRaw();
    
    if (result.containsKey("data") && result.containsKey("total")) {
      return NoticeResponse.fromJson(result);
    }
    
    throw Exception("Failed to retrieve notices: Invalid response format");
  }

  /// 获取应用通知
  /// 
  /// 返回包含"app"标签且应该显示的通知列表，按创建时间倒序排列
  /// 
  /// 示例：
  /// ```dart
  /// final appNotices = await sdk.notice.fetchAppNotices();
  /// for (final notice in appNotices) {
  ///   print('应用通知: ${notice.title}');
  /// }
  /// ```
  Future<List<Notice>> fetchAppNotices() async {
    try {
      final response = await fetchNotices();
      return response.appNotices;
    } catch (e) {
      // 出错时返回空列表
      return [];
    }
  }

  /// 获取可见通知
  /// 
  /// 返回所有应该显示的通知列表，按创建时间倒序排列
  /// 
  /// 示例：
  /// ```dart
  /// final visibleNotices = await sdk.notice.fetchVisibleNotices();
  /// print('共有${visibleNotices.length}条可见通知');
  /// ```
  Future<List<Notice>> fetchVisibleNotices() async {
    try {
      final response = await fetchNotices();
      
      final visibleNotices = response.notices
          .where((notice) => notice.shouldShow)
          .toList();
          
      // 按照创建时间排序，最新的排在前面
      visibleNotices.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return visibleNotices;
    } catch (e) {
      // 出错时返回空列表
      return [];
    }
  }

  /// 根据标签筛选通知
  /// 
  /// [tag] 要筛选的标签
  /// 返回包含指定标签且应该显示的通知列表
  /// 
  /// 示例：
  /// ```dart
  /// final systemNotices = await sdk.notice.fetchNoticesByTag('system');
  /// ```
  Future<List<Notice>> fetchNoticesByTag(String tag) async {
    try {
      final response = await fetchNotices();
      
      final taggedNotices = response.notices
          .where((notice) => 
              notice.shouldShow && 
              notice.tags != null && 
              notice.tags!.contains(tag))
          .toList();
          
      // 按照创建时间排序，最新的排在前面
      taggedNotices.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return taggedNotices;
    } catch (e) {
      // 出错时返回空列表
      return [];
    }
  }

  /// 根据ID获取单个通知
  /// 
  /// [noticeId] 通知ID
  /// 返回指定ID的通知，如果未找到则返回null
  /// 
  /// 示例：
  /// ```dart
  /// final notice = await sdk.notice.getNoticeById(123);
  /// if (notice != null) {
  ///   print('通知标题: ${notice.title}');
  /// }
  /// ```
  Future<Notice?> getNoticeById(int noticeId) async {
    try {
      final response = await fetchNotices();
      
      for (final notice in response.notices) {
        if (notice.id == noticeId) {
          return notice;
        }
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
} 