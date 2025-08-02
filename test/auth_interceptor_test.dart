import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:flutter_xboard_sdk/src/core/token/auth_interceptor.dart';
import 'package:flutter_xboard_sdk/src/core/token/token_manager.dart';
import 'package:flutter_xboard_sdk/src/core/token/memory_token_storage.dart';

void main() {
  group('AuthInterceptor Unit Tests', () {
    late TokenManager tokenManager;
    late AuthInterceptor authInterceptor;
    late Dio dio;

    setUp(() {
      tokenManager = TokenManager(storage: MemoryTokenStorage());
      authInterceptor = AuthInterceptor(tokenManager: tokenManager);
      dio = Dio();
      dio.interceptors.add(authInterceptor);
    });

    tearDown(() {
      tokenManager.dispose();
    });

    group('请求拦截', () {
      test('应该为认证端点添加token', () async {
        // Arrange
        await tokenManager.saveTokens(
          accessToken: 'test_token',
          refreshToken: 'test_refresh',
          expiry: DateTime.now().add(const Duration(hours: 1)),
        );

        final requestOptions = RequestOptions(path: '/api/v1/user/info');
        final handler = MockRequestInterceptorHandler();

        // Act
        await authInterceptor.onRequest(requestOptions, handler);

        // Assert
        expect(requestOptions.headers['Authorization'], equals('Bearer test_token'));
        expect(handler.nextCalled, isTrue);
      });

      test('不应该为公开端点添加token', () async {
        // Arrange
        await tokenManager.saveTokens(
          accessToken: 'test_token',
          refreshToken: 'test_refresh',
          expiry: DateTime.now().add(const Duration(hours: 1)),
        );

        final requestOptions = RequestOptions(path: '/api/v1/passport/auth/login');
        final handler = MockRequestInterceptorHandler();

        // Act
        await authInterceptor.onRequest(requestOptions, handler);

        // Assert
        expect(requestOptions.headers.containsKey('Authorization'), isFalse);
        expect(handler.nextCalled, isTrue);
      });

      test('无token时不应该添加Authorization头', () async {
        // Arrange
        final requestOptions = RequestOptions(path: '/api/v1/user/info');
        final handler = MockRequestInterceptorHandler();

        // Act
        await authInterceptor.onRequest(requestOptions, handler);

        // Assert
        expect(requestOptions.headers.containsKey('Authorization'), isFalse);
        expect(handler.nextCalled, isTrue);
      });

      test('应该正确识别公开端点', () async {
        // Arrange
        final publicPaths = [
          '/api/v1/passport/auth/login',
          '/api/v1/passport/auth/register',
          '/api/v1/passport/comm/sendEmailVerify',
          '/api/v1/passport/auth/forget',
          '/api/v1/guest/comm/config',
        ];

        await tokenManager.saveTokens(
          accessToken: 'test_token',
          refreshToken: 'test_refresh',
          expiry: DateTime.now().add(const Duration(hours: 1)),
        );

        // Act & Assert
        for (final path in publicPaths) {
          final requestOptions = RequestOptions(path: path);
          final handler = MockRequestInterceptorHandler();

          await authInterceptor.onRequest(requestOptions, handler);

          expect(
            requestOptions.headers.containsKey('Authorization'),
            isFalse,
            reason: 'Path $path should be public',
          );
        }
      });
    });

    group('401错误处理', () {
      test('401错误应该触发token刷新和重试', () async {
        // Arrange
        await tokenManager.saveTokens(
          accessToken: 'expired_token',
          refreshToken: 'valid_refresh',
          expiry: DateTime.now().add(const Duration(hours: 1)),
        );

        // 设置刷新回调
        tokenManager.setTokenRefreshCallback(() async {
          return TokenInfo(
            accessToken: 'new_token',
            refreshToken: 'new_refresh',
            expiry: DateTime.now().add(const Duration(hours: 1)),
          );
        });

        final requestOptions = RequestOptions(path: '/api/v1/user/info');
        final response = Response(
          requestOptions: requestOptions,
          statusCode: 401,
        );
        final dioException = DioException(
          requestOptions: requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );

        final handler = MockErrorInterceptorHandler();

        // Act
        await authInterceptor.onError(dioException, handler);

        // Assert
        expect(handler.resolveCalled, isTrue);
        expect(requestOptions.headers['Authorization'], equals('Bearer new_token'));
      });

      test('公开端点的401错误不应该触发刷新', () async {
        // Arrange
        await tokenManager.saveTokens(
          accessToken: 'test_token',
          refreshToken: 'test_refresh',
          expiry: DateTime.now().add(const Duration(hours: 1)),
        );

        bool refreshCalled = false;
        tokenManager.setTokenRefreshCallback(() async {
          refreshCalled = true;
          return null;
        });

        final requestOptions = RequestOptions(path: '/api/v1/passport/auth/login');
        final response = Response(
          requestOptions: requestOptions,
          statusCode: 401,
        );
        final dioException = DioException(
          requestOptions: requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );

        final handler = MockErrorInterceptorHandler();

        // Act
        await authInterceptor.onError(dioException, handler);

        // Assert
        expect(refreshCalled, isFalse);
        expect(handler.nextCalled, isTrue);
      });

      test('token刷新失败应该清除本地token', () async {
        // Arrange
        await tokenManager.saveTokens(
          accessToken: 'expired_token',
          refreshToken: 'invalid_refresh',
          expiry: DateTime.now().add(const Duration(hours: 1)),
        );

        tokenManager.setTokenRefreshCallback(() async {
          return null; // 刷新失败
        });

        final requestOptions = RequestOptions(path: '/api/v1/user/info');
        final response = Response(
          requestOptions: requestOptions,
          statusCode: 401,
        );
        final dioException = DioException(
          requestOptions: requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );

        final handler = MockErrorInterceptorHandler();

        // Act
        await authInterceptor.onError(dioException, handler);

        // Assert
        expect(await tokenManager.getAccessToken(), isNull);
        expect(handler.nextCalled, isTrue);
      });

      test('应该限制重试次数', () async {
        // Arrange
        await tokenManager.saveTokens(
          accessToken: 'expired_token',
          refreshToken: 'valid_refresh',
          expiry: DateTime.now().add(const Duration(hours: 1)),
        );

        tokenManager.setTokenRefreshCallback(() async {
          return TokenInfo(
            accessToken: 'new_token',
            refreshToken: 'new_refresh',
            expiry: DateTime.now().add(const Duration(hours: 1)),
          );
        });

        final requestOptions = RequestOptions(
          path: '/api/v1/user/info',
          extra: {'retry_count': 1}, // 已经重试过一次
        );
        final response = Response(
          requestOptions: requestOptions,
          statusCode: 401,
        );
        final dioException = DioException(
          requestOptions: requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );

        final handler = MockErrorInterceptorHandler();

        // Act
        await authInterceptor.onError(dioException, handler);

        // Assert
        expect(handler.nextCalled, isTrue); // 应该直接传递错误，不再重试
      });
    });

    group('非401错误处理', () {
      test('非401错误应该直接传递', () async {
        // Arrange
        final requestOptions = RequestOptions(path: '/api/v1/user/info');
        final response = Response(
          requestOptions: requestOptions,
          statusCode: 500,
        );
        final dioException = DioException(
          requestOptions: requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );

        final handler = MockErrorInterceptorHandler();

        // Act
        await authInterceptor.onError(dioException, handler);

        // Assert
        expect(handler.nextCalled, isTrue);
        expect(handler.resolveCalled, isFalse);
      });

      test('网络错误应该直接传递', () async {
        // Arrange
        final requestOptions = RequestOptions(path: '/api/v1/user/info');
        final dioException = DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.connectionTimeout,
        );

        final handler = MockErrorInterceptorHandler();

        // Act
        await authInterceptor.onError(dioException, handler);

        // Assert
        expect(handler.nextCalled, isTrue);
        expect(handler.resolveCalled, isFalse);
      });
    });

    group('公开端点管理', () {
      test('应该能添加和移除公开端点', () async {
        // Arrange
        const customEndpoint = '/api/v1/custom/public';
        await tokenManager.saveTokens(
          accessToken: 'test_token',
          refreshToken: 'test_refresh',
          expiry: DateTime.now().add(const Duration(hours: 1)),
        );

        // Act - 添加自定义公开端点
        authInterceptor.addPublicEndpoint(customEndpoint);

        final requestOptions1 = RequestOptions(path: customEndpoint);
        final handler1 = MockRequestInterceptorHandler();
        await authInterceptor.onRequest(requestOptions1, handler1);

        // Assert - 应该不添加token
        expect(requestOptions1.headers.containsKey('Authorization'), isFalse);

        // Act - 移除公开端点
        authInterceptor.removePublicEndpoint(customEndpoint);

        final requestOptions2 = RequestOptions(path: customEndpoint);
        final handler2 = MockRequestInterceptorHandler();
        await authInterceptor.onRequest(requestOptions2, handler2);

        // Assert - 应该添加token
        expect(requestOptions2.headers['Authorization'], equals('Bearer test_token'));
      });

      test('应该正确匹配带查询参数的端点', () async {
        // Arrange
        await tokenManager.saveTokens(
          accessToken: 'test_token',
          refreshToken: 'test_refresh',
          expiry: DateTime.now().add(const Duration(hours: 1)),
        );

        final requestOptions = RequestOptions(path: '/api/v1/guest/comm/config?version=1.0');
        final handler = MockRequestInterceptorHandler();

        // Act
        await authInterceptor.onRequest(requestOptions, handler);

        // Assert
        expect(requestOptions.headers.containsKey('Authorization'), isFalse);
      });
    });
  });
}

/// Mock请求拦截器处理器
class MockRequestInterceptorHandler implements RequestInterceptorHandler {
  bool nextCalled = false;
  bool rejectCalled = false;
  DioException? rejectError;

  @override
  void next(RequestOptions requestOptions) {
    nextCalled = true;
  }

  @override
  void reject(DioException error, [bool newError = false]) {
    rejectCalled = true;
    rejectError = error;
  }
}

/// Mock错误拦截器处理器
class MockErrorInterceptorHandler implements ErrorInterceptorHandler {
  bool nextCalled = false;
  bool resolveCalled = false;
  DioException? nextError;
  Response? resolveResponse;

  @override
  void next(DioException err) {
    nextCalled = true;
    nextError = err;
  }

  @override
  void resolve(Response response) {
    resolveCalled = true;
    resolveResponse = response;
  }
}