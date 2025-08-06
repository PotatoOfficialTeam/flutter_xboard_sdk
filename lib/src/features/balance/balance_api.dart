import 'package:flutter_xboard_sdk/src/services/http_service.dart';
import 'package:flutter_xboard_sdk/src/features/balance/balance_models.dart';
import 'package:flutter_xboard_sdk/src/exceptions/xboard_exceptions.dart';

import 'package:flutter_xboard_sdk/src/common/models/api_response.dart'; // Import ApiResponse

class BalanceApi {
  final HttpService _httpService;

  BalanceApi(this._httpService);

  /// 划转佣金到余额
  /// [transferAmount] 转账金额（分为单位）
  /// 返回转账结果
  /// 注意：需要先通过SDK设置token才能调用此方法
  Future<TransferResult> transferCommission(int transferAmount) async {
    try {
      final result = await _httpService.postRequest(
        '/api/v1/user/transfer',
        {'transfer_amount': transferAmount.toString()},
      );
      return TransferResult.fromJson(result);
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('划转佣金失败: $e');
    }
  }

  /// 申请提现
  /// [withdrawMethod] 提现方式
  /// [withdrawAccount] 提现账户
  /// 返回提现申请结果
  /// 注意：需要先通过SDK设置token才能调用此方法
  Future<WithdrawResult> withdrawFunds(
    String withdrawMethod,
    String withdrawAccount,
  ) async {
    try {
      final result = await _httpService.postRequest(
        '/api/v1/user/ticket/withdraw',
        {
          'withdraw_method': withdrawMethod,
          'withdraw_account': withdrawAccount,
        },
      );
      return WithdrawResult.fromJson(result);
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('申请提现失败: $e');
    }
  }

  /// 获取佣金历史记录
  /// 返回佣金记录列表
  /// 注意：需要先通过SDK设置token才能调用此方法
  Future<ApiResponse<List<CommissionHistoryItem>>> getCommissionHistory() async {
    try {
      final result = await _httpService.getRequest(
        '/api/v1/user/invite/details',
      );
      // 修正：从 result['data'] 中提取列表
      return ApiResponse.fromJson(result, (json) => (json['data'] as List<dynamic>).map((e) => CommissionHistoryItem.fromJson(e as Map<String, dynamic>)).toList());
    } catch (e) {
      if (e is XBoardException) rethrow;
      throw ApiException('获取佣金历史失败: $e');
    }
  }
}