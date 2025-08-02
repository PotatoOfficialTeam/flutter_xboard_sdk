import 'package:test/test.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';

void main() {
  group('PaymentApi Integration Tests', () {
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

    test('getPaymentMethods should return a list of payment methods', () async {
      final response = await sdk.payment.getPaymentMethods();
      expect(response.data, isA<List<PaymentMethodInfo>>());
      expect(response.data, isNotEmpty);
    });

    // Note: submitOrderPayment and checkPaymentStatus tests require a valid tradeNo and methodId.
    // These tests might need to be run manually or with specific mock data.
    // test('submitOrderPayment should return a payment response', () async {
    //   final request = PaymentRequest(
    //     tradeNo: 'test_trade_no_123', // Replace with a valid tradeNo
    //     method: 'alipay', // Replace with a valid methodId
    //   );
    //   final response = await sdk.payment.submitOrderPayment(request);
    //   expect(response.data, isA<PaymentResponse>());
    // });

    // test('checkPaymentStatus should return payment status result', () async {
    //   final tradeNo = 'test_trade_no_123'; // Replace with a valid tradeNo
    //   final response = await sdk.payment.checkPaymentStatus(tradeNo);
    //   expect(response.data, isA<PaymentStatusResult>());
    // });
  });
}
