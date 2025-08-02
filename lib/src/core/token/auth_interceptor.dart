import 'package:dio/dio.dart';
import 'token_manager.dart';

/// 认证拦截器
/// 自动处理HTTP请求的token添加、刷新和401错误重试
class AuthInterceptor extends Interceptor {
  final TokenManager _tokenManager;
  final Set<String> _publicEndpoints;
  final int _maxRetries;

  AuthInterceptor({
    required TokenManager tokenManager,
    Set<String>? publicEndpoints,
    int maxRetries = 1,
  })  : _tokenManager = tokenManager,
        _publicEndpoints = publicEndpoints ?? _defaultPublicEndpoints,
        _maxRetries = maxRetries;

  /// 默认的公开端点（无需token的接口）
  static const Set<String> _defaultPublicEndpoints = {
    '/api/v1/passport/auth/login',
    '/api/v1/passport/auth/register',
    '/api/v1/passport/comm/sendEmailVerify',
    '/api/v1/passport/auth/forget',
    '/api/v1/guest/comm/config',
  };

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // 检查是否为公开端点
      if (_isPublicEndpoint(options.path)) {
        print('[AuthInterceptor] Public endpoint, skipping token: ${options.path}');
        handler.next(options);
        return;
      }

      // 获取有效的访问token（应该已经包含Bearer前缀）
      final token = await _tokenManager.getValidAccessToken();
      if (token != null) {
        options.headers['Authorization'] = token;
        print('[AuthInterceptor] Added token to request: ${options.path}');
      } else {
        print('[AuthInterceptor] No valid token available for: ${options.path}');
      }

      handler.next(options);
    } catch (e) {
      print('[AuthInterceptor] Error in onRequest: $e');
      handler.next(options); // 继续请求，让服务器返回401
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('[AuthInterceptor] Response: ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    
    print('[AuthInterceptor] Error: ${err.response?.statusCode} ${requestOptions.path}');

    // 处理401未授权错误和403权限错误（通常也表示token过期）
    if ((err.response?.statusCode == 401 || err.response?.statusCode == 403) && !_isPublicEndpoint(requestOptions.path)) {
      try {
        // 检查是否已经重试过
        final retryCount = requestOptions.extra['retry_count'] as int? ?? 0;
        if (retryCount >= _maxRetries) {
          print('[AuthInterceptor] Max retries reached for: ${requestOptions.path}');
          handler.next(err);
          return;
        }

        print('[AuthInterceptor] Attempting to refresh token for ${err.response?.statusCode} error');

        // 尝试刷新token
        final newToken = await _tokenManager.refreshToken();
        if (newToken != null) {
          print('[AuthInterceptor] Token refreshed successfully, retrying request');

          // 直接使用刷新后的token（应该已经包含Bearer前缀）
          requestOptions.headers['Authorization'] = newToken;
          requestOptions.extra['retry_count'] = retryCount + 1;

          // 重新发起请求
          try {
            final dio = Dio();
            final cloneReq = await dio.fetch(requestOptions);
            handler.resolve(cloneReq);
            return;
          } catch (retryError) {
            print('[AuthInterceptor] Retry request failed: $retryError');
            handler.next(err);
            return;
          }
        } else {
          print('[AuthInterceptor] Token refresh failed');
          // 刷新失败，清除本地token
          await _tokenManager.clearTokens();
        }
      } catch (refreshError) {
        print('[AuthInterceptor] Error during token refresh: $refreshError');
      }
    }

    handler.next(err);
  }

  /// 检查是否为公开端点
  bool _isPublicEndpoint(String path) {
    // 精确匹配
    if (_publicEndpoints.contains(path)) {
      return true;
    }

    // 路径匹配（考虑查询参数）
    for (final endpoint in _publicEndpoints) {
      if (path.startsWith(endpoint)) {
        // 确保是完整路径匹配，避免误匹配
        final remaining = path.substring(endpoint.length);
        if (remaining.isEmpty || remaining.startsWith('?') || remaining.startsWith('/')) {
          return true;
        }
      }
    }

    return false;
  }

  /// 添加公开端点
  void addPublicEndpoint(String endpoint) {
    _publicEndpoints.add(endpoint);
  }

  /// 移除公开端点
  void removePublicEndpoint(String endpoint) {
    _publicEndpoints.remove(endpoint);
  }

  /// 获取所有公开端点
  Set<String> get publicEndpoints => Set.unmodifiable(_publicEndpoints);
}

/// 带重试机制的认证拦截器
class RetryAuthInterceptor extends AuthInterceptor {
  final Duration _retryDelay;

  RetryAuthInterceptor({
    required TokenManager tokenManager,
    Set<String>? publicEndpoints,
    int maxRetries = 3,
    Duration retryDelay = const Duration(milliseconds: 500),
  })  : _retryDelay = retryDelay,
        super(
          tokenManager: tokenManager,
          publicEndpoints: publicEndpoints,
          maxRetries: maxRetries,
        );

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    
    // 对于网络错误，尝试重试
    if (_isNetworkError(err) && !_isPublicEndpoint(requestOptions.path)) {
      final retryCount = requestOptions.extra['network_retry_count'] as int? ?? 0;
      if (retryCount < _maxRetries) {
        print('[RetryAuthInterceptor] Network error, retrying (${retryCount + 1}/$_maxRetries): ${requestOptions.path}');
        
        await Future.delayed(_retryDelay);
        
        requestOptions.extra['network_retry_count'] = retryCount + 1;
        
        try {
          final dio = Dio();
          final cloneReq = await dio.fetch(requestOptions);
          handler.resolve(cloneReq);
          return;
        } catch (retryError) {
          print('[RetryAuthInterceptor] Retry failed: $retryError');
        }
      }
    }

    // 调用父类的错误处理（处理401错误）
    super.onError(err, handler);
  }

  /// 判断是否为网络错误
  bool _isNetworkError(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.sendTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.connectionError;
  }
}