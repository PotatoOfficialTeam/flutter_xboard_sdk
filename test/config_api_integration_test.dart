import 'package:test/test.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';

void main() {
  group('ConfigApi Integration Tests', () {
    const baseUrl = 'https://apiwj0801.wujie001.info';

    late XBoardSDK sdk;

    setUp(() async {
      sdk = XBoardSDK.instance;
      await sdk.initialize(baseUrl);
    });

    test('getConfig should return a valid ConfigResponse', () async {
      final configResponse = await sdk.config.getConfig();

      expect(configResponse, isNotNull);
      expect(configResponse.status, 'success');
      expect(configResponse.data, isNotNull);
      expect(configResponse.data!.appDescription, isNotEmpty);
      expect(configResponse.data!.appUrl, isNotEmpty);

      print('Config Response: ${configResponse.data?.toJson()}');
    });
  });
}
