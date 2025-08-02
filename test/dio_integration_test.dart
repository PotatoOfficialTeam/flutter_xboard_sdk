import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import '../lib/src/core/token/memory_token_storage.dart';
import '../lib/src/core/token/auth_interceptor.dart';

// 简化的TokenManager用于测试
class MockTokenManager {
  final MemoryTokenStorage _storage = MemoryTokenStorage();
  String? _currentToken;
  
  Future<void> saveToken(String token) async {
    _currentToken = token;
    await _storage.saveAccessToken(token);
  }
  
  Future<String?> getValidAccessToken() async {
    return _currentToken;
  }
  
  Future<String?> refreshToken() async {
    // 模拟刷新成功
    final newToken = 'refreshed_${_currentToken}';
    await saveToken(newToken);
    return newToken;
  }
  
  Future<void> clearTokens() async {
    _currentToken = null;
    await _storage.clearTokens();
  }
}

void main() async {
  print('🌐 Starting HTTP Integration Tests...\n');
  
  // 启动一个简单的HTTP服务器用于测试
  final server = await HttpServer.bind('localhost', 8899);
  print('📡 Test server started at http://localhost:8899');
  
  try {
    await testBasicHttpRequest(server);
    await testAuthInterceptor(server);
    await testTokenRefresh(server);
    print('\n✅ All HTTP integration tests passed!');
  } finally {
    await server.close();
    print('📡 Test server stopped');
  }
}

/// 测试基本HTTP请求
Future<void> testBasicHttpRequest(HttpServer server) async {
  print('🔧 Testing Basic HTTP Request...');
  
  // 设置服务器响应
  server.listen((request) async {
    if (request.uri.path == '/test') {
      request.response
        ..statusCode = 200
        ..headers.contentType = ContentType.json
        ..write('{"message": "Hello World"}');
    } else {
      request.response.statusCode = 404;
    }
    await request.response.close();
  });
  
  // 创建Dio实例
  final dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8899',
  ));
  
  // 发送请求
  final response = await dio.get('/test');
  
  myAssert(response.statusCode == 200, 'Status code should be 200');
  myAssert(response.data['message'] == 'Hello World', 'Response message should match');
  
  print('✅ Basic HTTP Request: PASSED');
}

/// 测试认证拦截器
Future<void> testAuthInterceptor(HttpServer server) async {
  print('🔐 Testing Auth Interceptor...');
  
  String? receivedAuthHeader;
  
  // 设置服务器响应
  server.listen((request) async {
    if (request.uri.path == '/protected') {
      receivedAuthHeader = request.headers.value('Authorization');
      request.response
        ..statusCode = 200
        ..headers.contentType = ContentType.json
        ..write('{"message": "Protected resource"}');
    } else if (request.uri.path == '/public') {
      receivedAuthHeader = request.headers.value('Authorization');
      request.response
        ..statusCode = 200
        ..headers.contentType = ContentType.json
        ..write('{"message": "Public resource"}');
    }
    await request.response.close();
  });
  
  // 创建TokenManager和Dio
  final tokenManager = MockTokenManager();
  await tokenManager.saveToken('test_auth_token');
  
  final dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8899',
  ));
  
  final authInterceptor = AuthInterceptor(
    tokenManager: tokenManager,
    publicEndpoints: {'/public'}, // 添加公开端点
  );
  dio.interceptors.add(authInterceptor);
  
  // 测试受保护端点
  await dio.get('/protected');
  myAssert(receivedAuthHeader == 'Bearer test_auth_token', 
           'Protected endpoint should receive auth token');
  
  // 测试公开端点
  receivedAuthHeader = null;
  await dio.get('/public');
  myAssert(receivedAuthHeader == null, 
           'Public endpoint should not receive auth token');
  
  print('✅ Auth Interceptor: PASSED');
}

/// 测试Token刷新机制
Future<void> testTokenRefresh(HttpServer server) async {
  print('🔄 Testing Token Refresh...');
  
  int requestCount = 0;
  String? finalAuthHeader;
  
  // 设置服务器响应
  server.listen((request) async {
    requestCount++;
    
    if (request.uri.path == '/api/protected') {
      final authHeader = request.headers.value('Authorization');
      
      if (requestCount == 1) {
        // 第一次请求返回401
        request.response.statusCode = 401;
      } else {
        // 第二次请求（刷新后）返回成功
        finalAuthHeader = authHeader;
        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType.json
          ..write('{"message": "Success after refresh"}');
      }
    }
    await request.response.close();
  });
  
  // 创建TokenManager和Dio
  final tokenManager = MockTokenManager();
  await tokenManager.saveToken('expired_token');
  
  final dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:8899',
  ));
  
  final authInterceptor = AuthInterceptor(tokenManager: tokenManager);
  dio.interceptors.add(authInterceptor);
  
  // 发送请求，应该触发token刷新
  final response = await dio.get('/api/protected');
  
  myAssert(response.statusCode == 200, 'Final response should be successful');
  myAssert(finalAuthHeader == 'Bearer refreshed_expired_token', 
           'Should use refreshed token');
  myAssert(requestCount == 2, 'Should make exactly 2 requests (original + retry)');
  
  print('✅ Token Refresh: PASSED');
}

/// 简单的断言函数
void myAssert(bool condition, String message) {
  if (!condition) {
    throw Exception('Assertion failed: $message');
  }
}