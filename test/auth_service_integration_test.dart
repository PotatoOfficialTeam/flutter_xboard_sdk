import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';

void main() {
  group('AuthService Integration Tests', () {
    const baseUrl = 'https://apiv20801.wujie001.info';
    const email = 'alonmadeit@gmail.com';
    const password = '12345678';

    late HttpService httpService;
    late LoginApi loginApi;

    setUp(() {
      httpService = HttpService(baseUrl);
      loginApi = LoginApi(httpService);
    });

    test('Login with invalid credentials should throw AuthException', () {
      // 使用一个错误的密码，并期望它抛出AuthException
      expect(
        () => loginApi.login(email, 'wrongpassword'),
        throwsA(isA<ApiException>()),
      );
      print('Test with invalid credentials threw AuthException as expected.');
    });

    test('Full authentication flow: Login and get user info', () async {
      // Step 1: Login with valid credentials
      print('Attempting to login with email: $email');
      final loginResponse = await loginApi.login(email, password);

      expect(loginResponse.success, isTrue, reason: 'Login should be successful');
      expect(loginResponse.data?.authData, isNotNull, reason: 'authData should not be null');
      expect(loginResponse.data!.authData!.isNotEmpty, isTrue, reason: 'authData should not be empty');

      final bearerToken = loginResponse.data!.authData!;
      print('Login successful, received authData: $bearerToken');

      // Step 2: Set the token in HttpService for subsequent authenticated requests
      httpService.setAuthToken(bearerToken);
      print('Auth token set for subsequent requests.');

      // Step 3: Get user info to validate the token
      final userInfoService = UserInfoService(httpService);
      print('Attempting to get user info...');
      final userInfoResponse = await userInfoService.getUserInfo();

      expect(userInfoResponse.success, isTrue, reason: 'Get user info should be successful');
      expect(userInfoResponse.data, isNotNull, reason: 'User info data should not be null');
      expect(userInfoResponse.data!.email, email, reason: 'User email should match the logged-in user');
      print('Successfully fetched user info for: ${userInfoResponse.data!.email}');
      print('Test finished.');
    });
  });
}