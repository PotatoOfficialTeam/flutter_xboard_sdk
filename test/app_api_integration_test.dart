import 'package:test/test.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';

void main() {
  group('AppApi Integration Tests', () {
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

    test('fetchDedicatedAppInfo should return app info or throw 404', () async {
      try {
        final response = await sdk.appApi.fetchDedicatedAppInfo();
        expect(response.data, isNotNull);
        if (response.data != null) {
          expect(response.data, isA<AppInfo>());
        }
      } catch (e) {
        expect(e, isA<ApiException>());
        expect((e as ApiException).code, 404);
      }
    });

    // Note: Running this test will actually generate an app.
    // test('generateDedicatedApp should return success', () async {
    //   final response = await sdk.appApi.generateDedicatedApp(
    //     appName: 'Test App',
    //     appIcon: 'icon',
    //     appDescription: 'Test Description',
    //   );
    //   expect(response.status, 'success');
    //   expect(response.data, isA<AppInfo>());
    // });
  });
}
