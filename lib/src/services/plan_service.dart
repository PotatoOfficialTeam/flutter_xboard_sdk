import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/plan_models.dart';
import '../utils/subscription_cache.dart';

/// 套餐/计划服务
class PlanService {
  final String _baseUrl;
  final Map<String, String> _defaultHeaders;

  PlanService(this._baseUrl, this._defaultHeaders);

  /// 获取套餐列表
  Future<List<Plan>> fetchPlans() async {
    final accessToken = await SubscriptionCache.getAccessToken();
    if (accessToken == null) {
      throw Exception('未找到访问令牌，请先登录');
    }
    final response = await http.get(
      Uri.parse('$_baseUrl/api/v1/user/plan/fetch'),
      headers: {
        ..._defaultHeaders,
        'Authorization': accessToken,
      },
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == false) {
        throw Exception(data['message'] ?? '获取套餐失败');
      }
      return (data['data'] as List)
          .map((e) => Plan.fromJson(e))
          .toList();
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  }

  /// 获取套餐详情
  Future<Plan?> getPlanDetails(int planId) async {
    final plans = await fetchPlans();
    try {
      return plans.firstWhere((plan) => plan.id == planId);
    } catch (e) {
      return null;
    }
  }
} 