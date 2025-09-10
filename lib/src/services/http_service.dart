import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/services.dart';
import '../exceptions/xboard_exceptions.dart';
import '../core/token/token_manager.dart';
import '../core/token/auth_interceptor.dart';

class HttpService {
  final String baseUrl;
  final String? proxyUrl;
  late final Dio _dio;
  TokenManager? _tokenManager;
  AuthInterceptor? _authInterceptor;
  String? _expectedCertificatePem;

  HttpService(this.baseUrl, {TokenManager? tokenManager, this.proxyUrl}) {
    _tokenManager = tokenManager;
    _loadClientCertificate();
    _initializeDio();
  }

  /// 初始化Dio配置
  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      responseType: ResponseType.plain,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0 (compatible; RmxDbGFzaC1XdWppZS1BUEkvMS4w)',
      },
    ));

    // 配置客户端证书和SSL验证
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      
      // 配置代理
      if (proxyUrl != null && proxyUrl!.isNotEmpty) {
        client.findProxy = (uri) {
          return "PROXY $proxyUrl";
        };
      }
      
      // 配置SSL证书验证
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        // 只验证证书，忽略主机名验证
        return _verifyCertificate(cert);
      };
      
      return client;
    };

    // 添加拦截器（生产环境移除日志拦截器）

    // 添加响应格式化拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onResponse: (response, handler) {
        // 检查是否需要解混淆
        response.data = _deobfuscateResponse(response);
        response.data = _normalizeResponse(response.data);
        handler.next(response);
      },
      onError: (error, handler) {
        final normalizedError = _handleDioError(error);
        handler.next(normalizedError);
      },
    ));

    // 添加认证拦截器（最后添加，确保它能处理认证相关错误）
    if (_tokenManager != null) {
      _authInterceptor = AuthInterceptor(tokenManager: _tokenManager!);
      _dio.interceptors.add(_authInterceptor!);
    }
  }

  /// 设置TokenManager
  void setTokenManager(TokenManager tokenManager) {
    _tokenManager = tokenManager;
    
    // 移除旧的认证拦截器
    if (_authInterceptor != null) {
      _dio.interceptors.remove(_authInterceptor!);
    }
    
    // 添加新的认证拦截器
    _authInterceptor = AuthInterceptor(tokenManager: tokenManager);
    _dio.interceptors.add(_authInterceptor!);
  }

  /// 设置认证token（向后兼容）
  @Deprecated('Use TokenManager instead')
  void setAuthToken(String token) {
    if (_tokenManager != null) {
      // 如果有TokenManager，通过它来设置token
      _tokenManager!.saveTokens(
        accessToken: token,
        refreshToken: '', // 临时值
        expiry: DateTime.now().add(const Duration(hours: 24)),
      );
    } else {
      // 兼容模式：直接设置header
      _dio.options.headers['Authorization'] = token.startsWith('Bearer ') ? token : 'Bearer $token';
    }
  }

  /// 清除认证token（向后兼容）
  @Deprecated('Use TokenManager instead')
  void clearAuthToken() {
    if (_tokenManager != null) {
      _tokenManager!.clearTokens();
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  /// 获取当前认证token（向后兼容）
  @Deprecated('Use TokenManager instead')
  String? getAuthToken() {
    if (_tokenManager != null) {
      // 这里返回null，因为TokenManager是异步的
      return null;
    } else {
      return _dio.options.headers['Authorization'];
    }
  }

  /// 发送GET请求
  Future<Map<String, dynamic>> getRequest(String path, {Map<String, String>? headers}) async {
    try {
      final response = await _dio.get(
        path,
        options: Options(headers: headers),
      );
      
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw _convertDioError(e);
    }
  }

  /// 发送POST请求
  Future<Map<String, dynamic>> postRequest(String path, Map<String, dynamic> data, {Map<String, String>? headers}) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        options: Options(headers: headers),
      );
      
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw _convertDioError(e);
    }
  }

  /// 发送PUT请求
  Future<Map<String, dynamic>> putRequest(String path, Map<String, dynamic> data, {Map<String, String>? headers}) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        options: Options(headers: headers),
      );
      
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw _convertDioError(e);
    }
  }

  /// 发送DELETE请求
  Future<Map<String, dynamic>> deleteRequest(String path, {Map<String, String>? headers}) async {
    try {
      final response = await _dio.delete(
        path,
        options: Options(headers: headers),
      );
      
      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw _convertDioError(e);
    }
  }

  /// 解混淆响应数据
  /// 
  /// Caddy混淆规则：replace "{\"status\"" "OBFS_9K8L7M6N_{\"status\""
  dynamic _deobfuscateResponse(Response response) {
    try {
      final responseText = response.data as String;
      
      // 自动检测是否包含混淆前缀
      final containsObfuscationPrefix = responseText.contains('OBFS_9K8L7M6N_');
      
      if (containsObfuscationPrefix) {
        // 反混淆：移除混淆前缀
        final deobfuscated = responseText.replaceAll('OBFS_9K8L7M6N_', '');
        return jsonDecode(deobfuscated);
      } else {
        // 没有混淆，尝试直接解析JSON
        if (responseText.trim().startsWith('{') || responseText.trim().startsWith('[')) {
          return jsonDecode(responseText);
        } else {
          return responseText;
        }
      }
    } catch (e) {
      // 解混淆失败，返回原始数据
      return response.data;
    }
  }

  /// 验证客户端证书
  /// 
  /// 只验证证书内容，忽略主机名验证
  bool _verifyCertificate(X509Certificate cert) {
    try {
      if (_expectedCertificatePem == null) {
        // 如果无法加载预期证书，则接受所有证书（开发模式）
        return true;
      }
      
      // 获取当前证书的PEM格式
      final currentCertPem = cert.pem;
      
      // 比较证书内容（忽略空白字符差异）
      final expectedNormalized = _expectedCertificatePem!.replaceAll(RegExp(r'\s+'), '');
      final currentNormalized = currentCertPem.replaceAll(RegExp(r'\s+'), '');
      
      return expectedNormalized == currentNormalized;
    } catch (e) {
      // 证书验证出错，为安全起见拒绝连接
      return false;
    }
  }
  
  /// 加载客户端证书
  void _loadClientCertificate() {
    try {
      // 异步加载证书文件
      rootBundle.loadString('packages/flutter_xboard_sdk/assets/cer/client-cert.crt').then((certContent) {
        _expectedCertificatePem = certContent;
      }).catchError((error) {
        // 加载失败，保持为null（开发模式下接受所有证书）
        _expectedCertificatePem = null;
      });
    } catch (e) {
      _expectedCertificatePem = null;
    }
  }

  /// 标准化响应格式
  Map<String, dynamic> _normalizeResponse(dynamic responseData) {
    if (responseData is! Map<String, dynamic>) {
      return {
        'success': true,
        'data': responseData,
      };
    }

    final jsonResponse = responseData;

    // 兼容两种响应格式：
    // 1. XBoard格式: {status: "success", data: {...}}
    // 2. 通用格式: {success: true, data: {...}}
    
    if (jsonResponse.containsKey('status')) {
      // XBoard格式 -> 转换为通用格式
      return {
        'success': jsonResponse['status'] == 'success',
        'status': jsonResponse['status'],
        'message': jsonResponse['message'],
        'data': jsonResponse['data'],
        'total': jsonResponse['total'],
      };
    } else if (jsonResponse.containsKey('success')) {
      // 已经是通用格式，直接返回
      return jsonResponse;
    } else {
      // 其他格式，包装为通用格式
      return {
        'success': true,
        'data': jsonResponse,
      };
    }
  }

  /// 处理Dio错误
  DioException _handleDioError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode!;
      final responseData = error.response!.data;
      
      String errorMessage = '请求失败 (状态码: $statusCode)';
      
      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        } else if (responseData.containsKey('error')) {
          errorMessage = responseData['error'];
        }
      }

      // 创建新的DioException，保持原有的错误信息但添加我们的错误消息
      return DioException(
        requestOptions: error.requestOptions,
        response: error.response,
        type: error.type,
        error: errorMessage,
        message: errorMessage,
      );
    }
    
    return error;
  }

  /// 转换Dio错误为XBoard异常
  XBoardException _convertDioError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final statusCode = error.response!.statusCode!;
        final errorMessage = error.message ?? '请求失败';
        
        if (statusCode == 401) {
          return AuthException(errorMessage);
        } else if (statusCode >= 400 && statusCode < 500) {
          return ApiException(errorMessage, statusCode);
        } else {
          return NetworkException(errorMessage);
        }
      } else {
        // 网络错误
        return NetworkException('网络连接失败: ${error.message}');
      }
    } else if (error is XBoardException) {
      return error;
    } else {
      return ApiException('请求失败: $error');
    }
  }

  /// 释放资源
  void dispose() {
    _dio.close();
  }

  /// 获取Dio实例（用于高级用法）
  Dio get dio => _dio;

  /// 获取TokenManager
  TokenManager? get tokenManager => _tokenManager;
} 