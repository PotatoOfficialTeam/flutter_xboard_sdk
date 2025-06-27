import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';

void main() {
  group('XBoard SDK Tests', () {
    late XBoardSDK sdk;

    setUp(() {
      sdk = XBoardSDK.instance;
    });

    test('SDK should be singleton', () {
      final sdk1 = XBoardSDK.instance;
      final sdk2 = XBoardSDK.instance;
      expect(sdk1, same(sdk2));
    });

    test('SDK should throw exception when base URL is empty', () {
      expect(
        () => sdk.initialize(''),
        throwsA(isA<ConfigException>()),
      );
    });

    test('SDK should set auth token correctly', () {
      const token = 'test_token_123';
      expect(() => sdk.setAuthToken(token), returnsNormally);
    });

    test('SDK should throw exception when token is empty', () {
      expect(
        () => sdk.setAuthToken(''),
        throwsA(isA<ParameterException>()),
      );
    });

    test('SDK should clear auth token', () {
      sdk.setAuthToken('test_token');
      expect(() => sdk.clearAuthToken(), returnsNormally);
    });

    test('AuthService should be accessible', () {
      expect(sdk.auth, isA<AuthService>());
    });

    test('HttpService should be accessible', () {
      expect(sdk.httpService, isA<HttpService>());
    });
  });

  group('Auth Models Tests', () {
    test('LoginRequest should serialize correctly', () {
      final request = LoginRequest(
        email: 'test@example.com',
        password: 'password123',
      );

      final json = request.toJson();
      expect(json['email'], 'test@example.com');
      expect(json['password'], 'password123');
    });

    test('LoginResponse should deserialize correctly', () {
      final json = {
        'success': true,
        'message': 'Login successful',
        'data': {
          'token': 'abc123',
          'user': {
            'id': 1,
            'email': 'test@example.com',
            'balance': 1000,
          }
        }
      };

      final response = LoginResponse.fromJson(json);
      expect(response.success, true);
      expect(response.message, 'Login successful');
      expect(response.token, 'abc123');
      expect(response.user?.id, 1);
      expect(response.user?.email, 'test@example.com');
    });

    test('UserInfo should serialize and deserialize correctly', () {
      final user = UserInfo(
        id: 1,
        email: 'test@example.com',
        balance: 1000,
        commissionBalance: 500,
      );

      final json = user.toJson();
      final deserializedUser = UserInfo.fromJson(json);

      expect(deserializedUser.id, user.id);
      expect(deserializedUser.email, user.email);
      expect(deserializedUser.balance, user.balance);
      expect(deserializedUser.commissionBalance, user.commissionBalance);
    });
  });
}
