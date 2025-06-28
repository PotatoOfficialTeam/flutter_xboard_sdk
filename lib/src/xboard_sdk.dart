import 'services/http_service.dart';
import 'services/auth_service.dart';
import 'services/subscription_service.dart';
import 'services/balance_service.dart';
import 'utils/subscription_cache.dart';
import 'exceptions/xboard_exceptions.dart';

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

  /// 获取基础URL
  String? get baseUrl => _httpService.baseUrl;
} 