/// Payment processing result model
library;

import 'payment_error.dart';

/// Status of a payment transaction
enum PaymentStatus {
  /// Payment initiated, awaiting completion
  pending,

  /// Payment being processed
  processing,

  /// Payment successful
  succeeded,

  /// Payment failed
  failed,

  /// Payment canceled by user
  canceled,

  /// Payment refunded
  refunded,

  /// Payment partially refunded
  partiallyRefunded,
}

/// Result of a payment operation
class PaymentResult {
  /// Unique transaction identifier
  final String transactionId;

  /// Current payment status
  final PaymentStatus status;

  /// Amount paid/attempted
  final double amount;

  /// ISO currency code (USD, EUR, INR, etc.)
  final String currency;

  /// Provider that processed the payment
  final String providerId;

  /// Transaction timestamp
  final DateTime timestamp;

  /// URL to receipt/invoice
  final String? receiptUrl;

  /// Raw receipt data for validation
  final String? receiptData;

  /// Additional metadata
  final Map<String, dynamic>? metadata;

  /// Error information if payment failed
  final PaymentError? error;

  const PaymentResult({
    required this.transactionId,
    required this.status,
    required this.amount,
    required this.currency,
    required this.providerId,
    required this.timestamp,
    this.receiptUrl,
    this.receiptData,
    this.metadata,
    this.error,
  });

  /// Create successful payment result
  factory PaymentResult.success({
    required String transactionId,
    required double amount,
    required String currency,
    required String providerId,
    String? receiptUrl,
    String? receiptData,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentResult(
      transactionId: transactionId,
      status: PaymentStatus.succeeded,
      amount: amount,
      currency: currency,
      providerId: providerId,
      timestamp: DateTime.now(),
      receiptUrl: receiptUrl,
      receiptData: receiptData,
      metadata: metadata,
    );
  }

  /// Create failed payment result
  factory PaymentResult.failed({
    required String transactionId,
    required double amount,
    required String currency,
    required String providerId,
    required PaymentError error,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentResult(
      transactionId: transactionId,
      status: PaymentStatus.failed,
      amount: amount,
      currency: currency,
      providerId: providerId,
      timestamp: DateTime.now(),
      metadata: metadata,
      error: error,
    );
  }

  /// Create canceled payment result
  factory PaymentResult.canceled({
    required String transactionId,
    required double amount,
    required String currency,
    required String providerId,
    Map<String, dynamic>? metadata,
  }) {
    return PaymentResult(
      transactionId: transactionId,
      status: PaymentStatus.canceled,
      amount: amount,
      currency: currency,
      providerId: providerId,
      timestamp: DateTime.now(),
      metadata: metadata,
    );
  }

  /// Whether payment was successful
  bool get isSuccess => status == PaymentStatus.succeeded;

  /// Whether payment failed
  bool get isFailed => status == PaymentStatus.failed;

  /// Whether payment was canceled
  bool get isCanceled => status == PaymentStatus.canceled;

  /// Whether payment is still processing
  bool get isProcessing =>
      status == PaymentStatus.processing || status == PaymentStatus.pending;

  /// Copy with modifications
  PaymentResult copyWith({
    String? transactionId,
    PaymentStatus? status,
    double? amount,
    String? currency,
    String? providerId,
    DateTime? timestamp,
    String? receiptUrl,
    String? receiptData,
    Map<String, dynamic>? metadata,
    PaymentError? error,
  }) {
    return PaymentResult(
      transactionId: transactionId ?? this.transactionId,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      providerId: providerId ?? this.providerId,
      timestamp: timestamp ?? this.timestamp,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      receiptData: receiptData ?? this.receiptData,
      metadata: metadata ?? this.metadata,
      error: error ?? this.error,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'status': status.name,
      'amount': amount,
      'currency': currency,
      'providerId': providerId,
      'timestamp': timestamp.toIso8601String(),
      'receiptUrl': receiptUrl,
      'receiptData': receiptData,
      'metadata': metadata,
      'error': error?.toJson(),
    };
  }

  /// Create from JSON
  factory PaymentResult.fromJson(Map<String, dynamic> json) {
    return PaymentResult(
      transactionId: json['transactionId'] as String,
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.failed,
      ),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      providerId: json['providerId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      receiptUrl: json['receiptUrl'] as String?,
      receiptData: json['receiptData'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      error: json['error'] != null
          ? PaymentError.fromJson(json['error'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  String toString() {
    return 'PaymentResult(id: $transactionId, status: $status, amount: $amount $currency, provider: $providerId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PaymentResult && other.transactionId == transactionId;
  }

  @override
  int get hashCode => transactionId.hashCode;
}
