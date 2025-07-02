/// 支付状态枚举
/// 
/// 定义支付过程中的各种状态
enum PaymentStatus {
  /// 初始状态
  initial,
  
  /// 处理中
  processing,
  
  /// 支付成功
  success,
  
  /// 支付失败
  failed,
  
  /// 已取消
  canceled,
  
  /// 等待确认
  pending,
  
  /// 超时
  timeout;

  /// 获取状态描述
  String get description {
    switch (this) {
      case PaymentStatus.initial:
        return '初始状态';
      case PaymentStatus.processing:
        return '处理中';
      case PaymentStatus.success:
        return '支付成功';
      case PaymentStatus.failed:
        return '支付失败';
      case PaymentStatus.canceled:
        return '已取消';
      case PaymentStatus.pending:
        return '等待确认';
      case PaymentStatus.timeout:
        return '支付超时';
    }
  }

  /// 是否为最终状态
  bool get isFinal {
    return this == PaymentStatus.success || 
           this == PaymentStatus.failed || 
           this == PaymentStatus.canceled ||
           this == PaymentStatus.timeout;
  }

  /// 是否为成功状态
  bool get isSuccess => this == PaymentStatus.success;

  /// 是否为失败状态
  bool get isFailed => this == PaymentStatus.failed || this == PaymentStatus.timeout;
}

/// 支付状态结果
/// 
/// 用于表示支付状态检查的结果
class PaymentStatusResult {
  final bool isSuccess;
  final bool isCanceled;
  final bool isPending;
  final String? message;

  const PaymentStatusResult({
    required this.isSuccess,
    required this.isCanceled,
    required this.isPending,
    this.message,
  });

  /// 创建成功结果
  factory PaymentStatusResult.success([String? message]) => 
      PaymentStatusResult(
        isSuccess: true, 
        isCanceled: false, 
        isPending: false,
        message: message,
      );

  /// 创建取消结果
  factory PaymentStatusResult.canceled([String? message]) => 
      PaymentStatusResult(
        isSuccess: false, 
        isCanceled: true, 
        isPending: false,
        message: message,
      );

  /// 创建等待结果
  factory PaymentStatusResult.pending([String? message]) => 
      PaymentStatusResult(
        isSuccess: false, 
        isCanceled: false, 
        isPending: true,
        message: message,
      );

  /// 创建失败结果
  factory PaymentStatusResult.failed([String? message]) => 
      PaymentStatusResult(
        isSuccess: false, 
        isCanceled: false, 
        isPending: false,
        message: message,
      );

  /// 从JSON创建
  factory PaymentStatusResult.fromJson(Map<String, dynamic> json) {
    return PaymentStatusResult(
      isSuccess: json['is_success'] == true,
      isCanceled: json['is_canceled'] == true,
      isPending: json['is_pending'] == true,
      message: json['message'] as String?,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'is_success': isSuccess,
      'is_canceled': isCanceled,
      'is_pending': isPending,
      if (message != null) 'message': message,
    };
  }
}

/// 增强的支付方式模型
/// 
/// 表示一种可用的支付方式
class PaymentMethodInfo {
  final String id;
  final String name;
  final double feePercent;
  final String? icon;
  final bool isAvailable;
  final Map<String, dynamic>? config;
  final String? description;
  final double? minAmount;
  final double? maxAmount;

  const PaymentMethodInfo({
    required this.id,
    required this.name,
    required this.feePercent,
    this.icon,
    this.isAvailable = true,
    this.config,
    this.description,
    this.minAmount,
    this.maxAmount,
  });

  /// 从JSON创建
  factory PaymentMethodInfo.fromJson(Map<String, dynamic> json) {
    return PaymentMethodInfo(
      id: json['id']?.toString() ?? '',
      name: _parseString(json['name']),
      feePercent: _parseDouble(json['handling_fee_percent'] ?? json['fee_percent']),
      icon: json['icon'] as String?,
      isAvailable: json['is_available'] != false,
      config: json['config'] as Map<String, dynamic>?,
      description: json['description'] as String?,
      minAmount: _parseDouble(json['min_amount']),
      maxAmount: _parseDouble(json['max_amount']),
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'handling_fee_percent': feePercent,
      if (icon != null) 'icon': icon,
      'is_available': isAvailable,
      if (config != null) 'config': config,
      if (description != null) 'description': description,
      if (minAmount != null) 'min_amount': minAmount,
      if (maxAmount != null) 'max_amount': maxAmount,
    };
  }

