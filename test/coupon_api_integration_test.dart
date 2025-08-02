import 'package:test/test.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';

void main() {
  group('CouponApi Integration Tests', () {
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

    test('checkCoupon should return a CouponResponse', () async {
      // Replace with a valid coupon code and plan ID for your test environment
      // This test might fail if the coupon code is invalid or expired.
      final couponCode = 'xiaoqi'; // Replace with a valid coupon code
      final planId = 5; // Replace with a valid plan ID

      try {
        final response = await sdk.couponApi.checkCoupon(couponCode, planId);
        expect(response, isNotNull);
        expect(response.success, isA<bool>());
        // Add more specific assertions based on expected coupon response
      } catch (e) {
        // Handle expected API errors, e.g., invalid coupon
        print('Error checking coupon: $e');
        // Depending on your test strategy, you might expect an ApiException here
        // expect(e, isA<ApiException>());
      }
    });
  });
}