/// UPI Payment Exceptions
///
/// All custom exceptions for UPI payment operations

/// Base UPI exception class
class UpiException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  UpiException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() {
    if (code != null) {
      return 'UpiException($code): $message';
    }
    return 'UpiException: $message';
  }
}

/// Exception thrown when no UPI apps are installed
class NoUpiAppsException extends UpiException {
  NoUpiAppsException()
      : super(
          message: 'No UPI apps are installed on this device',
          code: 'NO_UPI_APPS',
        );
}

/// Exception thrown when UPI app is not found
class UpiAppNotFoundException extends UpiException {
  final String appPackageName;

  UpiAppNotFoundException({
    required this.appPackageName,
  }) : super(
          message: 'UPI app not found: $appPackageName',
          code: 'UPI_APP_NOT_FOUND',
        );
}

/// Exception thrown when payment is cancelled by user
class UpiPaymentCancelledException extends UpiException {
  UpiPaymentCancelledException()
      : super(
          message: 'Payment was cancelled by user',
          code: 'PAYMENT_CANCELLED',
        );
}

/// Exception thrown when payment fails
class UpiPaymentFailedException extends UpiException {
  final String? failureReason;

  UpiPaymentFailedException({
    this.failureReason,
  }) : super(
          message: failureReason ?? 'Payment failed',
          code: 'PAYMENT_FAILED',
        );
}

/// Exception thrown when invalid UPI ID is provided
class InvalidUpiIdException extends UpiException {
  final String upiId;

  InvalidUpiIdException({
    required this.upiId,
  }) : super(
          message: 'Invalid UPI ID: $upiId',
          code: 'INVALID_UPI_ID',
        );
}

/// Exception thrown when invalid amount is provided
class InvalidAmountException extends UpiException {
  final double amount;

  InvalidAmountException({
    required this.amount,
  }) : super(
          message: 'Invalid amount: $amount',
          code: 'INVALID_AMOUNT',
        );
}

/// Exception thrown when transaction validation fails
class UpiTransactionValidationException extends UpiException {
  final String? validationError;

  UpiTransactionValidationException({
    this.validationError,
  }) : super(
          message: validationError ?? 'Transaction validation failed',
          code: 'VALIDATION_FAILED',
        );
}

/// Exception thrown when platform is not supported
class UpiPlatformNotSupportedException extends UpiException {
  final String platform;

  UpiPlatformNotSupportedException({
    required this.platform,
  }) : super(
          message: 'UPI is not supported on platform: $platform',
          code: 'PLATFORM_NOT_SUPPORTED',
        );
}

/// Exception thrown when UPI transaction times out
class UpiTransactionTimeoutException extends UpiException {
  UpiTransactionTimeoutException()
      : super(
          message: 'UPI transaction timed out',
          code: 'TRANSACTION_TIMEOUT',
        );
}

/// Exception thrown when UPI app returns invalid response
class InvalidUpiResponseException extends UpiException {
  final String? response;

  InvalidUpiResponseException({
    this.response,
  }) : super(
          message: 'Invalid UPI response: ${response ?? "null"}',
          code: 'INVALID_RESPONSE',
        );
}

/// Exception thrown when server verification fails
class UpiServerVerificationException extends UpiException {
  final int? statusCode;

  UpiServerVerificationException({
    this.statusCode,
    String? message,
  }) : super(
          message: message ?? 'Server verification failed',
          code: 'SERVER_VERIFICATION_FAILED',
        );
}

/// Exception thrown when UPI service is not initialized
class UpiNotInitializedException extends UpiException {
  UpiNotInitializedException()
      : super(
          message: 'UPI service is not initialized. Call initialize() first.',
          code: 'NOT_INITIALIZED',
        );
}

/// Exception thrown when duplicate transaction is detected
class DuplicateTransactionException extends UpiException {
  final String transactionId;

  DuplicateTransactionException({
    required this.transactionId,
  }) : super(
          message: 'Duplicate transaction: $transactionId',
          code: 'DUPLICATE_TRANSACTION',
        );
}

/// Exception thrown when network error occurs
class UpiNetworkException extends UpiException {
  UpiNetworkException({
    String? message,
    dynamic originalError,
  }) : super(
          message: message ?? 'Network error occurred',
          code: 'NETWORK_ERROR',
          originalError: originalError,
        );
}

/// Exception thrown when permission is denied
class UpiPermissionDeniedException extends UpiException {
  final String permission;

  UpiPermissionDeniedException({
    required this.permission,
  }) : super(
          message: 'Permission denied: $permission',
          code: 'PERMISSION_DENIED',
        );
}
