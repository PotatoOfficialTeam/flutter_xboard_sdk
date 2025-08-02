import 'services/http_service.dart';

import 'features/payment/payment_api.dart';
import 'features/plan/plan_api.dart';
import 'features/ticket/ticket_api.dart';
import 'exceptions/xboard_exceptions.dart';
import 'features/user_info/user_info_api.dart';
import 'features/balance/balance_api.dart';
import 'features/coupon/coupon_api.dart';
import 'features/notice/notice_api.dart';
import 'features/order/order_api.dart'; // Added this import

// New imports for modularized auth features
import 'features/app/app_api.dart';
import 'features/invite/invite_api.dart';
import 'features/auth/login/login_api.dart';
import 'features/auth/register/register_api.dart';
import 'features/auth/send_email_code/send_email_code_api.dart';
import 'features/auth/reset_password/reset_password_api.dart';
import 'features/auth/refresh_token/refresh_token_api.dart';
import 'features/config/config_api.dart';
import 'features/subscription/subscription_api.dart';

/// XBoard SDK主类
/// 提供对XBoard API的统一访问接口
class XBoardSDK {
  static XBoardSDK? _instance;
  static XBoardSDK get instance => _instance ??= XBoardSDK._internal();

  XBoardSDK._internal();

  late HttpService _httpService;

  late PaymentApi _paymentApi;
  late PlanApi _planApi;
  late TicketApi _ticketApi;
  late UserInfoApi _userInfoApi;

  // New API instances for modularized auth features
  late LoginApi _loginApi;
  late RegisterApi _registerApi;
  late SendEmailCodeApi _sendEmailCodeApi;
  late ResetPasswordApi _resetPasswordApi;
  late RefreshTokenApi _refreshTokenApi;
  late ConfigApi _configApi;
  late SubscriptionApi _subscriptionApi;
  late BalanceApi _balanceApi;
  late CouponApi _couponApi;
  late NoticeApi _noticeApi;
  late OrderApi _orderApi; // Added this line
  late InviteApi _inviteApi;
  late AppApi _appApi;

  String? _authToken;
  bool _isInitialized = false;

  /// 初始化SDK
  /// [baseUrl] XBoard服务器的基础URL
  ///
  /// 示例:
  /// ```dart
  /// await XBoardSDK.instance.initialize('https://your-xboard-domain.com');
  /// ```
  Future<void> initialize(String baseUrl) async {
    if (baseUrl.isEmpty) {
      throw ConfigException('Base URL cannot be empty');
    }

    // 移除URL末尾的斜杠
    final cleanUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    _httpService = HttpService(cleanUrl);

    _paymentApi = PaymentApi(_httpService);
    _planApi = PlanApi(_httpService);
    _ticketApi = TicketApi(_httpService);
    _userInfoApi = UserInfoApi(_httpService);

    // Initialize new API instances
    _loginApi = LoginApi(_httpService);
    _registerApi = RegisterApi(_httpService);
    _sendEmailCodeApi = SendEmailCodeApi(_httpService);
    _resetPasswordApi = ResetPasswordApi(_httpService);
    _refreshTokenApi = RefreshTokenApi(_httpService);
    _configApi = ConfigApi(_httpService);
    _subscriptionApi = SubscriptionApi(_httpService);
    _balanceApi = BalanceApi(_httpService);
    _couponApi = CouponApi(_httpService);
    _noticeApi = NoticeApi(_httpService);
    _orderApi = OrderApi(_httpService); // Added this line
    _inviteApi = InviteApi(_httpService);
    _appApi = AppApi(_httpService);

    _isInitialized = true;
  }

  /// 设置认证Token
  void setAuthToken(String token) {
    _authToken = token;
    _httpService.setAuthToken(token);
  }

  /// 获取当前认证Token
  String? getAuthToken() {
    return _authToken;
  }

  /// 清除认证Token
  void clearAuthToken() {
    _authToken = null;
    _httpService.clearAuthToken();
  }

  /// 检查SDK是否已初始化
  bool get isInitialized => _isInitialized;

  /// 获取HTTP服务实例（供高级用户使用）
  HttpService get httpService => _httpService;

  // New getters for modularized auth features
  LoginApi get login => _loginApi;
  RegisterApi get register => _registerApi;
  SendEmailCodeApi get sendEmailCode => _sendEmailCodeApi;
  ResetPasswordApi get resetPassword => _resetPasswordApi;
  RefreshTokenApi get refreshToken => _refreshTokenApi;
  ConfigApi get config => _configApi;
  SubscriptionApi get subscription => _subscriptionApi;
  BalanceApi get balanceApi => _balanceApi;
  CouponApi get couponApi => _couponApi;
  NoticeApi get noticeApi => _noticeApi;
  OrderApi get orderApi => _orderApi; // Added this line
  InviteApi get inviteApi => _inviteApi;
  AppApi get appApi => _appApi;

  /// 支付服务
  PaymentApi get payment => _paymentApi;

  /// 套餐服务
  PlanApi get plan => _planApi;

  /// 工单服务
  TicketApi get ticket => _ticketApi;

  /// 用户信息服务
  UserInfoApi get userInfo => _userInfoApi;

  /// 获取基础URL
  String? get baseUrl => _httpService.baseUrl;
}