  /// 计算手续费
  double calculateFee(double amount) {
    return amount * (feePercent / 100);
  }

  /// 计算总金额（包含手续费）
  double calculateTotalAmount(double amount) {
    return amount + calculateFee(amount);
  }

  /// 检查金额是否在允许范围内
  bool isAmountValid(double amount) {
    if (minAmount != null && amount < minAmount!) return false;
    if (maxAmount != null && amount > maxAmount!) return false;
    return true;
  }

  /// 安全地解析字符串
  static String _parseString(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  /// 安全地解析double
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }
}

/// 订单信息
/// 
/// 包含订单的详细信息
class PaymentOrderInfo {
  final String tradeNo;
  final double originalAmount;
  final double finalAmount;
  final String? couponCode;
  final double? discountAmount;
  final String? currency;
  final DateTime? expireTime;

  const PaymentOrderInfo({
    required this.tradeNo,
    required this.originalAmount,
    this.finalAmount = 0.0,
    this.couponCode,
    this.discountAmount,
    this.currency = 'CNY',
    this.expireTime,
  });

  /// 从JSON创建
  factory PaymentOrderInfo.fromJson(Map<String, dynamic> json) {
    return PaymentOrderInfo(
      tradeNo: json['trade_no']?.toString() ?? '',
      originalAmount: PaymentMethodInfo._parseDouble(json['original_amount']),
      finalAmount: PaymentMethodInfo._parseDouble(json['final_amount'] ?? json['total_amount']),
      couponCode: json['coupon_code'] as String?,
      discountAmount: PaymentMethodInfo._parseDouble(json['discount_amount']),
      currency: json['currency'] as String? ?? 'CNY',
      expireTime: json['expire_time'] != null 
          ? DateTime.fromMillisecondsSinceEpoch((json['expire_time'] as int) * 1000)
          : null,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'trade_no': tradeNo,
      'original_amount': originalAmount,
      'final_amount': finalAmount,
      if (couponCode != null) 'coupon_code': couponCode,
      if (discountAmount != null) 'discount_amount': discountAmount,
      'currency': currency,
      if (expireTime != null) 'expire_time': expireTime!.millisecondsSinceEpoch ~/ 1000,
    };
  }

  /// 复制并修改
  PaymentOrderInfo copyWith({
    String? tradeNo,
    double? originalAmount,
    double? finalAmount,
    String? couponCode,
    double? discountAmount,
    String? currency,
    DateTime? expireTime,
  }) {
    return PaymentOrderInfo(
      tradeNo: tradeNo ?? this.tradeNo,
      originalAmount: originalAmount ?? this.originalAmount,
      finalAmount: finalAmount ?? this.finalAmount,
      couponCode: couponCode ?? this.couponCode,
      discountAmount: discountAmount ?? this.discountAmount,
      currency: currency ?? this.currency,
      expireTime: expireTime ?? this.expireTime,
    );
  }

  /// 获取实际折扣金额
  double get actualDiscountAmount {
    return discountAmount ?? (originalAmount - finalAmount);
  }

  /// 是否有折扣
  bool get hasDiscount => actualDiscountAmount > 0;

  /// 折扣百分比
  double get discountPercent {
    if (originalAmount <= 0) return 0;
    return (actualDiscountAmount / originalAmount) * 100;
  }

  /// 是否已过期
  bool get isExpired {
    if (expireTime == null) return false;
    return DateTime.now().isAfter(expireTime!);
  }
}

/// 支付结果
/// 
/// 使用sealed class处理不同的支付结果类型
sealed class PaymentResult {
  const PaymentResult();
  
