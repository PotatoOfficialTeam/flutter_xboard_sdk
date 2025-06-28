import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';

void main() {
  group('XBoard SDK Tests', () {
    test('SDK should be singleton', () {
      final sdk1 = XBoardSDK.instance;
      final sdk2 = XBoardSDK.instance;
      expect(sdk1, same(sdk2));
    });

    test('SDK should throw exception when base URL is empty', () {
      final sdk = XBoardSDK.instance;
      expect(
        () => sdk.initialize(''),
        throwsA(isA<ConfigException>()),
      );
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

    test('RegisterRequest should serialize correctly', () {
      final request = RegisterRequest(
        email: 'test@example.com',
        password: 'password123',
        inviteCode: 'INVITE123',
        emailCode: '123456',
      );

      final json = request.toJson();
      expect(json['email'], 'test@example.com');
      expect(json['password'], 'password123');
      expect(json['invite_code'], 'INVITE123');
      expect(json['email_code'], '123456');
    });

    test('LoginResponse should deserialize correctly', () {
      final json = {
        'success': true,
        'message': 'Login successful',
        'data': {
          'token': 'abc123',
          'user': {
            'email': 'test@example.com',
            'balance': 10000,
            'commission_balance': 5000,
            'transfer_enable': 1000000000,
            'created_at': 1640995200,
            'banned': 0,
            'remind_expire': 1,
            'remind_traffic': 1,
            'plan_id': 1,
            'uuid': 'test-uuid-123',
            'avatar_url': 'https://example.com/avatar.png',
          }
        }
      };

      final response = LoginResponse.fromJson(json);
      expect(response.success, true);
      expect(response.message, 'Login successful');
      expect(response.token, 'abc123');
      expect(response.user?['email'], 'test@example.com');
      expect(response.user?['balance'], 10000);
    });

    test('UserInfo should serialize and deserialize correctly', () {
      final user = UserInfo(
        email: 'test@example.com',
        balance: 10000, // 分为单位
        commissionBalance: 5000, // 分为单位
        transferEnable: 1000000000,
        createdAt: 1640995200,
        banned: false,
        remindExpire: true,
        remindTraffic: true,
        planId: 1,
        uuid: 'test-uuid-123',
        avatarUrl: 'https://example.com/avatar.png',
      );

      final json = user.toJson();
      final deserializedUser = UserInfo.fromJson(json);

      expect(deserializedUser.email, user.email);
      expect(deserializedUser.balance, user.balance);
      expect(deserializedUser.commissionBalance, user.commissionBalance);
      expect(deserializedUser.balanceInYuan, 100.0); // 10000分 = 100元
      expect(deserializedUser.commissionBalanceInYuan, 50.0); // 5000分 = 50元
    });
  });

  group('Balance Models Tests', () {
    test('SystemConfig should serialize and deserialize correctly', () {
      final config = SystemConfig(
        withdrawMethods: ['alipay', 'wechat'],
        withdrawEnabled: true,
        currency: 'CNY',
        currencySymbol: '¥',
      );

      final json = config.toJson();
      final deserializedConfig = SystemConfig.fromJson(json);

      expect(deserializedConfig.withdrawMethods, config.withdrawMethods);
      expect(deserializedConfig.withdrawEnabled, config.withdrawEnabled);
      expect(deserializedConfig.currency, config.currency);
      expect(deserializedConfig.currencySymbol, config.currencySymbol);
    });

    test('TransferResult should deserialize correctly', () {
      final json = {
        'status': 'success',
        'message': '转账成功',
        'data': {
          'email': 'test@example.com',
          'balance': 8000,
          'commission_balance': 2000,
          'transfer_enable': 1000000000,
          'created_at': 1640995200,
          'banned': 0,
          'remind_expire': 1,
          'remind_traffic': 1,
          'plan_id': 1,
          'uuid': 'test-uuid-123',
          'avatar_url': 'https://example.com/avatar.png',
        }
      };

      final result = TransferResult.fromJson(json);
      expect(result.success, true);
      expect(result.message, '转账成功');
      expect(result.updatedUserInfo?.balance, 8000);
    });
  });

  group('Exception Tests', () {
    test('NetworkException should be a XBoardException', () {
      const message = 'Network error';
      final exception = NetworkException(message);
      
      expect(exception, isA<XBoardException>());
      expect(exception.message, message);
      expect(exception.toString(), 'XBoardException: $message');
    });

    test('AuthException should be a XBoardException', () {
      const message = 'Auth error';
      final exception = AuthException(message);
      
      expect(exception, isA<XBoardException>());
      expect(exception.message, message);
      expect(exception.toString(), 'XBoardException: $message');
    });

    test('ApiException should be a XBoardException', () {
      const message = 'API error';
      final exception = ApiException(message);
      
      expect(exception, isA<XBoardException>());
      expect(exception.message, message);
    });

    test('ConfigException should be a XBoardException', () {
      const message = 'Config error';
      final exception = ConfigException(message);
      
      expect(exception, isA<XBoardException>());
      expect(exception.message, message);
    });

    test('ParameterException should be a XBoardException', () {
      const message = 'Parameter error';
      final exception = ParameterException(message);
      
      expect(exception, isA<XBoardException>());
      expect(exception.message, message);
    });
  });
}
