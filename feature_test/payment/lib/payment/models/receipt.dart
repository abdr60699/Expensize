/// Receipt models
library;

/// Receipt validation status
enum ReceiptStatus {
  /// Receipt not yet validated
  pending,

  /// Receipt validated successfully
  valid,

  /// Receipt validation failed
  invalid,

  /// Receipt expired
  expired,

  /// Receipt already used (duplicate)
  duplicate,
}

/// Receipt data model
class Receipt {
  /// Unique receipt identifier
  final String receiptId;

  /// Associated transaction identifier
  final String transactionId;

  /// Payment provider identifier
  final String providerId;

  /// Raw receipt data (encrypted/encoded)
  final String receiptData;

  /// Validation status
  final ReceiptStatus status;

  /// Receipt creation timestamp
  final DateTime createdAt;

  /// Receipt validation timestamp
  final DateTime? validatedAt;

  /// Validation result details
  final Map<String, dynamic>? validationResult;

  /// Product/order identifier
  final String? productId;

  /// Subscription identifier (if applicable)
  final String? subscriptionId;

  /// Additional metadata
  final Map<String, dynamic>? metadata;

  const Receipt({
    required this.receiptId,
    required this.transactionId,
    required this.providerId,
    required this.receiptData,
    required this.status,
    required this.createdAt,
    this.validatedAt,
    this.validationResult,
    this.productId,
    this.subscriptionId,
    this.metadata,
  });

  /// Whether receipt is valid
  bool get isValid => status == ReceiptStatus.valid;

  /// Whether receipt is invalid
  bool get isInvalid =>
      status == ReceiptStatus.invalid ||
      status == ReceiptStatus.expired ||
      status == ReceiptStatus.duplicate;

  /// Whether receipt is pending validation
  bool get isPending => status == ReceiptStatus.pending;

  /// Copy with modifications
  Receipt copyWith({
    String? receiptId,
    String? transactionId,
    String? providerId,
    String? receiptData,
    ReceiptStatus? status,
    DateTime? createdAt,
    DateTime? validatedAt,
    Map<String, dynamic>? validationResult,
    String? productId,
    String? subscriptionId,
    Map<String, dynamic>? metadata,
  }) {
    return Receipt(
      receiptId: receiptId ?? this.receiptId,
      transactionId: transactionId ?? this.transactionId,
      providerId: providerId ?? this.providerId,
      receiptData: receiptData ?? this.receiptData,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      validatedAt: validatedAt ?? this.validatedAt,
      validationResult: validationResult ?? this.validationResult,
      productId: productId ?? this.productId,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'receiptId': receiptId,
      'transactionId': transactionId,
      'providerId': providerId,
      'receiptData': receiptData,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'validatedAt': validatedAt?.toIso8601String(),
      'validationResult': validationResult,
      'productId': productId,
      'subscriptionId': subscriptionId,
      'metadata': metadata,
    };
  }

  /// Create from JSON
  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      receiptId: json['receiptId'] as String,
      transactionId: json['transactionId'] as String,
      providerId: json['providerId'] as String,
      receiptData: json['receiptData'] as String,
      status: ReceiptStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReceiptStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      validatedAt: json['validatedAt'] != null
          ? DateTime.parse(json['validatedAt'] as String)
          : null,
      validationResult: json['validationResult'] as Map<String, dynamic>?,
      productId: json['productId'] as String?,
      subscriptionId: json['subscriptionId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'Receipt(id: $receiptId, transaction: $transactionId, status: $status)';
  }
}

/// Receipt validation result
class ReceiptValidation {
  /// Unique validation identifier
  final String validationId;

  /// Receipt that was validated
  final Receipt receipt;

  /// Whether receipt is valid
  final bool isValid;

  /// Validation timestamp
  final DateTime validatedAt;

  /// Validation error message (if invalid)
  final String? errorMessage;

  /// Product identifier from receipt
  final String? productId;

  /// Transaction identifier from receipt
  final String? transactionId;

  /// Purchase date from receipt
  final DateTime? purchaseDate;

  /// Expiry date (for subscriptions)
  final DateTime? expiryDate;

  /// Original transaction ID (for restores)
  final String? originalTransactionId;

  /// Validation details from provider
  final Map<String, dynamic>? providerData;

  const ReceiptValidation({
    required this.validationId,
    required this.receipt,
    required this.isValid,
    required this.validatedAt,
    this.errorMessage,
    this.productId,
    this.transactionId,
    this.purchaseDate,
    this.expiryDate,
    this.originalTransactionId,
    this.providerData,
  });

  /// Create valid receipt validation
  factory ReceiptValidation.valid({
    required Receipt receipt,
    String? productId,
    String? transactionId,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    String? originalTransactionId,
    Map<String, dynamic>? providerData,
  }) {
    return ReceiptValidation(
      validationId: 'val_${DateTime.now().millisecondsSinceEpoch}',
      receipt: receipt,
      isValid: true,
      validatedAt: DateTime.now(),
      productId: productId,
      transactionId: transactionId,
      purchaseDate: purchaseDate,
      expiryDate: expiryDate,
      originalTransactionId: originalTransactionId,
      providerData: providerData,
    );
  }

  /// Create invalid receipt validation
  factory ReceiptValidation.invalid({
    required Receipt receipt,
    required String errorMessage,
    Map<String, dynamic>? providerData,
  }) {
    return ReceiptValidation(
      validationId: 'val_${DateTime.now().millisecondsSinceEpoch}',
      receipt: receipt,
      isValid: false,
      validatedAt: DateTime.now(),
      errorMessage: errorMessage,
      providerData: providerData,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'validationId': validationId,
      'receipt': receipt.toJson(),
      'isValid': isValid,
      'validatedAt': validatedAt.toIso8601String(),
      'errorMessage': errorMessage,
      'productId': productId,
      'transactionId': transactionId,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'originalTransactionId': originalTransactionId,
      'providerData': providerData,
    };
  }

  /// Create from JSON
  factory ReceiptValidation.fromJson(Map<String, dynamic> json) {
    return ReceiptValidation(
      validationId: json['validationId'] as String,
      receipt: Receipt.fromJson(json['receipt'] as Map<String, dynamic>),
      isValid: json['isValid'] as bool,
      validatedAt: DateTime.parse(json['validatedAt'] as String),
      errorMessage: json['errorMessage'] as String?,
      productId: json['productId'] as String?,
      transactionId: json['transactionId'] as String?,
      purchaseDate: json['purchaseDate'] != null
          ? DateTime.parse(json['purchaseDate'] as String)
          : null,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      originalTransactionId: json['originalTransactionId'] as String?,
      providerData: json['providerData'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'ReceiptValidation(id: $validationId, isValid: $isValid, productId: $productId)';
  }
}
