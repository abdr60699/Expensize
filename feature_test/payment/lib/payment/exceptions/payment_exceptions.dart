/// Payment exceptions
library;

import '../models/payment_error.dart';

/// Base payment exception
class PaymentException implements Exception {
  final String message;
  final PaymentErrorCode code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const PaymentException({
    required this.message,
    this.code = PaymentErrorCode.unknown,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() {
    return 'PaymentException($code): $message';
  }
}

/// Payment validation exception
class PaymentValidationException extends PaymentException {
  final Map<String, String>? fieldErrors;

  PaymentValidationException({
    required String message,
    this.fieldErrors,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: PaymentErrorCode.validationError,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Payment provider exception
class PaymentProviderException extends PaymentException {
  final String providerId;

  PaymentProviderException({
    required this.providerId,
    required String message,
    PaymentErrorCode code = PaymentErrorCode.providerUnavailable,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Payment network exception
class PaymentNetworkException extends PaymentException {
  PaymentNetworkException({
    String message = 'Network error occurred during payment',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: PaymentErrorCode.networkError,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Payment timeout exception
class PaymentTimeoutException extends PaymentException {
  PaymentTimeoutException({
    String message = 'Payment request timed out',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: PaymentErrorCode.timeout,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Payment authentication exception
class PaymentAuthenticationException extends PaymentException {
  PaymentAuthenticationException({
    String message = 'Payment authentication failed',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: PaymentErrorCode.authenticationError,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Payment declined exception
class PaymentDeclinedException extends PaymentException {
  final String? declineCode;

  PaymentDeclinedException({
    String message = 'Payment was declined',
    this.declineCode,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: PaymentErrorCode.cardDeclined,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Transaction not found exception
class TransactionNotFoundException extends PaymentException {
  final String transactionId;

  TransactionNotFoundException({
    required this.transactionId,
    String? message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message ?? 'Transaction not found: $transactionId',
          code: PaymentErrorCode.transactionNotFound,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Subscription not found exception
class SubscriptionNotFoundException extends PaymentException {
  final String subscriptionId;

  SubscriptionNotFoundException({
    required this.subscriptionId,
    String? message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message ?? 'Subscription not found: $subscriptionId',
          code: PaymentErrorCode.subscriptionNotFound,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Refund failed exception
class RefundFailedException extends PaymentException {
  final String transactionId;

  RefundFailedException({
    required this.transactionId,
    String? message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message ?? 'Refund failed for transaction: $transactionId',
          code: PaymentErrorCode.refundFailed,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// User canceled payment exception
class UserCanceledPaymentException extends PaymentException {
  UserCanceledPaymentException({
    String message = 'Payment was canceled by user',
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message,
          code: PaymentErrorCode.userCanceled,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Duplicate transaction exception
class DuplicateTransactionException extends PaymentException {
  final String transactionId;

  DuplicateTransactionException({
    required this.transactionId,
    String? message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message ?? 'Duplicate transaction: $transactionId',
          code: PaymentErrorCode.duplicateTransaction,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Currency not supported exception
class CurrencyNotSupportedException extends PaymentException {
  final String currency;
  final String providerId;

  CurrencyNotSupportedException({
    required this.currency,
    required this.providerId,
    String? message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message ??
              'Currency $currency is not supported by provider $providerId',
          code: PaymentErrorCode.currencyNotSupported,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}

/// Amount validation exception
class AmountValidationException extends PaymentException {
  final double amount;
  final bool isTooSmall;

  AmountValidationException({
    required this.amount,
    required this.isTooSmall,
    String? message,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message: message ??
              (isTooSmall
                  ? 'Amount $amount is too small'
                  : 'Amount $amount is too large'),
          code: isTooSmall
              ? PaymentErrorCode.amountTooSmall
              : PaymentErrorCode.amountTooLarge,
          originalError: originalError,
          stackTrace: stackTrace,
        );
}
