import 'package:test/test.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';

void main() {
  group('BalanceApi Integration Tests', () {
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

    test('getCommissionHistory should return a list of CommissionHistoryItem', () async {
      final history = await sdk.balanceApi.getCommissionHistory();
      expect(history, isNotNull);
      expect(history.data, isA<List<CommissionHistoryItem>>());
      if (history.data!.isNotEmpty) {
        expect(history.data!.first.id, isA<int>());
        expect(history.data!.first.orderAmount, isA<int>());
        expect(history.data!.first.tradeNo, isA<String>());
        expect(history.data!.first.getAmount, isA<int>());
        expect(history.data!.first.createdAt, isA<int>());
      }
    });
  });
}