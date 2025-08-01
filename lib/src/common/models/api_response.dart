/// API响应基础模型 - 兼容XBoard格式
class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;
  final int? code;
  final dynamic error;

  ApiResponse({
    required this.success,
    this.message,
    this.data,
    this.code,
    this.error,
  });

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    // 兼容两种格式：success字段和status字段
    bool isSuccess = false;
    if (json.containsKey('success')) {
      isSuccess = json['success'] ?? false;
    } else if (json.containsKey('status')) {
      isSuccess = json['status'] == 'success';
    }

    return ApiResponse<T>(
      success: isSuccess,
      message: json['message'],
      code: json['code'],
      error: json['error'],
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
    );
  }
}