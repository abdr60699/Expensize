/// Mock payment provider for testing
library;

import '../../config/provider_config.dart';
import '../../exceptions/payment_exceptions.dart';
import '../../models/payment_models.dart';
import '../base/payment_provider_interface.dart';

/// Mock payment provider for testing and development
class MockPaymentProvider implements IPaymentProvider {
  bool _isInitialized = false;
  bool _isEnabled = true;
  final List<Transaction> _transactions = [];
  final List<Subscription> _subscriptions = [];

  @override
  String get providerId => 'mock';

  @override
  String get providerName => 'Mock Payment Provider';

  @override
  bool get isEnabled => _isEnabled;

  @override
  bool get isInitialized => _isInitialized;

  @override
  List<String> get supportedCurrencies => ['USD', 'EUR', 'GBP', 'INR'];

  @override
  List<PaymentMethod> get supportedMethods => [
        PaymentMethod.card,
        PaymentMethod.wallet,
        PaymentMethod.bankTransfer,
      ];

  @override
  bool get supportsSubscriptions => true;

  @override
  bool get supportsRefunds => true;

  @override
  Future<void> initialize(ProviderConfig config) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _isInitialized = true;
  }

  @override
  Future<void> dispose() async {
    _isInitialized = false;
  }

  @override
  Future<PaymentResult> processPayment(PaymentRequest request) async {
    if (!_isInitialized) {
      throw PaymentProviderException(
        providerId: providerId,
        message: 'Provider not initialized',
      );
    }

    // Validate request
    if (!request.isValid) {
      throw PaymentValidationException(message: request.validationError!);
    }

    // Simulate processing delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Create transaction
    final transaction = Transaction(
      transactionId: 'mock_txn_${DateTime.now().millisecondsSinceEpoch}',
      type: TransactionType.payment,
      amount: request.amount,
      currency: request.currency,
      status: PaymentStatus.succeeded,
      providerId: providerId,
      timestamp: DateTime.now(),
      customerId: request.customer?.customerId,
      orderId: request.orderId,
      description: request.description,
      paymentMethod: request.preferredMethod?.name,
      last4: '4242',
      cardBrand: 'Visa',
      receiptUrl: 'https://mock.example.com/receipt/123',
    );

    _transactions.add(transaction);

    return PaymentResult.success(
      transactionId: transaction.transactionId,
      amount: transaction.amount,
      currency: transaction.currency,
      providerId: providerId,
      receiptUrl: transaction.receiptUrl,
      receiptData: 'mock_receipt_data_${transaction.transactionId}',
    );
  }

  @override
  Future<SubscriptionResult> createSubscription(
    SubscriptionRequest request,
  ) async {
    if (!_isInitialized) {
      throw PaymentProviderException(
        providerId: providerId,
        message: 'Provider not initialized',
      );
    }

    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    final trialEnd = request.trialDays > 0
        ? now.add(Duration(days: request.trialDays))
        : null;

    final subscription = Subscription(
      subscriptionId: 'mock_sub_${now.millisecondsSinceEpoch}',
      customerId: request.customerId,
      planId: request.planId,
      status: trialEnd != null
          ? SubscriptionStatus.trialing
          : SubscriptionStatus.active,
      startDate: now,
      trialEndDate: trialEnd,
      currentPeriodStart: now,
      currentPeriodEnd: now.add(const Duration(days: 30)),
      amount: request.customAmount ?? 9.99,
      currency: 'USD',
      interval: BillingInterval.monthly,
      providerId: providerId,
    );

    _subscriptions.add(subscription);

    return SubscriptionResult.success(subscription);
  }

  @override
  Future<void> cancelSubscription(
    String subscriptionId, {
    CancellationReason? reason,
  }) async {
    if (!_isInitialized) {
      throw PaymentProviderException(
        providerId: providerId,
        message: 'Provider not initialized',
      );
    }

    await Future.delayed(const Duration(milliseconds: 300));

    final index =
        _subscriptions.indexWhere((s) => s.subscriptionId == subscriptionId);

    if (index == -1) {
      throw SubscriptionNotFoundException(subscriptionId: subscriptionId);
    }

    _subscriptions[index] = _subscriptions[index].copyWith(
      status: SubscriptionStatus.canceled,
      canceledAt: DateTime.now(),
      cancellationReason: reason,
    );
  }

  @override
  Future<Subscription> getSubscription(String subscriptionId) async {
    final subscription =
        _subscriptions.firstWhere((s) => s.subscriptionId == subscriptionId);
    return subscription;
  }

  @override
  Future<SubscriptionResult> updateSubscription(
    String subscriptionId,
    SubscriptionUpdate update,
  ) async {
    if (!_isInitialized) {
      throw PaymentProviderException(
        providerId: providerId,
        message: 'Provider not initialized',
      );
    }

    final index =
        _subscriptions.indexWhere((s) => s.subscriptionId == subscriptionId);

    if (index == -1) {
      throw SubscriptionNotFoundException(subscriptionId: subscriptionId);
    }

    _subscriptions[index] = _subscriptions[index].copyWith(
      planId: update.planId,
      amount: update.amount,
    );

    return SubscriptionResult.success(_subscriptions[index]);
  }

  @override
  Future<ReceiptValidation> validateReceipt(String receiptData) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final receipt = Receipt(
      receiptId: 'mock_receipt_${DateTime.now().millisecondsSinceEpoch}',
      transactionId: 'mock_txn_123',
      providerId: providerId,
      receiptData: receiptData,
      status: ReceiptStatus.valid,
      createdAt: DateTime.now(),
    );

    return ReceiptValidation.valid(
      receipt: receipt,
      productId: 'mock_product_123',
      transactionId: 'mock_txn_123',
      purchaseDate: DateTime.now(),
    );
  }

  @override
  Future<RefundResult> refundTransaction(
    String transactionId, {
    double? amount,
  }) async {
    if (!_isInitialized) {
      throw PaymentProviderException(
        providerId: providerId,
        message: 'Provider not initialized',
      );
    }

    await Future.delayed(const Duration(milliseconds: 400));

    final originalTransaction =
        _transactions.firstWhere((t) => t.transactionId == transactionId);

    final refundAmount = amount ?? originalTransaction.amount;

    final refundTransaction = Transaction(
      transactionId: 'mock_refund_${DateTime.now().millisecondsSinceEpoch}',
      type: refundAmount == originalTransaction.amount
          ? TransactionType.refund
          : TransactionType.partialRefund,
      amount: refundAmount,
      currency: originalTransaction.currency,
      status: PaymentStatus.refunded,
      providerId: providerId,
      timestamp: DateTime.now(),
      customerId: originalTransaction.customerId,
      orderId: originalTransaction.orderId,
      originalTransactionId: transactionId,
      refundReason: 'Customer requested refund',
    );

    _transactions.add(refundTransaction);

    return RefundResult.success(refundTransaction);
  }

  @override
  Future<List<Transaction>> getTransactionHistory({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    var filtered = _transactions;

    if (startDate != null) {
      filtered = filtered.where((t) => t.timestamp.isAfter(startDate)).toList();
    }

    if (endDate != null) {
      filtered = filtered.where((t) => t.timestamp.isBefore(endDate)).toList();
    }

    if (limit != null && filtered.length > limit) {
      filtered = filtered.take(limit).toList();
    }

    return filtered;
  }

  @override
  Future<Transaction> getTransaction(String transactionId) async {
    try {
      return _transactions.firstWhere((t) => t.transactionId == transactionId);
    } catch (e) {
      throw TransactionNotFoundException(transactionId: transactionId);
    }
  }

  @override
  Future<PaymentStatus> checkPaymentStatus(String transactionId) async {
    final transaction = await getTransaction(transactionId);
    return transaction.status;
  }

  @override
  bool supportsCurrency(String currency) {
    return supportedCurrencies.contains(currency.toUpperCase());
  }

  @override
  bool supportsPaymentMethod(PaymentMethod method) {
    return supportedMethods.contains(method);
  }
}
