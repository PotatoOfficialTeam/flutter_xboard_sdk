import 'services/http_service.dart';
import 'services/auth_service.dart';
import 'services/subscription_service.dart';
import 'services/balance_service.dart';
import 'services/coupon_service.dart';
import 'services/notice_service.dart';
import 'services/order_service.dart';
import 'services/payment_service.dart';
import 'services/plan_service.dart';
import 'services/ticket_service.dart';
import 'utils/subscription_cache.dart';
import 'exceptions/xboard_exceptions.dart';
import 'services/user_info_service.dart';

/// XBoard SDK主类
/// 提供对XBoard API的统一访问接口
class XBoardSDK {
  static XBoardSDK? _instance;
  static XBoardSDK get instance => _instance ??= XBoardSDK._internal();
  
  XBoardSDK._internal();

  late HttpService _httpService;
  late AuthService _authService;
  late SubscriptionService _subscriptionService;
  late BalanceService _balanceService;
  late CouponService _couponService;
  late NoticeService _noticeService;
  late OrderService _orderService;
  late PaymentService _paymentService;
  late PlanService _planService;
  late TicketService _ticketService;
  late UserInfoService _userInfoService;
  
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
    _authService = AuthService(_httpService);
    _subscriptionService = SubscriptionService(_httpService);
    _balanceService = BalanceService(_httpService);
    _couponService = CouponService(_httpService);
    _noticeService = NoticeService(_httpService);
    _orderService = OrderService(_httpService);
    _paymentService = PaymentService(_httpService);
    _planService = PlanService(_httpService);
    _ticketService = TicketService(_httpService);
    _userInfoService = UserInfoService(_httpService);
    
    // 初始化订阅缓存
    await SubscriptionCache.init();
    
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
    // 清除订阅缓存
    SubscriptionCache.clearAll();
  }

  /// 检查SDK是否已初始化
  bool get isInitialized => _isInitialized;

  /// 获取HTTP服务实例（供高级用户使用）
  HttpService get httpService => _httpService;

  /// 认证服务
  AuthService get auth => _authService;
  
  /// 订阅服务
  SubscriptionService get subscription => _subscriptionService;

  /// 余额服务
  BalanceService get balance => _balanceService;

  /// 优惠券服务
  CouponService get coupon => _couponService;

  /// 通知服务
  NoticeService get notice => _noticeService;

  /// 订单服务
  OrderService get order => _orderService;

  /// 支付服务
  PaymentService get payment => _paymentService;

  /// 套餐服务
  PlanService get plan => _planService;

  /// 工单服务
  TicketService get ticket => _ticketService;

  /// 用户信息服务
  UserInfoService get userInfo => _userInfoService;

  /// 获取基础URL
  String? get baseUrl => _httpService.baseUrl;
} 