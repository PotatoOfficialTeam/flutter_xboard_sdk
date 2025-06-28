import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpService {
  late String _baseUrl;
  String? _authToken;

  HttpService(String baseUrl) {
    setBaseUrl(baseUrl);
  }

  /// 设置基础URL
  void setBaseUrl(String baseUrl) {
    // 确保URL以斜杠结尾
    _baseUrl = baseUrl.endsWith('/') ? baseUrl : '$baseUrl/';
  }

  /// 获取基础URL
  String get baseUrl => _baseUrl;

  /// 设置认证Token
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// 清除认证Token
  void clearAuthToken() {
    _authToken = null;
  }

  /// 构建完整URL
  String _buildUrl(String endpoint) {
    // 移除endpoint开头的斜杠避免重复
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    return '$_baseUrl$cleanEndpoint';
  }

  /// 构建请求头
  Map<String, String> _buildHeaders({Map<String, String>? additionalHeaders}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  /// GET请求
  Future<Map<String, dynamic>> getRequest(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse(_buildUrl(endpoint));
      final requestHeaders = _buildHeaders(additionalHeaders: headers);
      
      final response = await http.get(url, headers: requestHeaders);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('GET请求失败: $e');
    }
  }

  /// POST请求
  Future<Map<String, dynamic>> postRequest(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse(_buildUrl(endpoint));
      final requestHeaders = _buildHeaders(additionalHeaders: headers);
      
      final response = await http.post(
        url,
        headers: requestHeaders,
        body: jsonEncode(data),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('POST请求失败: $e');
    }
  }

  /// PUT请求
  Future<Map<String, dynamic>> putRequest(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse(_buildUrl(endpoint));
      final requestHeaders = _buildHeaders(additionalHeaders: headers);
      
      final response = await http.put(
        url,
        headers: requestHeaders,
        body: jsonEncode(data),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('PUT请求失败: $e');
    }
  }

  /// DELETE请求
  Future<Map<String, dynamic>> deleteRequest(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse(_buildUrl(endpoint));
      final requestHeaders = _buildHeaders(additionalHeaders: headers);
      
      final response = await http.delete(url, headers: requestHeaders);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('DELETE请求失败: $e');
    }
  }

  /// 处理HTTP响应
  Map<String, dynamic> _handleResponse(http.Response response) {
    try {
      final Map<String, dynamic> data = jsonDecode(response.body);
      
      // 将XBoard的status格式转换为标准格式
      if (data.containsKey('status')) {
        final status = data['status'];
        data['success'] = status == 'success';
        
        // 如果没有message但有其他错误信息，尝试提取
        if (!data.containsKey('message') && status != 'success') {
          data['message'] = data['msg'] ?? data['error'] ?? '请求失败';
        }
      }
      
      return data;
    } catch (e) {
      // 如果无法解析JSON，返回错误
      return {
        'success': false,
        'message': '响应解析失败: ${response.body}',
        'status_code': response.statusCode,
      };
    }
  }
} 