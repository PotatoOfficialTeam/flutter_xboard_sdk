# XBoard SDK 通知功能

## 概述

基于原有的 p2hiddify 项目中的通知实现，我们已成功将通知API功能集成到 XBoard SDK 中。此功能允许应用获取和管理各种类型的通知消息。

## 新增文件

### 模型文件
- `lib/src/models/notice_models.dart` - 通知相关的数据模型

### 服务文件  
- `lib/src/services/notice_service.dart` - 通知服务API接口

### 测试文件
- `test/notice_test.dart` - 通知功能完整测试示例
- `validate_notice_models.dart` - 模型验证脚本

## 功能特性

### 1. 数据模型

#### Notice (通知模型)
```dart
class Notice {
  final int id;                    // 通知ID
  final String title;              // 通知标题
  final String content;            // 通知内容
  final dynamic show;              // 显示状态 (支持int和bool)
  final String? imgUrl;            // 图片URL (可选)
  final List<String>? tags;        // 标签列表 (可选)
  final int createdAt;             // 创建时间戳
  final int updatedAt;             // 更新时间戳
  
  // 辅助方法
  bool get shouldShow;             // 是否应该显示
  bool get isAppNotice;            // 是否为应用通知
}
```

#### NoticeResponse (通知响应模型)
```dart
class NoticeResponse {
  final List<Notice> notices;      // 通知列表
  final int total;                 // 总数量
  
  // 辅助方法
  List<Notice> get appNotices;     // 获取应用通知 (按时间倒序)
}
```

#### NoticesState (通知状态模型)
```dart
class NoticesState {
  final bool isLoading;            // 加载状态
  final NoticeResponse? noticeResponse; // 通知响应数据
  final String? error;             // 错误信息
  
  NoticesState copyWith({...});    // 状态复制方法
}
```

### 2. API 服务

#### NoticeService 提供的方法

```dart
// 获取原始通知数据
Future<Map<String, dynamic>> fetchNoticesRaw();

// 获取结构化通知列表
Future<NoticeResponse> fetchNotices();

// 获取应用通知 (包含'app'标签且可见)
Future<List<Notice>> fetchAppNotices();

// 获取所有可见通知
Future<List<Notice>> fetchVisibleNotices();

// 根据标签筛选通知
Future<List<Notice>> fetchNoticesByTag(String tag);

// 根据ID获取单个通知
Future<Notice?> getNoticeById(int noticeId);
```

## 使用方法

### 1. 基本使用

```dart
// 初始化SDK
await XBoardSDK.instance.initialize('https://your-domain.com');
XBoardSDK.instance.setAuthToken('your_token');

// 获取所有通知
final response = await XBoardSDK.instance.notice.fetchNotices();
print('共有${response.total}条通知');

// 获取应用通知
final appNotices = await XBoardSDK.instance.notice.fetchAppNotices();
for (final notice in appNotices) {
  print('${notice.title}: ${notice.content}');
}
```

### 2. 实际应用场景

#### 应用启动时检查重要通知
```dart
Future<void> checkImportantNotices() async {
  try {
    final appNotices = await XBoardSDK.instance.notice.fetchAppNotices();
    
    for (final notice in appNotices.take(3)) {
      // 显示通知弹窗
      showNotificationDialog(notice.title, notice.content);
    }
  } catch (e) {
    print('获取通知失败: $e');
  }
}
```

#### 通知列表页面
```dart
class NotificationProvider extends ChangeNotifier {
  NoticesState _state = NoticesState();
  NoticesState get state => _state;
  
  Future<void> refreshNotices() async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();
    
    try {
      final response = await XBoardSDK.instance.notice.fetchNotices();
      _state = _state.copyWith(
        isLoading: false,
        noticeResponse: response,
      );
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
    notifyListeners();
  }
}
```

#### 根据用户偏好筛选通知
```dart
Future<List<Notice>> getPersonalizedNotices() async {
  final userPreferences = await getUserPreferences();
  
  if (userPreferences.onlyAppNotices) {
    return await XBoardSDK.instance.notice.fetchAppNotices();
  } else if (userPreferences.favoriteTag != null) {
    return await XBoardSDK.instance.notice.fetchNoticesByTag(
      userPreferences.favoriteTag!
    );
  } else {
    return await XBoardSDK.instance.notice.fetchVisibleNotices();
  }
}
```

## API 接口

### 端点
- `GET /api/v1/user/notice/fetch` - 获取通知列表

### 响应格式
```json
{
  "data": [
    {
      "id": 1,
      "title": "通知标题",
      "content": "通知内容",
      "show": 1,
      "img_url": "https://example.com/image.png",
      "tags": ["app", "feature"],
      "created_at": 1703000000,
      "updated_at": 1703000000
    }
  ],
  "total": 1
}
```

## 标签系统

通知支持标签分类，常用标签包括：

- `app` - 应用相关通知
- `system` - 系统通知
- `maintenance` - 维护通知
- `feature` - 新功能通知
- `security` - 安全相关通知

## 显示控制

通知的 `show` 字段支持多种格式：
- `1` 或 `true` - 显示
- `0` 或 `false` - 隐藏

使用 `notice.shouldShow` 方法可以统一判断是否应该显示。

## 测试

运行测试验证功能：

```bash
# 运行模型验证
dart validate_notice_models.dart

# 运行完整测试 (需要有效的API配置)
dart test/notice_test.dart
```

## 注意事项

1. **认证要求**: 所有通知API都需要有效的认证Token
2. **错误处理**: 所有API方法都包含错误处理，失败时返回空列表或null
3. **排序**: 应用通知和可见通知都按创建时间倒序排列
4. **缓存**: 建议在应用层实现适当的缓存机制
5. **性能**: 大量通知时建议实现分页加载

## 更新日志

### v1.0.0 (当前版本)
- ✅ 添加 Notice、NoticeResponse、NoticesState 数据模型
- ✅ 添加 NoticeService API 服务
- ✅ 支持通知标签筛选
- ✅ 支持应用通知识别
- ✅ 完整的测试覆盖
- ✅ 兼容原 p2hiddify 实现

这样，XBoard SDK 现在已经包含了完整的通知功能，可以满足各种通知管理需求。 