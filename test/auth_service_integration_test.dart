import 'package:test/test.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';

void main() {
  group('AuthService Integration Tests', () {
    const String email = 'h89600912@gmail.com';
    const String password = '12345678';
    const String baseUrl = 'https://apiwj0801.wujie001.info';

    late XBoardSDK sdk;

    setUp(() async {
      sdk = XBoardSDK.instance;
      await sdk.initialize(baseUrl);
    });

    test('Login with invalid credentials should throw ApiException', () {
      // 使用一个错误的密码，并期望它抛出ApiException
      expect(
        () => sdk.login.login(email, 'wrongpassword'),
        throwsA(isA<ApiException>()),
      );
      print('Test with invalid credentials threw ApiException as expected.');
    });

    test('Full authentication flow: Login and get user info', () async {
      // Step 1: Login with valid credentials
      print('Attempting to login with email: $email');
      final loginResponse = await sdk.login.login(email, password);

      expect(loginResponse.success, isTrue, reason: 'Login should be successful');
      expect(loginResponse.data?.authData, isNotNull, reason: 'authData should not be null');
      expect(loginResponse.data!.authData!.isNotEmpty, isTrue, reason: 'authData should not be empty');

      final bearerToken = loginResponse.data!.authData!;
      print('Login successful, received authData: $bearerToken');

      // Step 2: Set the token in HttpService for subsequent authenticated requests
      sdk.setAuthToken(bearerToken);
      print('Auth token set for subsequent requests.');

      // Step 3: Get user info to validate the token
      print('Attempting to get user info...');
      final userInfoResponse = await sdk.userInfo.getUserInfo();

      expect(userInfoResponse.success, isTrue, reason: 'Get user info should be successful');
      expect(userInfoResponse.data, isNotNull, reason: 'User info data should not be null');
      expect(userInfoResponse.data!.email, email, reason: 'User email should match the logged-in user');
      print('Successfully fetched user info for: ${userInfoResponse.data!.email}');
      print('Test finished.');
    });
  });
}
