import 'package:flutter_xboard_sdk/src/services/http_service.dart';
import 'package:flutter_xboard_sdk/src/features/app/app_models.dart';
import 'package:flutter_xboard_sdk/src/common/models/api_response.dart';
import 'package:flutter_xboard_sdk/src/exceptions/xboard_exceptions.dart';

class AppApi {
  final HttpService _httpService;

  AppApi(this._httpService);

  Future<ApiResponse<AppInfo>> generateDedicatedApp({
    required String appName,
    required String appIcon,
    required String appDescription,
  }) async {
    try {
      final response = await _httpService.postRequest(
        '/api/v1/user/app/save',
        {
          'name': appName,
          'icon': appIcon,
          'description': appDescription,
        },
      );
      return ApiResponse.fromJson(response, (json) => AppInfo.fromJson(json as Map<String, dynamic>));
    } on XBoardException {
      rethrow;
    } catch (e) {
      throw ApiException('Generate dedicated app failed: $e');
    }
  }

  Future<ApiResponse<AppInfo>> fetchDedicatedAppInfo() async {
    try {
      final response = await _httpService.getRequest('/api/v1/user/app/fetch');
      return ApiResponse.fromJson(response, (json) => AppInfo.fromJson(json as Map<String, dynamic>));
    } on XBoardException {
      rethrow;
    } catch (e) {
      throw ApiException('Fetch dedicated app info failed: $e');
    }
  }
}
