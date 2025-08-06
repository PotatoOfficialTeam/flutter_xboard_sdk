import 'package:flutter_xboard_sdk/src/services/http_service.dart';
import 'package:flutter_xboard_sdk/src/features/coupon/coupon_models.dart';
import 'package:flutter_xboard_sdk/src/exceptions/xboard_exceptions.dart';

class CouponApi {
  final HttpService _httpService;

  CouponApi(this._httpService);

  /// 验证优惠券
  /// [code] 优惠码
  /// [planId] 套餐ID
  /// 返回优惠券验证响应
  /// 注意：需要先通过SDK设置token才能调用此方法
  Future<CouponResponse> checkCoupon(String code, int planId) async {
    try {
      final result = await _httpService.postRequest(
        '/api/v1/user/coupon/check',
        {
          'code': code,
          'plan_id': planId.toString(),
        },
      );
      return CouponResponse.fromJson(result);
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('验证优惠券失败: $e');
    }
  }
}