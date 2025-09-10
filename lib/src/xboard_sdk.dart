import 'services/http_service.dart';
import 'core/token/token_manager.dart';
import 'core/token/token_storage_config.dart';

import 'features/payment/payment_api.dart';
import 'features/plan/plan_api.dart';
import 'features/ticket/ticket_api.dart';
import 'exceptions/xboard_exceptions.dart';
import 'features/user_info/user_info_api.dart';
import 'features/balance/balance_api.dart';
import 'features/coupon/coupon_api.dart';
import 'features/notice/notice_api.dart';
import 'features/order/order_api.dart';

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
  late TokenManager _tokenManager;

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
  late OrderApi _orderApi;
  late InviteApi _inviteApi;
  late AppApi _appApi;

  bool _isInitialized = false;

  /// 初始化SDK
  /// [baseUrl] XBoard服务器的基础URL
  /// [tokenConfig] Token存储配置，如果不提供则使用默认配置
  /// [proxyUrl] HTTP代理服务器地址，格式: username:password@host:port
  ///
  /// 示例:
  /// ```dart
  /// // 使用默认配置
  /// await XBoardSDK.instance.initialize('https://your-xboard-domain.com');
  /// 
  /// // 使用自定义配置
  /// await XBoardSDK.instance.initialize(
  ///   'https://your-xboard-domain.com',
  ///   tokenConfig: TokenStorageConfig.production(),
  /// );
  ///
  /// // 使用代理
  /// await XBoardSDK.instance.initialize(
  ///   'https://your-xboard-domain.com',
  ///   proxyUrl: 'username:password@proxy.example.com:8080',
  /// );
  /// ```
  Future<void> initialize(
    String baseUrl, {
    TokenStorageConfig? tokenConfig,
    String? proxyUrl,
  }) async {
    if (baseUrl.isEmpty) {
      throw ConfigException('Base URL cannot be empty');
    }

    // 移除URL末尾的斜杠
    final cleanUrl = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;

    // 初始化TokenManager
    final config = tokenConfig ?? TokenStorageConfig.defaultConfig();
    _tokenManager = TokenManager(
      storage: config.storage,
      refreshBuffer: config.refreshBuffer,
      autoRefresh: config.autoRefresh,
      onTokenExpired: config.onTokenExpired,
      onRefreshFailed: config.onRefreshFailed,
    );

    // 设置token刷新回调
    _tokenManager.setTokenRefreshCallback(() async {
      try {
        final refreshToken = await _tokenManager.getRefreshToken();
        if (refreshToken != null) {
          final response = await _refreshTokenApi.refreshToken();
          if (response.success == true && response.data != null) {
            // 这里需要根据实际的响应格式来解析token信息
            // 假设响应包含access_token, refresh_token, expires_in等字段
            final data = response.data as Map<String, dynamic>;
            final accessToken = data['access_token'] as String?;
            final newRefreshToken = data['refresh_token'] as String?;
            final expiresIn = data['expires_in'] as int?;
            
            if (accessToken != null && newRefreshToken != null && expiresIn != null) {
              final expiry = DateTime.now().add(Duration(seconds: expiresIn));
              return TokenInfo(
                accessToken: accessToken,
                refreshToken: newRefreshToken,
                expiry: expiry,
              );
            }
          }
        }
        return null;
      } catch (e) {
        return null;
      }
    });

    // 初始化HTTP服务
    _httpService = HttpService(cleanUrl, tokenManager: _tokenManager, proxyUrl: proxyUrl);

    // Initialize API instances
    _paymentApi = PaymentApi(_httpService);
    _planApi = PlanApi(_httpService);
    _ticketApi = TicketApi(_httpService);
    _userInfoApi = UserInfoApi(_httpService);
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
    _orderApi = OrderApi(_httpService);
    _inviteApi = InviteApi(_httpService);
    _appApi = AppApi(_httpService);

    _isInitialized = true;
  }

  /// 保存登录后的Token信息
  /// [accessToken] 访问令牌
  /// [refreshToken] 刷新令牌
  /// [expiry] 过期时间
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required DateTime expiry,
  }) async {
    await _tokenManager.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiry: expiry,
    );
  }

  /// 设置认证Token（向后兼容，建议使用saveTokens）
  @Deprecated('Use saveTokens instead for better token management')
  void setAuthToken(String token) {
    _httpService.setAuthToken(token);
  }

  /// 获取当前认证Token
  Future<String?> getAuthToken() async {
    return await _tokenManager.getAccessToken();
  }

  /// 清除所有Token
  Future<void> clearTokens() async {
    await _tokenManager.clearTokens();
  }

  /// 清除认证Token（向后兼容，建议使用clearTokens）
  @Deprecated('Use clearTokens instead')
  void clearAuthToken() {
    _httpService.clearAuthToken();
  }

  /// 检查Token是否有效
  Future<bool> isTokenValid() async {
    return await _tokenManager.isTokenValid();
  }

  /// 手动刷新Token
  Future<String?> refreshToken() async {
    return await _tokenManager.refreshToken();
  }

  /// 检查SDK是否已初始化
  bool get isInitialized => _isInitialized;

  /// 获取认证状态流
  Stream<AuthState> get authStateStream => _tokenManager.authStateStream;

  /// 获取当前认证状态
  AuthState get authState => _tokenManager.currentState;

  /// 是否已认证
  bool get isAuthenticated => _tokenManager.isAuthenticated;

  /// 获取HTTP服务实例（供高级用户使用）
  HttpService get httpService => _httpService;

  /// 获取TokenManager实例（供高级用户使用）
  TokenManager get tokenManager => _tokenManager;

  // New getters for modularized auth features
  LoginApi get login => _loginApi;
  RegisterApi get register => _registerApi;
  SendEmailCodeApi get sendEmailCode => _sendEmailCodeApi;
  ResetPasswordApi get resetPassword => _resetPasswordApi;
  RefreshTokenApi get refreshTokenApi => _refreshTokenApi;
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

  /// 便捷登录方法
  /// 登录成功后自动保存token
  Future<bool> loginWithCredentials(String email, String password) async {
    try {
      final response = await _loginApi.login(email, password);
      if (response.success == true && response.data != null) {
        final data = response.data!;
        // 优先使用authData，因为它包含完整的Bearer token格式
        // 如果authData不存在，则使用token字段
        final tokenToUse = data.authData ?? data.token;
        if (tokenToUse != null) {
          // 如果是authData，直接使用完整的Bearer token
          // 如果是token字段，需要添加Bearer前缀
          final fullToken = data.authData ?? 'Bearer ${data.token}';
          
          await saveTokens(
            accessToken: fullToken,
            refreshToken: fullToken, // 临时使用相同的token
            expiry: DateTime.now().add(const Duration(hours: 24)),
          );
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 释放SDK资源
  void dispose() {
    _tokenManager.dispose();
    _httpService.dispose();
  }
}