import 'http_service.dart';
import '../models/coupon_models.dart';

class CouponService {
  final HttpService _httpService;

  CouponService(this._httpService);

  /// 验证优惠券
  /// [code] 优惠码
  /// [planId] 套餐ID
  /// 返回优惠券验证响应
  /// 注意：需要先通过SDK设置token才能调用此方法
  Future<CouponResponse> checkCoupon(String code, int planId) async {
    final result = await _httpService.postRequest(
      '/api/v1/user/coupon/check',
      {
        'code': code,
        'plan_id': planId.toString(),
      },
    );

    return CouponResponse.fromJson(result);
  }

  /// 获取用户可用的优惠券列表
  /// [planId] 可选的套餐ID，用于筛选适用的优惠券
  /// 返回可用优惠券列表
  /// 注意：需要先通过SDK设置token才能调用此方法
  Future<AvailableCouponsResponse> getAvailableCoupons({int? planId}) async {
    String endpoint = '/api/v1/user/coupon';
    if (planId != null) {
      endpoint += '?plan_id=$planId';
    }

    final result = await _httpService.getRequest(endpoint);
    return AvailableCouponsResponse.fromJson(result);
  }

  /// 获取优惠券使用历史
  /// [page] 页码（从1开始）
  /// [pageSize] 每页数量
  /// 返回优惠券使用历史记录
  /// 注意：需要先通过SDK设置token才能调用此方法
  Future<Map<String, dynamic>> getCouponHistory({
    int page = 1,
    int pageSize = 20,
  }) async {
    final result = await _httpService.getRequest(
      '/api/v1/user/coupon/history?page=$page&limit=$pageSize',
    );

    if (result['success'] == true) {
      return {
        'success': true,
        'data': result['data'],
        'total': result['total'],
        'page': page,
        'pageSize': pageSize,
      };
    }

    throw Exception('获取优惠券历史失败: ${result['message'] ?? 'Unknown error'}');
  }


} 