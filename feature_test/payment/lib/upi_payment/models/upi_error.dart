/// UPI error models
library;

/// UPI error codes
enum UpiErrorCode {
  /// App not installed
  appNotInstalled,

  /// User canceled payment
  userCanceled,

  /// Payment failed
  paymentFailed,

  /// Network error
  networkError,

  /// Invalid VPA
  invalidVpa,

  /// Invalid amount
  invalidAmount,

  /// Timeout
  timeout,

  /// Verification failed
  verificationFailed,

  /// No UPI apps available
  noAppsAvailable,

  /// Unknown error
  unknown,
}

/// UPI error information
class UpiError {
  /// Error code
  final UpiErrorCode code;

  /// Error message
  final String message;

  /// Original error (if any)
  final dynamic originalError;

  /// Stack trace
  final StackTrace? stackTrace;

  /// Whether error is retryable
  final bool isRetryable;

  /// Additional details
  final Map<String, dynamic>? details;

  const UpiError({
    required this.code,
    required this.message,
    this.originalError,
    this.stackTrace,
    this.isRetryable = false,
    this.details,
  });

  /// Create app not installed error
  factory UpiError.appNotInstalled({
    required String appName,
    String? packageName,
  }) {
    return UpiError(
      code: UpiErrorCode.appNotInstalled,
      message: '$appName is not installed on this device',
      isRetryable: false,
      details: {
        'appName': appName,
        'packageName': packageName,
      },
    );
  }

  /// Create user canceled error
  factory UpiError.userCanceled() {
    return const UpiError(
      code: UpiErrorCode.userCanceled,
      message: 'User canceled the payment',
      isRetryable: false,
    );
  }

  /// Create payment failed error
  factory UpiError.paymentFailed({
    required String reason,
  }) {
    return UpiError(
      code: UpiErrorCode.paymentFailed,
      message: 'Payment failed: $reason',
      isRetryable: true,
    );
  }

  /// Create network error
  factory UpiError.network({
    String message = 'Network connection failed',
  }) {
    return UpiError(
      code: UpiErrorCode.networkError,
      message: message,
      isRetryable: true,
    );
  }

  /// Create invalid VPA error
  factory UpiError.invalidVpa({
    required String vpa,
  }) {
    return UpiError(
      code: UpiErrorCode.invalidVpa,
      message: 'Invalid VPA: $vpa',
      isRetryable: false,
      details: {'vpa': vpa},
    );
  }

  /// Create invalid amount error
  factory UpiError.invalidAmount({
    required double amount,
    String? reason,
  }) {
    return UpiError(
      code: UpiErrorCode.invalidAmount,
      message: 'Invalid amount: ₹$amount${reason != null ? ' - $reason' : ''}',
      isRetryable: false,
      details: {'amount': amount},
    );
  }

  /// Create timeout error
  factory UpiError.timeout() {
    return const UpiError(
      code: UpiErrorCode.timeout,
      message: 'Payment request timed out',
      isRetryable: true,
    );
  }

  /// Create verification failed error
  factory UpiError.verificationFailed({
    required String reason,
  }) {
    return UpiError(
      code: UpiErrorCode.verificationFailed,
      message: 'Server verification failed: $reason',
      isRetryable: true,
    );
  }

  /// Create no apps available error
  factory UpiError.noAppsAvailable() {
    return const UpiError(
      code: UpiErrorCode.noAppsAvailable,
      message: 'No UPI apps are installed on this device',
      isRetryable: false,
    );
  }

  /// Create unknown error
  factory UpiError.unknown({
    String message = 'An unknown error occurred',
    dynamic originalError,
    StackTrace? stackTrace,
  }) {
    return UpiError(
      code: UpiErrorCode.unknown,
      message: message,
      originalError: originalError,
      stackTrace: stackTrace,
      isRetryable: false,
    );
  }

  @override
  String toString() {
    return 'UpiError($code): $message';
  }
}
