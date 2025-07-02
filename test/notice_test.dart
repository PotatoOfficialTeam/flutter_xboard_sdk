import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';

/// 通知功能测试示例
/// 
/// 本文件演示如何使用XBoard SDK的通知功能
void main() async {
  print('=== XBoard SDK 通知功能测试 ===');
  
  try {
    await testNoticeFeatures();
  } catch (e) {
    print('❌ 通知测试失败: $e');
  }
}

Future<void> testNoticeFeatures() async {
  // 初始化SDK
  await XBoardSDK.instance.initialize('https://your-xboard-domain.com');
  
  // 设置认证Token（实际使用时从登录获取）
  XBoardSDK.instance.setAuthToken('your_auth_token_here');
  
  print('\n=== 基础通知功能测试 ===');
  
  try {
    // 1. 获取所有通知
    print('📋 获取所有通知...');
    final allNotices = await XBoardSDK.instance.notice.fetchNotices();
    print('✅ 成功获取 ${allNotices.total} 条通知');
    
    // 显示前3条通知
    for (int i = 0; i < allNotices.notices.length && i < 3; i++) {
      final notice = allNotices.notices[i];
      print('   ${i + 1}. ${notice.title}');
      print('      内容: ${notice.content.length > 50 ? notice.content.substring(0, 50) + "..." : notice.content}');
      print('      标签: ${notice.tags?.join(", ") ?? "无"}');
    }
    
    // 2. 获取应用通知
    print('\n📱 获取应用通知...');
    final appNotices = await XBoardSDK.instance.notice.fetchAppNotices();
    print('✅ 成功获取 ${appNotices.length} 条应用通知');
    
    for (final notice in appNotices.take(2)) {
      print('   • ${notice.title}');
    }
    
    // 3. 获取可见通知
    print('\n👁️ 获取可见通知...');
    final visibleNotices = await XBoardSDK.instance.notice.fetchVisibleNotices();
    print('✅ 成功获取 ${visibleNotices.length} 条可见通知');
    
    // 4. 根据标签筛选
    print('\n🏷️ 根据标签筛选通知...');
    final systemNotices = await XBoardSDK.instance.notice.fetchNoticesByTag('system');
    print('✅ 成功获取 ${systemNotices.length} 条系统通知');
    
    // 5. 根据ID获取单个通知
    if (allNotices.notices.isNotEmpty) {
      final firstNoticeId = allNotices.notices.first.id;
      print('\n🔍 根据ID获取通知...');
      final notice = await XBoardSDK.instance.notice.getNoticeById(firstNoticeId);
      if (notice != null) {
        print('✅ 成功获取通知: ${notice.title}');
      } else {
        print('❌ 未找到指定ID的通知');
      }
    }
    
  } catch (e) {
    print('❌ API调用失败: $e');
    print('💡 这是正常的，因为我们使用的是测试配置');
  }
  
  print('\n=== 数据模型使用示例 ===');
  testNoticeModelsUsage();
  
  print('\n=== 实际使用场景示例 ===');
  demonstrateUsageScenarios();
}

/// 演示通知数据模型的使用
void testNoticeModelsUsage() {
  // 模拟API响应数据
  final mockApiResponse = {
    'data': [
      {
        'id': 1,
        'title': '系统维护通知',
        'content': '系统将于今晚进行例行维护，预计需要2小时，期间服务可能暂时不可用。',
        'show': 1,
        'img_url': 'https://example.com/maintenance.png',
        'tags': ['system', 'maintenance'],
        'created_at': 1703000000,
        'updated_at': 1703000000,
      },
      {
        'id': 2,
        'title': '新功能上线',
        'content': '我们很高兴地宣布，新的数据统计功能现已上线！',
        'show': true,
        'img_url': null,
        'tags': ['app', 'feature'],
        'created_at': 1703100000,
        'updated_at': 1703100000,
      },
      {
        'id': 3,
        'title': '隐藏的通知',
        'content': '这条通知不应该显示给用户',
        'show': 0,
        'img_url': null,
        'tags': ['internal'],
        'created_at': 1702900000,
        'updated_at': 1702900000,
      }
    ],
    'total': 3,
  };
  
  // 解析响应
  final response = NoticeResponse.fromJson(mockApiResponse);
  print('📊 总通知数: ${response.total}');
  print('📊 实际通知数: ${response.notices.length}');
  
  // 获取应用通知
  final appNotices = response.appNotices;
  print('📱 应用通知数: ${appNotices.length}');
  
  // 遍历所有通知
  print('\n📋 所有通知详情:');
  for (final notice in response.notices) {
    print('   ${notice.id}. ${notice.title}');
    print('      应该显示: ${notice.shouldShow}');
    print('      是应用通知: ${notice.isAppNotice}');
    print('      标签: ${notice.tags?.join(", ") ?? "无"}');
  }
}

/// 演示实际使用场景
void demonstrateUsageScenarios() {
  print('💡 实际使用场景示例:');
  
  print('\n1. 在应用启动时检查重要通知:');
  print('''
  Future<void> checkImportantNotices() async {
    try {
      final appNotices = await XBoardSDK.instance.notice.fetchAppNotices();
      
      for (final notice in appNotices.take(3)) {
        // 显示通知弹窗或横幅
        showNotificationDialog(notice.title, notice.content);
      }
    } catch (e) {
      print('获取通知失败: \$e');
    }
  }
  ''');
  
  print('\n2. 定期刷新通知列表:');
  print('''
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
  ''');
  
  print('\n3. 根据用户偏好筛选通知:');
  print('''
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
  ''');
} 