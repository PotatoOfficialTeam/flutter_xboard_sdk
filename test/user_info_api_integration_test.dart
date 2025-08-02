import 'package:test/test.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';

void main() {
  group('UserInfoApi Integration Tests', () {
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

    test('getUserInfo should return user info', () async {
      final response = await sdk.userInfo.getUserInfo();
      expect(response.data, isA<UserInfo>());
      expect(response.data!.email, testEmail);
    });

    // Note: validateToken, getSubscriptionLink, resetSubscriptionLink, toggleTrafficReminder, toggleExpireReminder
    // tests might require specific setup or cleanup to avoid side effects.
    // They are commented out for now.

    // test('validateToken should return true for valid token', () async {
    //   final isValid = await sdk.userInfo.validateToken(sdk.getAuthToken()!); // Use current token
    //   expect(isValid.data, isTrue);
    // });

    // test('getSubscriptionLink should return a subscription link', () async {
    //   final link = await sdk.userInfo.getSubscriptionLink();
    //   expect(link.data, isNotNull);
    //   expect(link.data, startsWith('http'));
    // });

    // test('resetSubscriptionLink should return a new subscription link', () async {
    //   final newLink = await sdk.userInfo.resetSubscriptionLink();
    //   expect(newLink.data, isNotNull);
    //   expect(newLink.data, startsWith('http'));
    // });

    // test('toggleTrafficReminder should update traffic reminder setting', () async {
    //   final initialUserInfo = await sdk.userInfo.getUserInfo();
    //   final initialSetting = initialUserInfo.data!.remindTraffic;
    //   final response = await sdk.userInfo.toggleTrafficReminder(!initialSetting);
    //   expect(response.data, isNull); // Assuming success returns null data
    //   final updatedUserInfo = await sdk.userInfo.getUserInfo();
    //   expect(updatedUserInfo.data!.remindTraffic, !initialSetting);
    // });

    // test('toggleExpireReminder should update expire reminder setting', () async {
    //   final initialUserInfo = await sdk.userInfo.getUserInfo();
    //   final initialSetting = initialUserInfo.data!.remindExpire;
    //   final response = await sdk.userInfo.toggleExpireReminder(!initialSetting);
    //   expect(response.data, isNull); // Assuming success returns null data
    //   final updatedUserInfo = await sdk.userInfo.getUserInfo();
    //   expect(updatedUserInfo.data!.remindExpire, !initialSetting);
    // });
  });
}
