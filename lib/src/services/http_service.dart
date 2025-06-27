import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpService {
  String? _baseUrl;
  String? _token;
  
  // 设置基础URL
  void setBaseUrl(String baseUrl) {
    _baseUrl = baseUrl;
  }
  
  // 设置认证token
  void setToken(String token) {
    _token = token;
  }
  
  // 清除token
  void clearToken() {
    _token = null;
  }
  
  // GET请求
  Future<Map<String, dynamic>> getRequest(
    String endpoint, {
    bool includeHeaders = true,
  }) async {
    if (_baseUrl == null) {
      throw Exception('Base URL not set. Please call setBaseUrl() first.');
    }
    
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = _buildHeaders(includeHeaders);
    
    try {
      final response = await http.get(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // POST请求
  Future<Map<String, dynamic>> postRequest(
    String endpoint,
    Map<String, dynamic> data, {
    bool includeHeaders = true,
  }) async {
    if (_baseUrl == null) {
      throw Exception('Base URL not set. Please call setBaseUrl() first.');
    }
    
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = _buildHeaders(includeHeaders);
    final body = json.encode(data);
    
    try {
      final response = await http.post(url, headers: headers, body: body);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // PUT请求
  Future<Map<String, dynamic>> putRequest(
    String endpoint,
    Map<String, dynamic> data, {
    bool includeHeaders = true,
  }) async {
    if (_baseUrl == null) {
      throw Exception('Base URL not set. Please call setBaseUrl() first.');
    }
    
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = _buildHeaders(includeHeaders);
    final body = json.encode(data);
    
    try {
      final response = await http.put(url, headers: headers, body: body);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // DELETE请求
  Future<Map<String, dynamic>> deleteRequest(
    String endpoint, {
    bool includeHeaders = true,
  }) async {
    if (_baseUrl == null) {
      throw Exception('Base URL not set. Please call setBaseUrl() first.');
    }
    
    final url = Uri.parse('$_baseUrl$endpoint');
    final headers = _buildHeaders(includeHeaders);
    
    try {
      final response = await http.delete(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
  
  // 构建请求头
  Map<String, String> _buildHeaders(bool includeAuth) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (includeAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    
    return headers;
  }
  
  // 处理响应
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;
    
    Map<String, dynamic> data;
    try {
      data = json.decode(body);
    } catch (e) {
      throw Exception('Failed to parse response: $e');
    }
    
    if (statusCode >= 200 && statusCode < 300) {
      return data;
    } else {
      final message = data['message'] ?? 'Request failed with status $statusCode';
      throw Exception(message);
    }
  }
} 