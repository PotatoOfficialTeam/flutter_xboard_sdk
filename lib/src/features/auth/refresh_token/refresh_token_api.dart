import 'package:flutter_xboard_sdk/src/services/http_service.dart';
import 'package:flutter_xboard_sdk/src/common/models/api_response.dart';

class RefreshTokenApi {
  final HttpService _httpService;

  RefreshTokenApi(this._httpService);

  /// 刷新token
  /// 返回新的token信息
  Future<ApiResponse> refreshToken() async {
    final response = await _httpService.postRequest(
      "/api/v1/passport/auth/token",
      {},
    );
    return ApiResponse.fromJson(response, (json) => json);
  }
}