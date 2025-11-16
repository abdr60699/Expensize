/// UPI payment response model
library;

/// UPI transaction status
enum UpiTransactionStatus {
  /// Payment successful
  success,

  /// Payment failed
  failure,

  /// Payment pending (awaiting confirmation)
  pending,

  /// User canceled payment
  canceled,

  /// Unknown status
  unknown,
}

/// UPI response codes
enum UpiResponseCode {
  /// Payment successful
  success('00'),

  /// Payment pending
  pending('01'),

  /// Payment failed
  failure('02'),

  /// User canceled
  userCanceled('03'),

  /// Invalid VPA
  invalidVpa('04'),

  /// Transaction not allowed
  transactionNotAllowed('05'),

  /// Amount exceeds limit
  exceedsLimit('06'),

  /// Unknown error
  unknown('99');

  final String code;
  const UpiResponseCode(this.code);

  static UpiResponseCode fromCode(String code) {
    return UpiResponseCode.values.firstWhere(
      (e) => e.code == code,
      orElse: () => UpiResponseCode.unknown,
    );
  }
}

/// UPI payment response from payment app
class UpiPaymentResponse {
  /// Transaction status
  final UpiTransactionStatus status;

  /// Transaction ID (from request)
  final String transactionId;

  /// UPI transaction reference number (from UPI)
  final String? transactionRef;

  /// Bank approval reference number
  final String? approvalRef;

  /// Response code
  final UpiResponseCode responseCode;

  /// Error message (if failed)
  final String? errorMessage;

  /// Response timestamp
  final DateTime timestamp;

  /// Raw response data
  final Map<String, dynamic> rawData;

  /// Payee VPA (from request)
  final String? payeeVpa;

  /// Amount (from request)
  final double? amount;

  const UpiPaymentResponse({
    required this.status,
    required this.transactionId,
    this.transactionRef,
    this.approvalRef,
    required this.responseCode,
    this.errorMessage,
    required this.timestamp,
    required this.rawData,
    this.payeeVpa,
    this.amount,
  });

  /// Create successful response
  factory UpiPaymentResponse.success({
    required String transactionId,
    required String transactionRef,
    required String approvalRef,
    String? payeeVpa,
    double? amount,
    Map<String, dynamic>? rawData,
  }) {
    return UpiPaymentResponse(
      status: UpiTransactionStatus.success,
      transactionId: transactionId,
      transactionRef: transactionRef,
      approvalRef: approvalRef,
      responseCode: UpiResponseCode.success,
      timestamp: DateTime.now(),
      rawData: rawData ?? {},
      payeeVpa: payeeVpa,
      amount: amount,
    );
  }

  /// Create failed response
  factory UpiPaymentResponse.failure({
    required String transactionId,
    required String errorMessage,
    UpiResponseCode? responseCode,
    String? payeeVpa,
    double? amount,
    Map<String, dynamic>? rawData,
  }) {
    return UpiPaymentResponse(
      status: UpiTransactionStatus.failure,
      transactionId: transactionId,
      errorMessage: errorMessage,
      responseCode: responseCode ?? UpiResponseCode.failure,
      timestamp: DateTime.now(),
      rawData: rawData ?? {},
      payeeVpa: payeeVpa,
      amount: amount,
    );
  }

  /// Create canceled response
  factory UpiPaymentResponse.canceled({
    required String transactionId,
    String? payeeVpa,
    double? amount,
  }) {
    return UpiPaymentResponse(
      status: UpiTransactionStatus.canceled,
      transactionId: transactionId,
      responseCode: UpiResponseCode.userCanceled,
      errorMessage: 'User canceled the payment',
      timestamp: DateTime.now(),
      rawData: {},
      payeeVpa: payeeVpa,
      amount: amount,
    );
  }

  /// Create pending response
  factory UpiPaymentResponse.pending({
    required String transactionId,
    String? transactionRef,
    String? payeeVpa,
    double? amount,
  }) {
    return UpiPaymentResponse(
      status: UpiTransactionStatus.pending,
      transactionId: transactionId,
      transactionRef: transactionRef,
      responseCode: UpiResponseCode.pending,
      timestamp: DateTime.now(),
      rawData: {},
      payeeVpa: payeeVpa,
      amount: amount,
    );
  }

  /// Whether payment was successful
  bool get isSuccess => status == UpiTransactionStatus.success;

  /// Whether payment failed
  bool get isFailed => status == UpiTransactionStatus.failure;

  /// Whether payment was canceled
  bool get isCanceled => status == UpiTransactionStatus.canceled;

  /// Whether payment is pending
  bool get isPending => status == UpiTransactionStatus.pending;

  /// Whether response has transaction reference
  bool get hasTransactionRef => transactionRef != null && transactionRef!.isNotEmpty;

  /// Whether response has approval reference
  bool get hasApprovalRef => approvalRef != null && approvalRef!.isNotEmpty;

  /// Parse response from UPI app intent data
  factory UpiPaymentResponse.fromIntentData(Map<String, dynamic> data) {
    // Parse status
    final statusStr = data['Status']?.toString().toLowerCase() ?? 'unknown';
    UpiTransactionStatus status;
    UpiResponseCode responseCode;

    switch (statusStr) {
      case 'success':
      case 'submitted':
        status = UpiTransactionStatus.success;
        responseCode = UpiResponseCode.success;
        break;
      case 'failure':
      case 'failed':
        status = UpiTransactionStatus.failure;
        responseCode = UpiResponseCode.failure;
        break;
      case 'pending':
        status = UpiTransactionStatus.pending;
        responseCode = UpiResponseCode.pending;
        break;
      case 'cancelled':
      case 'canceled':
        status = UpiTransactionStatus.canceled;
        responseCode = UpiResponseCode.userCanceled;
        break;
      default:
        status = UpiTransactionStatus.unknown;
        responseCode = UpiResponseCode.unknown;
    }

    // Extract response code if available
    if (data['responseCode'] != null) {
      responseCode = UpiResponseCode.fromCode(data['responseCode'].toString());
    }

    return UpiPaymentResponse(
      status: status,
      transactionId: data['txnId']?.toString() ?? '',
      transactionRef: data['txnRef']?.toString(),
      approvalRef: data['ApprovalRefNo']?.toString(),
      responseCode: responseCode,
      errorMessage: data['errorMessage']?.toString(),
      timestamp: DateTime.now(),
      rawData: data,
      payeeVpa: data['payeeVpa']?.toString(),
      amount: data['amount'] != null ? double.tryParse(data['amount'].toString()) : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status.name,
      'transactionId': transactionId,
      'transactionRef': transactionRef,
      'approvalRef': approvalRef,
      'responseCode': responseCode.code,
      'errorMessage': errorMessage,
      'timestamp': timestamp.toIso8601String(),
      'rawData': rawData,
      'payeeVpa': payeeVpa,
      'amount': amount,
    };
  }

  /// Create from JSON
  factory UpiPaymentResponse.fromJson(Map<String, dynamic> json) {
    return UpiPaymentResponse(
      status: UpiTransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => UpiTransactionStatus.unknown,
      ),
      transactionId: json['transactionId'] as String,
      transactionRef: json['transactionRef'] as String?,
      approvalRef: json['approvalRef'] as String?,
      responseCode: UpiResponseCode.fromCode(json['responseCode'] as String),
      errorMessage: json['errorMessage'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      rawData: json['rawData'] as Map<String, dynamic>,
      payeeVpa: json['payeeVpa'] as String?,
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
    );
  }

  @override
  String toString() {
    return 'UpiPaymentResponse(status: $status, txnId: $transactionId, txnRef: $transactionRef)';
  }
}
