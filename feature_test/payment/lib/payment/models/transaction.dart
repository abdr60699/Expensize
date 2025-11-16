/// Transaction models
library;

import 'payment_result.dart';

/// Transaction type
enum TransactionType {
  /// One-time payment
  payment,

  /// Subscription payment
  subscription,

  /// Refund
  refund,

  /// Partial refund
  partialRefund,

  /// Authorization (not yet captured)
  authorization,

  /// Capture of authorized payment
  capture,

  /// Failed payment attempt
  failed,
}

/// Transaction record
class Transaction {
  /// Unique transaction identifier
  final String transactionId;

  /// Transaction type
  final TransactionType type;

  /// Transaction amount
  final double amount;

  /// ISO currency code
  final String currency;

  /// Transaction status
  final PaymentStatus status;

  /// Payment provider identifier
  final String providerId;

  /// Transaction timestamp
  final DateTime timestamp;

  /// Customer identifier
  final String? customerId;

  /// Subscription identifier (if applicable)
  final String? subscriptionId;

  /// Order/product identifier
  final String? orderId;

  /// Receipt URL
  final String? receiptUrl;

  /// Payment method used
  final String? paymentMethod;

  /// Last 4 digits of card (if applicable)
  final String? last4;

  /// Card brand (Visa, Mastercard, etc.)
  final String? cardBrand;

  /// Transaction description
  final String? description;

  /// Fee amount charged by provider
  final double? feeAmount;

  /// Net amount received (amount - fee)
  final double? netAmount;

  /// Original transaction ID (for refunds)
  final String? originalTransactionId;

  /// Refund reason (if applicable)
  final String? refundReason;

  /// Additional metadata
  final Map<String, dynamic>? metadata;

  const Transaction({
    required this.transactionId,
    required this.type,
    required this.amount,
    required this.currency,
    required this.status,
    required this.providerId,
    required this.timestamp,
    this.customerId,
    this.subscriptionId,
    this.orderId,
    this.receiptUrl,
    this.paymentMethod,
    this.last4,
    this.cardBrand,
    this.description,
    this.feeAmount,
    this.netAmount,
    this.originalTransactionId,
    this.refundReason,
    this.metadata,
  });

  /// Whether transaction was successful
  bool get isSuccessful => status == PaymentStatus.succeeded;

  /// Whether transaction was refunded
  bool get isRefunded =>
      status == PaymentStatus.refunded ||
      status == PaymentStatus.partiallyRefunded;

  /// Whether transaction failed
  bool get isFailed => status == PaymentStatus.failed;

  /// Display amount (formatted with currency symbol)
  String get displayAmount {
    final symbol = _getCurrencySymbol(currency);
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  static String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'INR':
        return '₹';
      case 'JPY':
        return '¥';
      case 'CNY':
        return '¥';
      case 'AUD':
        return 'A\$';
      case 'CAD':
        return 'C\$';
      default:
        return currency;
    }
  }

  /// Copy with modifications
  Transaction copyWith({
    String? transactionId,
    TransactionType? type,
    double? amount,
    String? currency,
    PaymentStatus? status,
    String? providerId,
    DateTime? timestamp,
    String? customerId,
    String? subscriptionId,
    String? orderId,
    String? receiptUrl,
    String? paymentMethod,
    String? last4,
    String? cardBrand,
    String? description,
    double? feeAmount,
    double? netAmount,
    String? originalTransactionId,
    String? refundReason,
    Map<String, dynamic>? metadata,
  }) {
    return Transaction(
      transactionId: transactionId ?? this.transactionId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      providerId: providerId ?? this.providerId,
      timestamp: timestamp ?? this.timestamp,
      customerId: customerId ?? this.customerId,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      orderId: orderId ?? this.orderId,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      last4: last4 ?? this.last4,
      cardBrand: cardBrand ?? this.cardBrand,
      description: description ?? this.description,
      feeAmount: feeAmount ?? this.feeAmount,
      netAmount: netAmount ?? this.netAmount,
      originalTransactionId:
          originalTransactionId ?? this.originalTransactionId,
      refundReason: refundReason ?? this.refundReason,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'type': type.name,
      'amount': amount,
      'currency': currency,
      'status': status.name,
      'providerId': providerId,
      'timestamp': timestamp.toIso8601String(),
      'customerId': customerId,
      'subscriptionId': subscriptionId,
      'orderId': orderId,
      'receiptUrl': receiptUrl,
      'paymentMethod': paymentMethod,
      'last4': last4,
      'cardBrand': cardBrand,
      'description': description,
      'feeAmount': feeAmount,
      'netAmount': netAmount,
      'originalTransactionId': originalTransactionId,
      'refundReason': refundReason,
      'metadata': metadata,
    };
  }

  /// Create from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transactionId: json['transactionId'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.payment,
      ),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.failed,
      ),
      providerId: json['providerId'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      customerId: json['customerId'] as String?,
      subscriptionId: json['subscriptionId'] as String?,
      orderId: json['orderId'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      last4: json['last4'] as String?,
      cardBrand: json['cardBrand'] as String?,
      description: json['description'] as String?,
      feeAmount: json['feeAmount'] != null
          ? (json['feeAmount'] as num).toDouble()
          : null,
      netAmount: json['netAmount'] != null
          ? (json['netAmount'] as num).toDouble()
          : null,
      originalTransactionId: json['originalTransactionId'] as String?,
      refundReason: json['refundReason'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'Transaction(id: $transactionId, type: $type, amount: $displayAmount, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Transaction && other.transactionId == transactionId;
  }

  @override
  int get hashCode => transactionId.hashCode;
}

/// Refund request
class RefundRequest {
  /// Transaction ID to refund
  final String transactionId;

  /// Refund amount (null for full refund)
  final double? amount;

  /// Reason for refund
  final String? reason;

  /// Additional metadata
  final Map<String, dynamic>? metadata;

  const RefundRequest({
    required this.transactionId,
    this.amount,
    this.reason,
    this.metadata,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'amount': amount,
      'reason': reason,
      'metadata': metadata,
    };
  }
}

/// Refund result
class RefundResult {
  /// Refund transaction
  final Transaction refundTransaction;

  /// Whether refund was successful
  final bool success;

  /// Error message if failed
  final String? error;

  const RefundResult({
    required this.refundTransaction,
    required this.success,
    this.error,
  });

  /// Create successful refund result
  factory RefundResult.success(Transaction refundTransaction) {
    return RefundResult(
      refundTransaction: refundTransaction,
      success: true,
    );
  }

  /// Create failed refund result
  factory RefundResult.failed({
    required Transaction refundTransaction,
    required String error,
  }) {
    return RefundResult(
      refundTransaction: refundTransaction,
      success: false,
      error: error,
    );
  }
}
