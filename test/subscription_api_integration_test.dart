import 'package:test/test.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';

void main() {
  group('SubscriptionApi Integration Tests', () {
    const String email = 'h89600912@gmail.com';
    const String password = '12345678';
    const String baseUrl = 'https://apiwj0801.wujie001.info';

    late XBoardSDK sdk;

    setUp(() async {
      sdk = XBoardSDK.instance;
      await sdk.initialize(baseUrl);
      final loginResponse = await sdk.login.login(email, password);
      sdk.setAuthToken(loginResponse.data!.authData!);
    });

    test('getSubscriptionLink should return valid subscription info', () async {
      final subscriptionResponse = await sdk.subscription.getSubscriptionLink();

      expect(subscriptionResponse.success, isTrue, reason: 'Subscription link retrieval should be successful');
      expect(subscriptionResponse.data, isNotNull, reason: 'Subscription data should not be null');
      expect(subscriptionResponse.data!.subscribeUrl, isNotNull, reason: 'Subscribe URL should not be null');
      expect(subscriptionResponse.data!.subscribeUrl, isNotEmpty, reason: 'Subscribe URL should not be empty');

      print('Subscription Info: ${subscriptionResponse.data}');
    });

    test('getSubscriptionStats should return valid subscription stats', () async {
      final subscriptionStats = await sdk.subscription.getSubscriptionStats();

      expect(subscriptionStats, isNotNull, reason: 'Subscription stats should not be null');

      print('Subscription Stats: ${subscriptionStats}');
    });

    test('getPlanName should return plan name', () async {
      final planName = await sdk.subscription.getPlanName();

      expect(planName, isNotNull, reason: 'Plan name should not be null');
      expect(planName, isNotEmpty, reason: 'Plan name should not be empty');

      print('Plan Name: $planName');
    });
  });
}
