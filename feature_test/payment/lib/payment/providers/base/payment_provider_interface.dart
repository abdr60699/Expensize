/// Base payment provider interface
library;

import '../../config/provider_config.dart';
import '../../models/payment_models.dart';

/// Payment provider interface that all providers must implement
abstract class IPaymentProvider {
  /// Unique provider identifier (e.g., 'stripe', 'paypal', 'razorpay', etc.)
  String get providerId;

  /// Human-readable provider name
  String get providerName;

  /// Whether this provider is currently enabled
  bool get isEnabled;

  /// Supported currencies by this provider
  List<String> get supportedCurrencies;

  /// Supported payment methods
  List<PaymentMethod> get supportedMethods;

  /// Whether provider supports subscriptions
  bool get supportsSubscriptions;

  /// Whether provider supports refunds
  bool get supportsRefunds;

  /// Whether provider is initialized
  bool get isInitialized;

  /// Initialize the provider with configuration
  ///
  /// This method should:
  /// - Validate configuration
  /// - Initialize SDK/libraries
  /// - Authenticate with provider API
  /// - Set up webhooks/listeners if needed
  ///
  /// Throws [PaymentException] if initialization fails
  Future<void> initialize(ProviderConfig config);

  /// Dispose and cleanup resources
  ///
  /// This method should:
  /// - Close connections
  /// - Cancel listeners
  /// - Clean up resources
  Future<void> dispose();

  /// Process a one-time payment
  ///
  /// [request] Payment request with amount, currency, customer info, etc.
  ///
  /// Returns [PaymentResult] with transaction details
  ///
  /// Throws:
  /// - [PaymentValidationException] if request is invalid
  /// - [PaymentDeclinedException] if payment is declined
  /// - [PaymentNetworkException] if network error occurs
  /// - [PaymentException] for other errors
  Future<PaymentResult> processPayment(PaymentRequest request);

  /// Create a subscription
  ///
  /// [request] Subscription request with plan, customer info, trial period, etc.
  ///
  /// Returns [SubscriptionResult] with subscription details
  ///
  /// Throws:
  /// - [PaymentValidationException] if request is invalid
  /// - [PaymentException] for other errors
  Future<SubscriptionResult> createSubscription(SubscriptionRequest request);

  /// Cancel a subscription
  ///
  /// [subscriptionId] ID of subscription to cancel
  /// [reason] Optional cancellation reason
  ///
  /// Throws:
  /// - [SubscriptionNotFoundException] if subscription not found
  /// - [PaymentException] for other errors
  Future<void> cancelSubscription(
    String subscriptionId, {
    CancellationReason? reason,
  });

  /// Update subscription (e.g., change plan, amount)
  ///
  /// [subscriptionId] ID of subscription to update
  /// [update] Updates to apply
  ///
  /// Returns [SubscriptionResult] with updated subscription
  ///
  /// Throws:
  /// - [SubscriptionNotFoundException] if subscription not found
  /// - [PaymentException] for other errors
  Future<SubscriptionResult> updateSubscription(
    String subscriptionId,
    SubscriptionUpdate update,
  );

  /// Get subscription details
  ///
  /// [subscriptionId] ID of subscription
  ///
  /// Returns [Subscription] details
  ///
  /// Throws:
  /// - [SubscriptionNotFoundException] if subscription not found
  Future<Subscription> getSubscription(String subscriptionId);

  /// Validate a receipt/transaction
  ///
  /// [receiptData] Raw receipt data (base64 encoded or JSON string)
  ///
  /// Returns [ReceiptValidation] result
  ///
  /// Throws [PaymentException] if validation fails
  Future<ReceiptValidation> validateReceipt(String receiptData);

  /// Refund a transaction
  ///
  /// [transactionId] ID of transaction to refund
  /// [amount] Amount to refund (null for full refund)
  ///
  /// Returns [RefundResult]
  ///
  /// Throws:
  /// - [TransactionNotFoundException] if transaction not found
  /// - [RefundFailedException] if refund fails
  Future<RefundResult> refundTransaction(
    String transactionId, {
    double? amount,
  });

  /// Get transaction history
  ///
  /// [startDate] Start date for filtering (optional)
  /// [endDate] End date for filtering (optional)
  /// [limit] Maximum number of transactions to return
  ///
  /// Returns list of [Transaction]
  Future<List<Transaction>> getTransactionHistory({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });

  /// Get transaction details
  ///
  /// [transactionId] ID of transaction
  ///
  /// Returns [Transaction] details
  ///
  /// Throws [TransactionNotFoundException] if not found
  Future<Transaction> getTransaction(String transactionId);

  /// Check payment status
  ///
  /// [transactionId] ID of transaction
  ///
  /// Returns current [PaymentStatus]
  ///
  /// Throws [TransactionNotFoundException] if not found
  Future<PaymentStatus> checkPaymentStatus(String transactionId);

  /// Check if currency is supported
  bool supportsCurrency(String currency) {
    return supportedCurrencies.contains(currency.toUpperCase());
  }

  /// Check if payment method is supported
  bool supportsPaymentMethod(PaymentMethod method) {
    return supportedMethods.contains(method);
  }
}

/// Provider information/metadata
class ProviderInfo {
  final String providerId;
  final String providerName;
  final bool isEnabled;
  final List<String> supportedCurrencies;
  final List<PaymentMethod> supportedMethods;
  final bool supportsSubscriptions;
  final bool supportsRefunds;

  const ProviderInfo({
    required this.providerId,
    required this.providerName,
    required this.isEnabled,
    required this.supportedCurrencies,
    required this.supportedMethods,
    required this.supportsSubscriptions,
    required this.supportsRefunds,
  });

  /// Create from provider instance
  factory ProviderInfo.fromProvider(IPaymentProvider provider) {
    return ProviderInfo(
      providerId: provider.providerId,
      providerName: provider.providerName,
      isEnabled: provider.isEnabled,
      supportedCurrencies: provider.supportedCurrencies,
      supportedMethods: provider.supportedMethods,
      supportsSubscriptions: provider.supportsSubscriptions,
      supportsRefunds: provider.supportsRefunds,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'providerId': providerId,
      'providerName': providerName,
      'isEnabled': isEnabled,
      'supportedCurrencies': supportedCurrencies,
      'supportedMethods': supportedMethods.map((m) => m.name).toList(),
      'supportsSubscriptions': supportsSubscriptions,
      'supportsRefunds': supportsRefunds,
    };
  }
}
