/// Payment request model
library;

import 'customer.dart';

/// Supported payment methods
enum PaymentMethod {
  /// Credit/debit card
  card,

  /// Digital wallet (Apple Pay, Google Pay, etc.)
  wallet,

  /// Bank transfer
  bankTransfer,

  /// UPI (Unified Payments Interface - India)
  upi,

  /// Net banking
  netBanking,

  /// PayPal
  paypal,

  /// Buy now, pay later
  bnpl,

  /// Cryptocurrency
  crypto,

  /// In-app purchase (Google Play / Apple App Store)
  inAppPurchase,
}

/// Payment request for processing
class PaymentRequest {
  /// Unique request identifier (idempotency key)
  final String requestId;

  /// Payment amount
  final double amount;

  /// ISO currency code (USD, EUR, INR, GBP, etc.)
  final String currency;

  /// Payment description
  final String description;

  /// Customer information
  final Customer? customer;

  /// Additional metadata
  final Map<String, dynamic>? metadata;

  /// Preferred payment method
  final PaymentMethod? preferredMethod;

  /// Webhook callback URL for async notifications
  final String? callbackUrl;

  /// Save payment method for future use
  final bool savePaymentMethod;

  /// Whether this is a test/sandbox transaction
  final bool isTestMode;

  /// Product/order identifier
  final String? orderId;

  /// Return URL after payment (for web flows)
  final String? returnUrl;

  /// Cancel URL (for web flows)
  final String? cancelUrl;

  PaymentRequest({
    String? requestId,
    required this.amount,
    required this.currency,
    required this.description,
    this.customer,
    this.metadata,
    this.preferredMethod,
    this.callbackUrl,
    this.savePaymentMethod = false,
    this.isTestMode = false,
    this.orderId,
    this.returnUrl,
    this.cancelUrl,
  }) : requestId = requestId ?? _generateRequestId();

  /// Generate unique request ID
  static String _generateRequestId() {
    return 'req_${DateTime.now().millisecondsSinceEpoch}_${_randomString(8)}';
  }

  static String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(
      length,
      (index) => chars[(DateTime.now().microsecond + index) % chars.length],
    ).join();
  }

  /// Validate request
  bool get isValid {
    if (amount <= 0) return false;
    if (currency.isEmpty || currency.length != 3) return false;
    if (description.isEmpty) return false;
    return true;
  }

  /// Get validation error message
  String? get validationError {
    if (amount <= 0) return 'Amount must be greater than 0';
    if (currency.isEmpty || currency.length != 3) {
      return 'Invalid currency code';
    }
    if (description.isEmpty) return 'Description is required';
    return null;
  }

  /// Copy with modifications
  PaymentRequest copyWith({
    String? requestId,
    double? amount,
    String? currency,
    String? description,
    Customer? customer,
    Map<String, dynamic>? metadata,
    PaymentMethod? preferredMethod,
    String? callbackUrl,
    bool? savePaymentMethod,
    bool? isTestMode,
    String? orderId,
    String? returnUrl,
    String? cancelUrl,
  }) {
    return PaymentRequest(
      requestId: requestId ?? this.requestId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      customer: customer ?? this.customer,
      metadata: metadata ?? this.metadata,
      preferredMethod: preferredMethod ?? this.preferredMethod,
      callbackUrl: callbackUrl ?? this.callbackUrl,
      savePaymentMethod: savePaymentMethod ?? this.savePaymentMethod,
      isTestMode: isTestMode ?? this.isTestMode,
      orderId: orderId ?? this.orderId,
      returnUrl: returnUrl ?? this.returnUrl,
      cancelUrl: cancelUrl ?? this.cancelUrl,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'amount': amount,
      'currency': currency,
      'description': description,
      'customer': customer?.toJson(),
      'metadata': metadata,
      'preferredMethod': preferredMethod?.name,
      'callbackUrl': callbackUrl,
      'savePaymentMethod': savePaymentMethod,
      'isTestMode': isTestMode,
      'orderId': orderId,
      'returnUrl': returnUrl,
      'cancelUrl': cancelUrl,
    };
  }

  /// Create from JSON
  factory PaymentRequest.fromJson(Map<String, dynamic> json) {
    return PaymentRequest(
      requestId: json['requestId'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      description: json['description'] as String,
      customer: json['customer'] != null
          ? Customer.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      preferredMethod: json['preferredMethod'] != null
          ? PaymentMethod.values.firstWhere(
              (e) => e.name == json['preferredMethod'],
              orElse: () => PaymentMethod.card,
            )
          : null,
      callbackUrl: json['callbackUrl'] as String?,
      savePaymentMethod: json['savePaymentMethod'] as bool? ?? false,
      isTestMode: json['isTestMode'] as bool? ?? false,
      orderId: json['orderId'] as String?,
      returnUrl: json['returnUrl'] as String?,
      cancelUrl: json['cancelUrl'] as String?,
    );
  }

  @override
  String toString() {
    return 'PaymentRequest(id: $requestId, amount: $amount $currency, description: $description)';
  }
}
