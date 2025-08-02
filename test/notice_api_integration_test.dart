import 'package:test/test.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';

void main() {
  group('NoticeApi Integration Tests', () {
    final sdk = XBoardSDK.instance;
    const String testEmail = 'h89600912@gmail.com';
    const String testPassword = '12345678';
    const String baseUrl = 'https://apiwj0801.wujie001.info';

    setUpAll(() async {
      await sdk.initialize(baseUrl);
      // 登录以获取token
      final loginResponse = await sdk.login.login(testEmail, testPassword);
      if (loginResponse.data?.authData != null) {
        sdk.setAuthToken(loginResponse.data!.authData!);
      } else {
        throw Exception('Login failed: ${loginResponse.message}');
      }
    });

    test('fetchNotices should return a NoticeResponse', () async {
      final response = await sdk.noticeApi.fetchNotices();
      expect(response, isNotNull);
      expect(response.data, isA<List<Notice>>());
      expect(response.total, isA<int>());

      if (response.data.isNotEmpty) {
        final notice = response.data.first;
        expect(notice.id, isA<int>());
        expect(notice.title, isA<String>());
        expect(notice.content, isA<String>());
        expect(notice.show, isA<bool>());
        expect(notice.createdAt, isA<int>());
        expect(notice.updatedAt, isA<int>());
      }
    });
  });
}
