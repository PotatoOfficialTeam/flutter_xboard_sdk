/// 通知模型
/// 
/// 表示从API获取的单个通知信息
class Notice {
  final int id;
  final String title;
  final String content;
  final dynamic show;  // 支持bool或int类型
  final String? imgUrl;
  final List<String>? tags;
  final int createdAt;
  final int updatedAt;

  const Notice({
    required this.id,
    required this.title,
    required this.content,
    required this.show,
    this.imgUrl,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 从JSON创建Notice实例
  factory Notice.fromJson(Map<String, dynamic> json) {
    List<String>? tagsList;
    if (json['tags'] != null) {
      if (json['tags'] is List) {
        tagsList = List<String>.from(json['tags'] as List);
      }
    }
    return Notice(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      show: json['show'],  // 不进行类型转换，直接使用原始值
      imgUrl: json['img_url'] as String?,
      tags: tagsList,
      createdAt: json['created_at'] as int,
      updatedAt: json['updated_at'] as int,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'show': show,
      'img_url': imgUrl,
      'tags': tags,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// 检查通知是否应该显示
  bool get shouldShow {
    return show == true || show == 1;
  }

  /// 检查是否为应用通知
  bool get isAppNotice {
    return tags != null && tags!.contains('app');
  }
}

/// 通知响应模型
///
/// 表示从API获取的通知列表响应
class NoticeResponse {
  final List<Notice> notices;
  final int total;

  const NoticeResponse({
    required this.notices,
    required this.total,
  });

  /// 从JSON创建NoticeResponse实例
  factory NoticeResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> noticesJson = json['data'] as List<dynamic>;
    final notices = noticesJson
        .map((noticeJson) => Notice.fromJson(noticeJson as Map<String, dynamic>))
        .toList();

    return NoticeResponse(
      notices: notices,
      total: json['total'] as int,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'data': notices.map((notice) => notice.toJson()).toList(),
      'total': total,
    };
  }

  /// 获取应用通知
  List<Notice> get appNotices {
    return notices
        .where((notice) => notice.isAppNotice && notice.shouldShow)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}

/// 通知状态类
class NoticesState {
  final bool isLoading;
  final NoticeResponse? noticeResponse;
  final String? error;
  
  const NoticesState({
    this.isLoading = false,
    this.noticeResponse,
    this.error,
  });
  
  NoticesState copyWith({
    bool? isLoading,
    NoticeResponse? noticeResponse,
    String? error,
  }) {
    return NoticesState(
      isLoading: isLoading ?? this.isLoading,
      noticeResponse: noticeResponse ?? this.noticeResponse,
      error: error ?? this.error,
    );
  }
} 