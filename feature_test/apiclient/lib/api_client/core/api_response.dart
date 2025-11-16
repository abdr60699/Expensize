/// API response wrapper for standardized responses
library;

/// Generic API response wrapper
class ApiResponse<T> {
  /// Response data
  final T? data;

  /// Whether the request was successful
  final bool success;

  /// HTTP status code
  final int? statusCode;

  /// Success message
  final String? message;

  /// Error information (if any)
  final ApiError? error;

  /// Response metadata
  final Map<String, dynamic>? metadata;

  /// Response timestamp
  final DateTime timestamp;

  const ApiResponse({
    this.data,
    required this.success,
    this.statusCode,
    this.message,
    this.error,
    this.metadata,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? const _DateTimeNow();

  /// Create successful response
  factory ApiResponse.success({
    T? data,
    int? statusCode,
    String? message,
    Map<String, dynamic>? metadata,
  }) {
    return ApiResponse<T>(
      data: data,
      success: true,
      statusCode: statusCode ?? 200,
      message: message,
      metadata: metadata,
    );
  }

  /// Create error response
  factory ApiResponse.error({
    required ApiError error,
    int? statusCode,
    Map<String, dynamic>? metadata,
  }) {
    return ApiResponse<T>(
      success: false,
      statusCode: statusCode,
      error: error,
      metadata: metadata,
    );
  }

  /// Whether response has data
  bool get hasData => data != null;

  /// Whether response has error
  bool get hasError => error != null;

  @override
  String toString() {
    return 'ApiResponse(success: $success, statusCode: $statusCode, hasData: $hasData, hasError: $hasError)';
  }
}

/// API error model
class ApiError {
  /// Error code
  final String code;

  /// Error message
  final String message;

  /// Detailed error description
  final String? details;

  /// Field-specific errors (for validation)
  final Map<String, List<String>>? fieldErrors;

  /// Original exception
  final dynamic originalError;

  /// Stack trace
  final StackTrace? stackTrace;

  /// Whether error is retryable
  final bool isRetryable;

  /// HTTP status code
  final int? statusCode;

  const ApiError({
    required this.code,
    required this.message,
    this.details,
    this.fieldErrors,
    this.originalError,
    this.stackTrace,
    this.isRetryable = false,
    this.statusCode,
  });

  /// Create network error
  factory ApiError.network({
    String message = 'Network connection failed',
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return ApiError(
      code: 'NETWORK_ERROR',
      message: message,
      originalError: originalError,
      stackTrace: stackTrace,
      isRetryable: true,
    );
  }

  /// Create timeout error
  factory ApiError.timeout({
    String message = 'Request timed out',
  }) {
    return ApiError(
      code: 'TIMEOUT',
      message: message,
      isRetryable: true,
    );
  }

  /// Create unauthorized error
  factory ApiError.unauthorized({
    String message = 'Unauthorized access',
  }) {
    return ApiError(
      code: 'UNAUTHORIZED',
      message: message,
      statusCode: 401,
      isRetryable: false,
    );
  }

  /// Create validation error
  factory ApiError.validation({
    required String message,
    Map<String, List<String>>? fieldErrors,
  }) {
    return ApiError(
      code: 'VALIDATION_ERROR',
      message: message,
      fieldErrors: fieldErrors,
      statusCode: 422,
      isRetryable: false,
    );
  }

  /// Create server error
  factory ApiError.server({
    String message = 'Internal server error',
    int? statusCode,
  }) {
    return ApiError(
      code: 'SERVER_ERROR',
      message: message,
      statusCode: statusCode ?? 500,
      isRetryable: true,
    );
  }

  /// Create not found error
  factory ApiError.notFound({
    String message = 'Resource not found',
  }) {
    return ApiError(
      code: 'NOT_FOUND',
      message: message,
      statusCode: 404,
      isRetryable: false,
    );
  }

  /// Create unknown error
  factory ApiError.unknown({
    String message = 'An unknown error occurred',
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return ApiError(
      code: 'UNKNOWN_ERROR',
      message: message,
      originalError: originalError,
      stackTrace: stackTrace,
      isRetryable: false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'details': details,
      'fieldErrors': fieldErrors,
      'isRetryable': isRetryable,
      'statusCode': statusCode,
    };
  }

  @override
  String toString() {
    return 'ApiError($code): $message${details != null ? ' - $details' : ''}';
  }
}

/// Helper class for default DateTime.now()
class _DateTimeNow extends DateTime {
  const _DateTimeNow() : super(0);

  @override
  String toString() => DateTime.now().toString();

  @override
  String toIso8601String() => DateTime.now().toIso8601String();
}
