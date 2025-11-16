/// UPI transaction record model
library;

import 'upi_payment_request.dart';
import 'upi_payment_response.dart';

/// UPI transaction record for local storage and tracking
class UpiTransaction {
  /// Unique transaction ID
  final String transactionId;

  /// Transaction reference number
  final String? transactionRef;

  /// Bank approval reference
  final String? approvalRef;

  /// Transaction status
  final UpiTransactionStatus status;

  /// Payee VPA
  final String payeeVpa;

  /// Payee name
  final String payeeName;

  /// Transaction amount
  final double amount;

  /// Currency
  final String currency;

  /// Transaction note
  final String transactionNote;

  /// UPI app used
  final String upiApp;

  /// Transaction creation timestamp
  final DateTime createdAt;

  /// Transaction completion timestamp
  final DateTime? completedAt;

  /// Server verification status
  final bool? isVerified;

  /// Verification timestamp
  final DateTime? verifiedAt;

  /// Error message (if failed)
  final String? errorMessage;

  /// Response code
  final String? responseCode;

  /// Additional metadata
  final Map<String, dynamic>? metadata;

  const UpiTransaction({
    required this.transactionId,
    this.transactionRef,
    this.approvalRef,
    required this.status,
    required this.payeeVpa,
    required this.payeeName,
    required this.amount,
    required this.currency,
    required this.transactionNote,
    required this.upiApp,
    required this.createdAt,
    this.completedAt,
    this.isVerified,
    this.verifiedAt,
    this.errorMessage,
    this.responseCode,
    this.metadata,
  });

  /// Create from payment request and response
  factory UpiTransaction.fromRequestAndResponse({
    required UpiPaymentRequest request,
    required UpiPaymentResponse response,
    required String upiApp,
  }) {
    return UpiTransaction(
      transactionId: request.transactionId,
      transactionRef: response.transactionRef,
      approvalRef: response.approvalRef,
      status: response.status,
      payeeVpa: request.payeeVpa,
      payeeName: request.payeeName,
      amount: request.amount,
      currency: request.currency,
      transactionNote: request.transactionNote,
      upiApp: upiApp,
      createdAt: DateTime.now(),
      completedAt: response.timestamp,
      errorMessage: response.errorMessage,
      responseCode: response.responseCode.code,
    );
  }

  /// Whether transaction was successful
  bool get isSuccess => status == UpiTransactionStatus.success;

  /// Whether transaction failed
  bool get isFailed => status == UpiTransactionStatus.failure;

  /// Whether transaction is pending
  bool get isPending => status == UpiTransactionStatus.pending;

  /// Whether transaction was canceled
  bool get isCanceled => status == UpiTransactionStatus.canceled;

  /// Whether transaction is completed (success or failure)
  bool get isCompleted => completedAt != null;

  /// Format amount for display
  String get formattedAmount => '₹${amount.toStringAsFixed(2)}';

  /// Transaction duration (if completed)
  Duration? get duration {
    if (completedAt == null) return null;
    return completedAt!.difference(createdAt);
  }

  /// Copy with modifications
  UpiTransaction copyWith({
    String? transactionId,
    String? transactionRef,
    String? approvalRef,
    UpiTransactionStatus? status,
    String? payeeVpa,
    String? payeeName,
    double? amount,
    String? currency,
    String? transactionNote,
    String? upiApp,
    DateTime? createdAt,
    DateTime? completedAt,
    bool? isVerified,
    DateTime? verifiedAt,
    String? errorMessage,
    String? responseCode,
    Map<String, dynamic>? metadata,
  }) {
    return UpiTransaction(
      transactionId: transactionId ?? this.transactionId,
      transactionRef: transactionRef ?? this.transactionRef,
      approvalRef: approvalRef ?? this.approvalRef,
      status: status ?? this.status,
      payeeVpa: payeeVpa ?? this.payeeVpa,
      payeeName: payeeName ?? this.payeeName,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      transactionNote: transactionNote ?? this.transactionNote,
      upiApp: upiApp ?? this.upiApp,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      isVerified: isVerified ?? this.isVerified,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      errorMessage: errorMessage ?? this.errorMessage,
      responseCode: responseCode ?? this.responseCode,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'transactionRef': transactionRef,
      'approvalRef': approvalRef,
      'status': status.name,
      'payeeVpa': payeeVpa,
      'payeeName': payeeName,
      'amount': amount,
      'currency': currency,
      'transactionNote': transactionNote,
      'upiApp': upiApp,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'isVerified': isVerified,
      'verifiedAt': verifiedAt?.toIso8601String(),
      'errorMessage': errorMessage,
      'responseCode': responseCode,
      'metadata': metadata,
    };
  }

  /// Create from JSON
  factory UpiTransaction.fromJson(Map<String, dynamic> json) {
    return UpiTransaction(
      transactionId: json['transactionId'] as String,
      transactionRef: json['transactionRef'] as String?,
      approvalRef: json['approvalRef'] as String?,
      status: UpiTransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => UpiTransactionStatus.unknown,
      ),
      payeeVpa: json['payeeVpa'] as String,
      payeeName: json['payeeName'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      transactionNote: json['transactionNote'] as String,
      upiApp: json['upiApp'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      isVerified: json['isVerified'] as bool?,
      verifiedAt: json['verifiedAt'] != null
          ? DateTime.parse(json['verifiedAt'] as String)
          : null,
      errorMessage: json['errorMessage'] as String?,
      responseCode: json['responseCode'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'UpiTransaction(id: $transactionId, status: $status, amount: $formattedAmount, app: $upiApp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UpiTransaction && other.transactionId == transactionId;
  }

  @override
  int get hashCode => transactionId.hashCode;
}
