import 'dart:convert';
import 'dart:io';
import '../exceptions/xboard_exceptions.dart';

class HttpService {
  final String baseUrl;
  String? _authToken;
  final HttpClient _httpClient = HttpClient();

  HttpService(this.baseUrl);

  /// 设置认证token
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// 清除认证token
  void clearAuthToken() {
    _authToken = null;
  }

  /// 获取当前认证token
  String? getAuthToken() {
    return _authToken;
  }

  /// 发送GET请求
  Future<Map<String, dynamic>> getRequest(String path, {Map<String, String>? headers}) async {
    return _sendRequest('GET', path, headers: headers);
  }

  /// 发送POST请求
  Future<Map<String, dynamic>> postRequest(String path, Map<String, dynamic> data, {Map<String, String>? headers}) async {
    return _sendRequest('POST', path, data: data, headers: headers);
  }

  /// 发送PUT请求
  Future<Map<String, dynamic>> putRequest(String path, Map<String, dynamic> data, {Map<String, String>? headers}) async {
    return _sendRequest('PUT', path, data: data, headers: headers);
  }

  /// 发送DELETE请求
  Future<Map<String, dynamic>> deleteRequest(String path, {Map<String, String>? headers}) async {
    return _sendRequest('DELETE', path, headers: headers);
  }

  /// 通用HTTP请求方法
  Future<Map<String, dynamic>> _sendRequest(
    String method,
    String path, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      print('[HttpService] $method $uri');
      if (data != null) {
        print('[HttpService] 请求数据: $data');
      }
      
      final request = await _httpClient.openUrl(method, uri);

      // 设置请求头
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');

      // 添加自定义头
      if (headers != null) {
        headers.forEach((key, value) {
          request.headers.set(key, value);
        });
      }

      // 添加认证头
      if (_authToken != null) {
        request.headers.set('Authorization', _authToken!);
      }

      // 写入请求体
      if (data != null) {
        final jsonData = jsonEncode(data);
        request.add(utf8.encode(jsonData));
      }

      // 发送请求并获取响应
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      print('[HttpService] 响应状态: ${response.statusCode}');
      print('[HttpService] 响应内容: $responseBody');

      return _handleResponse(response.statusCode, responseBody);
    } on SocketException catch (e) {
      throw NetworkException('网络连接失败: ${e.message}');
    } catch (e) {
      throw NetworkException('请求失败: $e');
    }
  }

  /// 处理HTTP响应
  Map<String, dynamic> _handleResponse(int statusCode, String responseBody) {
    try {
      final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);

      if (statusCode >= 200 && statusCode < 300) {
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
      } else {
        // HTTP错误状态码
        String errorMessage = '请求失败 (状态码: $statusCode)';
        
        if (jsonResponse.containsKey('message')) {
          errorMessage = jsonResponse['message'];
        } else if (jsonResponse.containsKey('error')) {
          errorMessage = jsonResponse['error'];
        }

        if (statusCode == 401) {
          throw AuthException(errorMessage);
        } else if (statusCode >= 400 && statusCode < 500) {
          throw ApiException(errorMessage, statusCode);
        } else {
          throw NetworkException(errorMessage);
        }
      }
    } catch (e) {
      if (e is XBoardException) {
        rethrow;
      }
      throw ApiException('响应解析失败: $e');
    }
  }
} 