  /// 支付成功
  const factory PaymentResult.success({
    String? transactionId,
    String? message,
    Map<String, dynamic>? extra,
  }) = PaymentResultSuccess;
  
  /// 需要重定向到支付页面
  const factory PaymentResult.redirect({
    required String url,
    String? method,
    Map<String, String>? headers,
  }) = PaymentResultRedirect;
  
  /// 支付失败
  const factory PaymentResult.failed({
    required String message,
    String? errorCode,
    Map<String, dynamic>? extra,
  }) = PaymentResultFailed;
  
  /// 支付取消
  const factory PaymentResult.canceled({
    String? message,
  }) = PaymentResultCanceled;
}

/// 支付成功结果
class PaymentResultSuccess extends PaymentResult {
  final String? transactionId;
  final String? message;
  final Map<String, dynamic>? extra;
  
  const PaymentResultSuccess({
    this.transactionId,
    this.message,
    this.extra,
  });
}

/// 支付重定向结果
class PaymentResultRedirect extends PaymentResult {
  final String url;
  final String? method;
  final Map<String, String>? headers;
  
  const PaymentResultRedirect({
    required this.url,
    this.method = 'GET',
    this.headers,
  });
}

/// 支付失败结果
class PaymentResultFailed extends PaymentResult {
  final String message;
  final String? errorCode;
  final Map<String, dynamic>? extra;
  
  const PaymentResultFailed({
    required this.message,
    this.errorCode,
    this.extra,
  });
}

/// 支付取消结果
class PaymentResultCanceled extends PaymentResult {
  final String? message;
  
  const PaymentResultCanceled({
    this.message,
  });
}

/// 支付错误
/// 
/// 定义支付过程中可能出现的各种错误
sealed class PaymentError implements Exception {
  final String message;
  final String? errorCode;
  
  const PaymentError(this.message, [this.errorCode]);

  /// 无Token错误
  factory PaymentError.noToken() = NoTokenError;
  
  /// 网络错误
  factory PaymentError.networkError([String? message]) = NetworkError;
  
  /// 无效响应错误
  factory PaymentError.invalidResponse([String? message]) = InvalidResponseError;
  
  /// 预检查失败错误
  factory PaymentError.preCheckFailed([String? message]) = PreCheckError;
  
  /// URL启动错误
  factory PaymentError.cannotLaunchUrl([String? url]) = UrlLaunchError;
  
  /// 支付超时错误
  factory PaymentError.timeout([String? message]) = PaymentTimeoutError;
  
  /// 金额无效错误
  factory PaymentError.invalidAmount([String? message]) = InvalidAmountError;
  
  /// 支付方式不可用错误
  factory PaymentError.paymentMethodUnavailable([String? message]) = PaymentMethodUnavailableError;
  
  /// 从异常创建错误
  factory PaymentError.fromException(dynamic e) {
    if (e is PaymentError) return e;
    return UnknownError(e.toString());
  }

  @override
  String toString() {
    if (errorCode != null) {
      return 'PaymentError($errorCode): $message';
    }
    return 'PaymentError: $message';
  }
}

/// 无Token错误
class NoTokenError extends PaymentError {
  const NoTokenError() : super('No access token available', 'NO_TOKEN');
}

/// 网络错误
class NetworkError extends PaymentError {
  const NetworkError([String? message]) 
      : super(message ?? 'Network request failed', 'NETWORK_ERROR');
}

/// 无效响应错误
class InvalidResponseError extends PaymentError {
  const InvalidResponseError([String? message]) 
      : super(message ?? 'Invalid server response', 'INVALID_RESPONSE');
}

/// 预检查失败错误
class PreCheckError extends PaymentError {
  const PreCheckError([String? message]) 
      : super(message ?? 'Payment pre-check failed', 'PRE_CHECK_FAILED');
}

/// URL启动错误
class UrlLaunchError extends PaymentError {
  const UrlLaunchError([String? url]) 
      : super('Cannot launch payment URL${url != null ? ': $url' : ''}', 'URL_LAUNCH_ERROR');
}

