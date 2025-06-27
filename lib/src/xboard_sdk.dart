import 'services/http_service.dart';
import 'services/auth_service.dart';
import 'exceptions/xboard_exceptions.dart';

/// XBoard SDK主类
/// 提供对XBoard API的统一访问接口
class XBoardSDK {
  static XBoardSDK? _instance;
  late final HttpService _httpService;
  late final AuthService auth;

  /// 私有构造函数
  XBoardSDK._internal() {
    _httpService = HttpService();
    auth = AuthService(_httpService);
  }

  /// 获取SDK单例实例
  static XBoardSDK get instance {
    _instance ??= XBoardSDK._internal();
    return _instance!;
  }

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
    
    _httpService.setBaseUrl(cleanUrl);
  }

  /// 设置认证token
  /// [token] 用户认证token
  void setAuthToken(String token) {
    if (token.isEmpty) {
      throw ParameterException('Token cannot be empty');
    }
    _httpService.setToken(token);
  }

  /// 清除认证token
  void clearAuthToken() {
    _httpService.clearToken();
  }

  /// 检查SDK是否已初始化
  bool get isInitialized {
    try {
      // 尝试进行一个简单的操作来检查是否已初始化
      _httpService.getRequest('/test');
      return true;
    } catch (e) {
      if (e.toString().contains('Base URL not set')) {
        return false;
      }
      return true; // 其他错误说明已初始化但可能是网络问题
    }
  }

  /// 获取HTTP服务实例（供高级用户使用）
  HttpService get httpService => _httpService;
} 