import 'package:flutter_xboard_sdk/src/services/http_service.dart';
import 'package:flutter_xboard_sdk/src/features/config/config_models.dart';

class ConfigApi {
  final HttpService _httpService;

  ConfigApi(this._httpService);

  /// 获取配置信息
  /// 无需认证
  Future<ConfigResponse> getConfig() async {
    final response = await _httpService.getRequest('/api/v1/guest/comm/config');
    return ConfigResponse.fromJson(response);
  }
}