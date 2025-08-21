import 'package:flutter_xboard_sdk/src/services/http_service.dart';
import 'package:flutter_xboard_sdk/src/features/invite/invite_models.dart';
import 'package:flutter_xboard_sdk/src/common/models/api_response.dart';
import 'package:flutter_xboard_sdk/src/exceptions/xboard_exceptions.dart';

class InviteApi {
  final HttpService _httpService;

  InviteApi(this._httpService);

  Future<ApiResponse<void>> generateInviteCode() async {
    try {
      final response = await _httpService.getRequest('/api/v1/user/invite/save');
      return ApiResponse.fromJson(response, (json) => null);
    } catch (e) {
      throw ApiException('Generate invite code failed: $e');
    }
  }

  Future<ApiResponse<InviteInfo>> fetchInviteCodes() async {
    try {
      final response = await _httpService.getRequest('/api/v1/user/invite/fetch');
      return ApiResponse.fromJson(response, (json) => InviteInfo.fromJson(json as Map<String, dynamic>));
    } catch (e) {
      throw ApiException('Fetch invite codes failed: $e');
    }
  }

  Future<ApiResponse<List<CommissionDetail>>> fetchCommissionDetails({
    required int current,
    required int pageSize,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final uri = '/api/v1/user/invite/details?current=$current&page_size=$pageSize&t=$timestamp';
      final response = await _httpService.getRequest(uri);
      return ApiResponse.fromJson(response, (json) => (json['data'] as List<dynamic>).map((e) => CommissionDetail.fromJson(e as Map<String, dynamic>)).toList());
    } catch (e) {
      throw ApiException('Fetch commission details failed: $e');
    }
  }

  String generateInviteLink(String code, {String? baseUrl}) {
    final base = baseUrl ?? "https://abcd168.icu";
    return '$base/?code=$code';
  }
}
