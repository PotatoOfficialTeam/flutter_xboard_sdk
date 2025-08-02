import 'package:test/test.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';

void main() {
  group('InviteApi Integration Tests', () {
    final sdk = XBoardSDK.instance;
    const String testEmail = 'h89600912@gmail.com';
    const String testPassword = '12345678';
    const String baseUrl = 'https://apiwj0801.wujie001.info';

    setUpAll(() async {
      await sdk.initialize(baseUrl);
      final loginResponse = await sdk.login.login(testEmail, testPassword);
      if (loginResponse.data?.authData != null) {
        sdk.setAuthToken(loginResponse.data!.authData!);
      } else {
        throw Exception('Login failed: ${loginResponse.message}');
      }
    });

    test('generateInviteCode should return success or reach limit', () async {
      try {
        final response = await sdk.inviteApi.generateInviteCode();
        expect(response.message, anyOf('操作成功', contains('已达到创建数量上限')));
      } catch (e) {
        expect(e, isA<ApiException>());
        expect(e.toString(), contains('已达到创建数量上限'));
      }
    });

    test('fetchInviteCodes should return invite info', () async {
      final response = await sdk.inviteApi.fetchInviteCodes();
      expect(response.data, isNotNull);
      expect(response.data, isA<InviteInfo>());
    });

    test('fetchCommissionDetails should return a list of commission details', () async {
      final response = await sdk.inviteApi.fetchCommissionDetails(current: 1, pageSize: 10);
      expect(response.data, isNotNull);
      expect(response.data, isA<List<CommissionDetail>>());
    });
  });
}