/// 支付超时错误
class PaymentTimeoutError extends PaymentError {
  const PaymentTimeoutError([String? message]) 
      : super(message ?? 'Payment timeout', 'TIMEOUT');
}

/// 金额无效错误
class InvalidAmountError extends PaymentError {
  const InvalidAmountError([String? message]) 
      : super(message ?? 'Invalid payment amount', 'INVALID_AMOUNT');
}

/// 支付方式不可用错误
class PaymentMethodUnavailableError extends PaymentError {
  const PaymentMethodUnavailableError([String? message]) 
      : super(message ?? 'Payment method is not available', 'METHOD_UNAVAILABLE');
}

/// 未知错误
class UnknownError extends PaymentError {
  const UnknownError(String message) : super(message, 'UNKNOWN_ERROR');
}

/// 支付状态
/// 
/// 管理支付流程的状态
class PaymentState {
  final PaymentOrderInfo? orderInfo;
  final PaymentStatus status;
  final String? error;
  final List<PaymentMethodInfo> paymentMethods;
  final bool isLoading;
  final PaymentResult? result;

  const PaymentState({
    this.orderInfo,
    this.status = PaymentStatus.initial,
    this.error,
    this.paymentMethods = const [],
    this.isLoading = false,
    this.result,
  });

  /// 复制并修改
  PaymentState copyWith({
    PaymentOrderInfo? orderInfo,
    PaymentStatus? status,
    String? error,
    List<PaymentMethodInfo>? paymentMethods,
    bool? isLoading,
    PaymentResult? result,
  }) {
    return PaymentState(
      orderInfo: orderInfo ?? this.orderInfo,
      status: status ?? this.status,
      error: error,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
    );
  }

  /// 是否可以支付
  bool get canPay {
    return orderInfo != null && 
           !isLoading && 
           status != PaymentStatus.processing &&
           paymentMethods.isNotEmpty;
  }

  /// 是否支付完成
  bool get isCompleted {
    return status.isFinal;
  }

  /// 是否支付成功
  bool get isSuccess {
    return status.isSuccess;
  }
}

/// 支付请求
/// 
/// 提交支付时使用的请求数据
class PaymentRequest {
  final String tradeNo;
  final String method;
  final String? callbackUrl;
  final Map<String, dynamic>? extra;

  const PaymentRequest({
    required this.tradeNo,
    required this.method,
    this.callbackUrl,
    this.extra,
  });

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'trade_no': tradeNo,
      'method': method,
      if (callbackUrl != null) 'callback_url': callbackUrl,
      if (extra != null) ...extra!,
    };
  }
}

/// 支付响应
/// 
/// 支付API返回的响应数据
class PaymentResponse {
  final bool success;
  final String? message;
  final PaymentResult? result;
  final Map<String, dynamic>? data;

  const PaymentResponse({
    required this.success,
    this.message,
    this.result,
    this.data,
  });

  /// 从JSON创建
  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    PaymentResult? result;
    
    // 解析支付结果
    final data = json['data'] as Map<String, dynamic>?;
    if (data != null) {
      if (data.containsKey('redirect_url') || data.containsKey('url')) {
        final url = data['redirect_url'] ?? data['url'];
        if (url != null) {
          result = PaymentResult.redirect(
            url: url.toString(),
            method: data['method'] as String?,
            headers: data['headers'] as Map<String, String>?,
          );
        }
      } else if (json['success'] == true || data['status'] == 'success') {
        result = PaymentResult.success(
          transactionId: data['transaction_id'] as String?,
          message: data['message'] as String?,
          extra: data,
        );
      } else if (json['success'] == false) {
        result = PaymentResult.failed(
          message: json['message']?.toString() ?? 'Payment failed',
          errorCode: data['error_code'] as String?,
          extra: data,
        );
      }
    }

    return PaymentResponse(
      success: json['success'] == true,
      message: json['message'] as String?,
      result: result,
      data: data,
    );
  }

  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (message != null) 'message': message,
      if (data != null) 'data': data,
    };
  }
} 