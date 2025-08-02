import 'package:test/test.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';

void main() {
  group('OrderApi Integration Tests', () {
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

    test('fetchUserOrders should return a list of orders', () async {
      final response = await sdk.orderApi.fetchUserOrders();
      expect(response, isNotNull);
      expect(response.data, isA<List<Order>>());
      expect(response.total, isA<int?>());
    });

    test('fetchPlans should return a list of plans', () async {
      final response = await sdk.orderApi.fetchPlans();
      expect(response, isNotNull);
      expect(response.data, isA<List<Plan>>());
      expect(response.total, isA<int?>());
    });

    test('getPaymentMethods should return a list of payment methods', () async {
      final response = await sdk.orderApi.getPaymentMethods();
      expect(response, isNotNull);
      expect(response.data, isA<List<PaymentMethod>>());
    });

    // Note: createOrder, getOrderDetails, cancelOrder, submitPayment
    // require specific conditions and might modify user data.
    // They are commented out for basic integration tests.
    // Uncomment and provide valid data for full testing.

    // test('createOrder should create a new order', () async {
    //   final response = await sdk.orderApi.createOrder(planId: 1, period: 'month');
    //   expect(response.success, isTrue);
    //   expect(response.data, isA<String>()); // tradeNo
    // });

    // test('getOrderDetails should return order details', () async {
    //   // Replace with a valid tradeNo from a created order
    //   final tradeNo = 'YOUR_TRADE_NO';
    //   final order = await sdk.orderApi.getOrderDetails(tradeNo);
    //   expect(order, isNotNull);
    //   expect(order.tradeNo, tradeNo);
    // });

    // test('cancelOrder should cancel an order', () async {
    //   // Replace with a valid tradeNo of a pending order
    //   final tradeNo = 'YOUR_PENDING_TRADE_NO';
    //   final response = await sdk.orderApi.cancelOrder(tradeNo);
    //   expect(response.success, isTrue);
    // });

    // test('submitPayment should submit payment', () async {
    //   // Replace with valid tradeNo and method
    //   final tradeNo = 'YOUR_TRADE_NO';
    //   final method = 'alipay';
    //   final response = await sdk.orderApi.submitPayment(tradeNo: tradeNo, method: method);
    //   expect(response.success, isTrue);
    // });
  });
}
