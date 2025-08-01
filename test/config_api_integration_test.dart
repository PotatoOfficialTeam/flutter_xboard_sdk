import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_xboard_sdk/flutter_xboard_sdk.dart';

void main() {
  group('ConfigApi Integration Tests', () {
    const baseUrl = 'https://apiv20801.wujie001.info';

    late HttpService httpService;
    late ConfigApi configApi;

    setUp(() {
      httpService = HttpService(baseUrl);
      configApi = ConfigApi(httpService);
    });

    test('getConfig should return a valid ConfigResponse', () async {
      final configResponse = await configApi.getConfig();

      expect(configResponse, isNotNull);
      expect(configResponse.status, 'success');
      expect(configResponse.data, isNotNull);
      expect(configResponse.data!.appDescription, isNotEmpty);
      expect(configResponse.data!.appUrl, isNotEmpty);

      print('Config Response: ${configResponse.toJson()}');
    });
  });
}
