/// Payment Manager - Main orchestration service
library;

import 'dart:io' show Platform;

import '../config/payment_config.dart';
import '../exceptions/payment_exceptions.dart';
import '../models/payment_models.dart';
import '../providers/base/payment_provider_interface.dart';
import '../providers/mock/mock_payment_provider.dart';

/// Main payment manager service - single entry point for all payment operations
class PaymentManager {
  static PaymentManager? _instance;
  static PaymentManager get instance {
    if (_instance == null) {
      throw PaymentException(
        message: 'PaymentManager not initialized. Call initialize() first.',
      );
    }
    return _instance!;
  }

  final PaymentConfig _config;
  final Map<String, IPaymentProvider> _providers = {};
  bool _isInitialized = false;

  PaymentManager._(this._config);

  /// Initialize payment manager with configuration
  static Future<void> initialize(PaymentConfig config) async {
    _instance = PaymentManager._(config);
    await _instance!._initializeProviders();
  }

  /// Initialize all configured providers
  Future<void> _initializeProviders() async {
    // Initialize each enabled provider
    for (final entry in _config.providers.entries) {
      final providerId = entry.key;
      final providerConfig = entry.value;

      if (!providerConfig.enabled) {
        continue; // Skip disabled providers
      }

      try {
        final provider = _createProvider(providerId);
        await provider.initialize(providerConfig);
        _providers[providerId] = provider;
      } catch (e) {
        if (_config.enableLogging) {
          print('Failed to initialize provider $providerId: $e');
        }
        // Continue with other providers even if one fails
      }
    }

    _isInitialized = true;
  }

  /// Create provider instance based on provider ID
  IPaymentProvider _createProvider(String providerId) {
    switch (providerId) {
      case 'mock':
        return MockPaymentProvider();

      // TODO: Uncomment and implement when SDKs are added
      // case 'stripe':
      //   return StripeProvider();
      // case 'paypal':
      //   return PayPalProvider();
      // case 'razorpay':
      //   return RazorpayProvider();
      // case 'google_play':
      //   return GooglePlayBillingProvider();
      // case 'apple_iap':
      //   return AppleIAPProvider();

      default:
        throw PaymentProviderException(
          providerId: providerId,
          message: 'Unknown provider: $providerId',
        );
    }
  }

  /// Get list of available (enabled and initialized) providers
  List<ProviderInfo> getAvailableProviders() {
    return _providers.values
        .where((p) => p.isEnabled && p.isInitialized)
        .map((p) => ProviderInfo.fromProvider(p))
        .toList();
  }

  /// Get provider by ID
  IPaymentProvider? getProvider(String providerId) {
    return _providers[providerId];
  }

  /// Select best provider for request
  IPaymentProvider _selectProvider(
    PaymentRequest request,
    String? preferredProviderId,
  ) {
    // If preferred provider specified and available, use it
    if (preferredProviderId != null) {
      final provider = _providers[preferredProviderId];
      if (provider != null &&
          provider.isEnabled &&
          provider.supportsCurrency(request.currency)) {
        return provider;
      }
      if (_config.enableLogging) {
        print('Preferred provider $preferredProviderId not available');
      }
    }

    // Auto-select based on request type and platform
    if (request.preferredMethod == PaymentMethod.inAppPurchase) {
      if (Platform.isAndroid) {
        final googlePlay = _providers['google_play'];
        if (googlePlay != null && googlePlay.isEnabled) {
          return googlePlay;
        }
      } else if (Platform.isIOS) {
        final appleIAP = _providers['apple_iap'];
        if (appleIAP != null && appleIAP.isEnabled) {
          return appleIAP;
        }
      }
    }

    // Find first available provider that supports the currency
    final availableProviders = _providers.values
        .where((p) =>
            p.isEnabled &&
            p.isInitialized &&
            p.supportsCurrency(request.currency))
        .toList();

    if (availableProviders.isEmpty) {
      throw PaymentProviderException(
        providerId: 'none',
        message: 'No available provider supports currency ${request.currency}',
      );
    }

    // Return first available provider
    // TODO: Implement more sophisticated selection (lowest fees, fastest, etc.)
    return availableProviders.first;
  }

