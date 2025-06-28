import 'http_service.dart';
import '../models/balance_models.dart';

class BalanceService {
  final HttpService _httpService;

  BalanceService(this._httpService);

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

      if (result['success'] == true) {
        return TransferResult(
          success: true,
          message: result['message'] ?? '佣金转移成功',
          transferAmount: transferAmount.toDouble(),
          newBalance: result['data']?['balance']?.toDouble(),
        );
      } else {
        return TransferResult(
          success: false,
          message: result['message'] ?? '佣金转移失败',
        );
      }
    } catch (e) {
      return TransferResult(
        success: false,
        message: '佣金转移异常: $e',
      );
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

      if (result['success'] == true) {
        return WithdrawResult(
          success: true,
          message: result['message'] ?? '提现申请成功',
          withdrawId: result['data']?['withdraw_id'],
          status: result['data']?['status'],
        );
      } else {
        return WithdrawResult(
          success: false,
          message: result['message'] ?? '提现申请失败',
        );
      }
    } catch (e) {
      return WithdrawResult(
        success: false,
        message: '提现申请异常: $e',
      );
    }
  }

  /// 获取系统配置
  /// 返回系统配置信息
  /// 注意：需要先通过SDK设置token才能调用此方法
  Future<SystemConfig> getSystemConfig() async {
    final result = await _httpService.getRequest('/api/v1/user/comm/config');

    if (result['success'] == true && result['data'] != null) {
      return SystemConfig.fromJson(result['data']);
    }

    throw Exception('获取系统配置失败: ${result['message'] ?? 'Unknown error'}');
  }

  /// 获取用户余额信息
  /// 返回余额详情
  /// 注意：需要先通过SDK设置token才能调用此方法
  Future<BalanceInfo> getBalanceInfo() async {
    try {
      final result = await _httpService.getRequest('/api/v1/user/info');

      if (result['success'] == true && result['data'] != null) {
        return BalanceInfo.fromJson(result['data']);
      }

      throw Exception('获取余额信息失败: ${result['message'] ?? 'Unknown error'}');
    } catch (e) {
      throw Exception('获取余额信息异常: $e');
    }
  }

  /// 获取提现历史记录
  /// [page] 页码（从1开始）
  /// [pageSize] 每页数量
  /// 返回提现记录列表
  /// 注意：需要先通过SDK设置token才能调用此方法
  Future<Map<String, dynamic>> getWithdrawHistory({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final result = await _httpService.getRequest(
        '/api/v1/user/order?page=$page&limit=$pageSize&type=withdraw',
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

      throw Exception('获取提现历史失败: ${result['message'] ?? 'Unknown error'}');
    } catch (e) {
      throw Exception('获取提现历史异常: $e');
    }
  }

  /// 获取佣金历史记录
  /// [page] 页码（从1开始）
  /// [pageSize] 每页数量
  /// 返回佣金记录列表
  /// 注意：需要先通过SDK设置token才能调用此方法
  Future<Map<String, dynamic>> getCommissionHistory({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final result = await _httpService.getRequest(
        '/api/v1/user/comm/log?page=$page&limit=$pageSize',
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

      throw Exception('获取佣金历史失败: ${result['message'] ?? 'Unknown error'}');
    } catch (e) {
      throw Exception('获取佣金历史异常: $e');
    }
  }
} 