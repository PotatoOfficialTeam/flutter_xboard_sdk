import 'http_service.dart';
import '../models/plan_models.dart';
import '../exceptions/xboard_exceptions.dart';

/// 套餐/计划服务
class PlanService {
  final HttpService _httpService;

  PlanService(this._httpService);

  /// 获取套餐列表
  Future<List<Plan>> fetchPlans() async {
    try {
      final result = await _httpService.getRequest('/api/v1/user/plan/fetch');
      
      if (result['success'] != true) {
        throw ApiException(result['message']?.toString() ?? '获取套餐失败');
      }
      
      return (result['data'] as List)
          .map((e) => Plan.fromJson(e))
          .toList();
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('获取套餐列表时发生错误: $e');
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