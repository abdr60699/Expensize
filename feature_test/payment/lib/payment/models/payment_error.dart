/// Payment error models
library;

/// Payment error codes
enum PaymentErrorCode {
  /// Unknown error
  unknown,

  /// Network error
  networkError,

  /// Invalid request
  invalidRequest,

  /// Invalid API key or credentials
  authenticationError,

  /// Payment declined by provider
  cardDeclined,

  /// Insufficient funds
  insufficientFunds,

  /// Expired card
  expiredCard,

  /// Invalid card number
  invalidCard,

  /// Processing error
  processingError,

  /// Rate limit exceeded
  rateLimitExceeded,

  /// Provider unavailable
  providerUnavailable,

  /// Validation error
  validationError,

  /// Transaction not found
  transactionNotFound,

  /// Subscription not found
  subscriptionNotFound,

  /// Refund failed
  refundFailed,

  /// Operation canceled by user
  userCanceled,

  /// Payment timeout
  timeout,

  /// Currency not supported
  currencyNotSupported,

  /// Amount too small
  amountTooSmall,

  /// Amount too large
  amountTooLarge,

  /// 3D Secure authentication failed
  authenticationFailed,

  /// Duplicate transaction
  duplicateTransaction,
}

/// Detailed payment error information
class PaymentError {
  /// Error code
  final PaymentErrorCode code;

  /// Human-readable error message
  final String message;

  /// Provider-specific error code (e.g., Stripe error code)
  final String? providerErrorCode;

  /// Provider-specific error message
  final String? providerErrorMessage;

  /// Whether this error is retryable
  final bool isRetryable;

  /// Additional error details
  final Map<String, dynamic>? details;

  /// Timestamp when error occurred
  final DateTime timestamp;

  PaymentError({
    required this.code,
    required this.message,
    this.providerErrorCode,
    this.providerErrorMessage,
    this.isRetryable = false,
    this.details,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Create network error
  factory PaymentError.network({
    String message = 'Network connection failed',
    Map<String, dynamic>? details,
  }) {
    return PaymentError(
      code: PaymentErrorCode.networkError,
      message: message,
      isRetryable: true,
      details: details,
    );
  }

  /// Create card declined error
  factory PaymentError.cardDeclined({
    String message = 'Card was declined',
    String? providerErrorCode,
    String? providerErrorMessage,
  }) {
    return PaymentError(
      code: PaymentErrorCode.cardDeclined,
      message: message,
      providerErrorCode: providerErrorCode,
      providerErrorMessage: providerErrorMessage,
      isRetryable: false,
    );
  }

  /// Create validation error
  factory PaymentError.validation({
    required String message,
    Map<String, dynamic>? details,
  }) {
    return PaymentError(
      code: PaymentErrorCode.validationError,
      message: message,
      isRetryable: false,
      details: details,
    );
  }

  /// Create provider unavailable error
  factory PaymentError.providerUnavailable({
    String message = 'Payment provider is currently unavailable',
    String? providerId,
  }) {
    return PaymentError(
      code: PaymentErrorCode.providerUnavailable,
      message: message,
      isRetryable: true,
      details: {'providerId': providerId},
    );
  }

  /// Create user canceled error
  factory PaymentError.userCanceled() {
    return const PaymentError(
      code: PaymentErrorCode.userCanceled,
      message: 'Payment was canceled by user',
      isRetryable: false,
    );
  }

  /// Create timeout error
  factory PaymentError.timeout({
    String message = 'Payment request timed out',
  }) {
    return PaymentError(
      code: PaymentErrorCode.timeout,
      message: message,
      isRetryable: true,
    );
  }

  /// Create unknown error
  factory PaymentError.unknown({
    String message = 'An unknown error occurred',
    String? providerErrorCode,
    String? providerErrorMessage,
  }) {
    return PaymentError(
      code: PaymentErrorCode.unknown,
      message: message,
      providerErrorCode: providerErrorCode,
      providerErrorMessage: providerErrorMessage,
      isRetryable: false,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code.name,
      'message': message,
      'providerErrorCode': providerErrorCode,
      'providerErrorMessage': providerErrorMessage,
      'isRetryable': isRetryable,
      'details': details,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create from JSON
  factory PaymentError.fromJson(Map<String, dynamic> json) {
    return PaymentError(
      code: PaymentErrorCode.values.firstWhere(
        (e) => e.name == json['code'],
        orElse: () => PaymentErrorCode.unknown,
      ),
      message: json['message'] as String,
      providerErrorCode: json['providerErrorCode'] as String?,
      providerErrorMessage: json['providerErrorMessage'] as String?,
      isRetryable: json['isRetryable'] as bool? ?? false,
      details: json['details'] as Map<String, dynamic>?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

  @override
  String toString() {
    final buffer = StringBuffer('PaymentError($code: $message');
    if (providerErrorCode != null) {
      buffer.write(', providerError: $providerErrorCode');
    }
    buffer.write(')');
    return buffer.toString();
  }
}

