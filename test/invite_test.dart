import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';

void main() {
  group('邀请码功能测试', () {
    test('测试 InviteCode 模型解析', () {
      final inviteCodeJson = {
        'user_id': 123,
        'code': 'ABC123',
        'pv': 45,
        'status': 1,
        'created_at': 1640995200,
        'updated_at': 1640995200,
      };

      final inviteCode = InviteCode.fromJson(inviteCodeJson);
      
      expect(inviteCode.userId, equals(123));
      expect(inviteCode.code, equals('ABC123'));
      expect(inviteCode.pv, equals(45));
      expect(inviteCode.status, equals(1));
      expect(inviteCode.isActive, isTrue);
      expect(inviteCode.createdAt, equals(1640995200));
      expect(inviteCode.updatedAt, equals(1640995200));
    });

    test('测试 InviteCodeData 模型解析', () {
      final dataJson = {
        'codes': [
          {
            'user_id': 123,
            'code': 'ABC123',
            'pv': 45,
            'status': 1,
            'created_at': 1640995200,
            'updated_at': 1640995200,
          }
        ],
        'stat': [100, 80, 5000],
      };

      final inviteCodeData = InviteCodeData.fromJson(dataJson);
      
      expect(inviteCodeData.codes.length, equals(1));
      expect(inviteCodeData.codes.first.code, equals('ABC123'));
      expect(inviteCodeData.stat, equals([100, 80, 5000]));
      expect(inviteCodeData.totalInvites, equals(100));
      expect(inviteCodeData.validInvites, equals(80));
      expect(inviteCodeData.totalCommission, equals(5000));
    });
  });
}