  /// Process a one-time payment
  Future<PaymentResult> processPayment(
    PaymentRequest request, {
    String? preferredProviderId,
  }) async {
    if (!_isInitialized) {
      throw PaymentException(message: 'PaymentManager not initialized');
    }

    // Validate request
    if (!request.isValid) {
      throw PaymentValidationException(message: request.validationError!);
    }

    // Select provider
    final provider = _selectProvider(request, preferredProviderId);

    try {
      // Process payment
      final result = await provider.processPayment(request);

      // Log success
      if (_config.enableLogging) {
        print('Payment processed: ${result.transactionId}');
      }

      return result;
    } on PaymentException {
      rethrow; // Re-throw payment exceptions
    } catch (e, stackTrace) {
      // Wrap other exceptions
      throw PaymentException(
        message: 'Payment processing failed: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Create a subscription
  Future<SubscriptionResult> createSubscription(
    SubscriptionRequest request, {
    String? preferredProviderId,
  }) async {
    if (!_isInitialized) {
      throw PaymentException(message: 'PaymentManager not initialized');
    }

    // Select provider
    final provider = _selectProvider(
      PaymentRequest(
        amount: 0,
        currency: 'USD',
        description: 'Subscription',
      ),
      preferredProviderId,
    );

    if (!provider.supportsSubscriptions) {
      throw PaymentException(
        message: 'Provider ${provider.providerId} does not support subscriptions',
      );
    }

    try {
      final result = await provider.createSubscription(request);

      if (_config.enableLogging) {
        print('Subscription created: ${result.subscription.subscriptionId}');
      }

      return result;
    } on PaymentException {
      rethrow;
    } catch (e, stackTrace) {
      throw PaymentException(
        message: 'Subscription creation failed: $e',
        originalError: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Cancel a subscription
  Future<void> cancelSubscription(
    String subscriptionId,
    String providerId, {
    CancellationReason? reason,
  }) async {
    final provider = _providers[providerId];
    if (provider == null) {
      throw PaymentProviderException(
        providerId: providerId,
        message: 'Provider not found',
      );
    }

    await provider.cancelSubscription(subscriptionId, reason: reason);

    if (_config.enableLogging) {
      print('Subscription canceled: $subscriptionId');
    }
  }

  /// Validate receipt
  Future<ReceiptValidation> validateReceipt(
    String receiptData,
    String providerId,
  ) async {
    final provider = _providers[providerId];
    if (provider == null) {
      throw PaymentProviderException(
        providerId: providerId,
        message: 'Provider not found',
      );
    }

    return await provider.validateReceipt(receiptData);
  }

  /// Get transaction history across all providers or specific provider
  Future<List<Transaction>> getTransactionHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? providerId,
    int? limit,
  }) async {
    if (providerId != null) {
      // Get from specific provider
      final provider = _providers[providerId];
      if (provider == null) {
        throw PaymentProviderException(
          providerId: providerId,
          message: 'Provider not found',
        );
      }

      return await provider.getTransactionHistory(
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );
    } else {
      // Get from all providers and combine
      final allTransactions = <Transaction>[];

      for (final provider in _providers.values) {
        try {
          final transactions = await provider.getTransactionHistory(
            startDate: startDate,
            endDate: endDate,
          );
          allTransactions.addAll(transactions);
        } catch (e) {
          if (_config.enableLogging) {
            print('Failed to get transactions from ${provider.providerId}: $e');
          }
        }
      }

      // Sort by timestamp (newest first)
      allTransactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Apply limit
      if (limit != null && allTransactions.length > limit) {
        return allTransactions.take(limit).toList();
      }

      return allTransactions;
    }
  }

  /// Refund a transaction
  Future<RefundResult> refundTransaction(
    String transactionId,
    String providerId, {
    double? amount,
  }) async {
    final provider = _providers[providerId];
    if (provider == null) {
      throw PaymentProviderException(
        providerId: providerId,
        message: 'Provider not found',
      );
    }

    if (!provider.supportsRefunds) {
      throw PaymentException(
        message: 'Provider ${provider.providerId} does not support refunds',
      );
    }

    return await provider.refundTransaction(transactionId, amount: amount);
  }

  /// Enable provider at runtime
  Future<void> enableProvider(String providerId) async {
    final providerConfig = _config.getProvider(providerId);
    if (providerConfig == null) {
      throw PaymentProviderException(
        providerId: providerId,
        message: 'Provider configuration not found',
      );
    }

    if (_providers.containsKey(providerId)) {
      // Already initialized, just mark as enabled
      return;
    }

    // Initialize the provider
    final provider = _createProvider(providerId);
    await provider.initialize(providerConfig);
    _providers[providerId] = provider;

    if (_config.enableLogging) {
      print('Provider enabled: $providerId');
    }
  }

  /// Disable provider at runtime
  Future<void> disableProvider(String providerId) async {
    final provider = _providers.remove(providerId);
    if (provider != null) {
      await provider.dispose();

      if (_config.enableLogging) {
        print('Provider disabled: $providerId');
      }
    }
  }

  /// Dispose all providers and cleanup
  Future<void> dispose() async {
    for (final provider in _providers.values) {
      await provider.dispose();
    }
    _providers.clear();
    _isInitialized = false;
  }
}
