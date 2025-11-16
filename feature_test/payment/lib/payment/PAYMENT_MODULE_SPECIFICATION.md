# Payment Integration Module - Implementation-Ready Specification

**Version**: 1.0.0
**Last Updated**: 2025-11-14
**Status**: Implementation Ready

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Folder Structure](#folder-structure)
4. [Core Interfaces & Contracts](#core-interfaces--contracts)
5. [Service Contracts](#service-contracts)
6. [Data Models](#data-models)
7. [Flow Diagrams](#flow-diagrams)
8. [Configuration System](#configuration-system)
9. [Security & Compliance](#security--compliance)
10. [Testing & QA Plan](#testing--qa-plan)
11. [Implementation Checklist](#implementation-checklist)

---

## Overview

### Purpose
A production-ready, drop-in payment integration module for Flutter applications that supports multiple payment backends and native in-app purchases with unified API.

### Key Features
- **Multiple Payment Providers**: Stripe, PayPal, Razorpay
- **Native IAP**: Google Play Billing, Apple App Store
- **Transaction Types**: One-time payments, subscriptions
- **Receipt Validation**: Server-side and client-side validation
- **Runtime Configuration**: Enable/disable providers at build or runtime
- **Security**: PCI-DSS compliant architecture, secure storage
- **Error Handling**: Comprehensive error handling and retry logic
- **Offline Support**: Transaction queue for offline scenarios

### Design Principles
1. **Provider Abstraction**: Unified API regardless of payment provider
2. **Dependency Injection**: Easy to test and swap implementations
3. **Security First**: No sensitive data in client, secure communication
4. **Extensibility**: Easy to add new payment providers
5. **Fail-Safe**: Graceful degradation, comprehensive error handling

---

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Application Layer                       │
│  (Screens, Widgets using PaymentManager public API)         │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│                   PaymentManager                             │
│  - Provider selection & routing                              │
│  - Transaction orchestration                                 │
│  - Subscription management                                   │
│  - Receipt validation coordination                           │
└─────┬─────────────┬──────────────┬──────────────┬──────────┘
      │             │              │              │
┌─────▼─────┐ ┌────▼────┐ ┌───────▼─────┐ ┌─────▼─────────┐
│  Stripe   │ │ PayPal  │ │  Razorpay   │ │   IAP (G/A)   │
│  Provider │ │Provider │ │  Provider   │ │   Provider    │
└─────┬─────┘ └────┬────┘ └───────┬─────┘ └─────┬─────────┘
      │             │              │              │
      └─────────────┴──────────────┴──────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│              IPaymentProvider Interface                      │
│  - processPayment()                                          │
│  - createSubscription()                                      │
│  - cancelSubscription()                                      │
│  - validateReceipt()                                         │
│  - refundTransaction()                                       │
└──────────────────────────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│                  Support Services                            │
│  - PaymentRepository (local storage)                         │
│  - ReceiptValidator (server communication)                   │
│  - EncryptionService (secure data)                           │
│  - NetworkService (API calls)                                │
│  - AnalyticsService (tracking)                               │
└──────────────────────────────────────────────────────────────┘
```

### Component Responsibilities

#### PaymentManager
- **Single entry point** for all payment operations
- Routes requests to appropriate provider
- Manages provider lifecycle (initialization, disposal)
- Coordinates complex workflows (e.g., subscription with trial)
- Caches transaction history
- Handles provider fallback/retry logic

#### IPaymentProvider (Interface)
- Defines contract all providers must implement
- Ensures consistent behavior across providers
- Enables runtime provider swapping

#### Provider Implementations
- **StripeProvider**: Stripe payment processing
- **PayPalProvider**: PayPal payment processing
- **RazorpayProvider**: Razorpay payment processing
- **GooglePlayBillingProvider**: Google Play in-app purchases
- **AppleIAPProvider**: Apple App Store in-app purchases

#### Support Services
- **PaymentRepository**: Persist transaction history, receipts (Hive/Secure Storage)
- **ReceiptValidator**: Validate receipts with backend server
- **EncryptionService**: Encrypt sensitive payment data
- **NetworkService**: HTTP client for API calls
- **AnalyticsService**: Track payment events

---

## Folder Structure

```
lib/features/payment/
├── payment.dart                          # Public API (exports)
├── README.md                             # Feature documentation
├── PAYMENT_MODULE_SPECIFICATION.md       # This file
├── TESTING_GUIDE.md                      # Testing & QA guide
│
├── models/                               # Data models
│   ├── payment_models.dart               # Re-export all models
│   ├── payment_result.dart               # PaymentResult, PaymentStatus
│   ├── payment_request.dart              # PaymentRequest
│   ├── subscription.dart                 # Subscription, SubscriptionPlan
│   ├── transaction.dart                  # Transaction, TransactionType
│   ├── receipt.dart                      # Receipt, ReceiptData
│   ├── customer.dart                     # Customer, BillingAddress
│   ├── product.dart                      # Product, ProductType, Price
│   └── payment_error.dart                # PaymentError, PaymentErrorCode
│
├── services/                             # Business logic
│   ├── payment_manager.dart              # Main service (orchestrator)
│   ├── receipt_validator.dart            # Receipt validation logic
│   ├── subscription_manager.dart         # Subscription lifecycle
│   ├── transaction_logger.dart           # Transaction logging
│   └── analytics_service.dart            # Payment analytics
│
├── providers/                            # Payment provider implementations
│   ├── base/
│   │   └── payment_provider_interface.dart  # IPaymentProvider
│   ├── stripe/
│   │   ├── stripe_provider.dart          # Stripe implementation
│   │   ├── stripe_config.dart            # Stripe configuration
│   │   └── stripe_models.dart            # Stripe-specific models
│   ├── paypal/
│   │   ├── paypal_provider.dart          # PayPal implementation
│   │   ├── paypal_config.dart            # PayPal configuration
│   │   └── paypal_models.dart            # PayPal-specific models
│   ├── razorpay/
│   │   ├── razorpay_provider.dart        # Razorpay implementation
│   │   ├── razorpay_config.dart          # Razorpay configuration
│   │   └── razorpay_models.dart          # Razorpay-specific models
│   ├── iap/
│   │   ├── google_play_billing_provider.dart  # Google Play Billing
│   │   ├── apple_iap_provider.dart       # Apple IAP
│   │   ├── iap_config.dart               # IAP configuration
│   │   └── iap_models.dart               # IAP-specific models
│   └── mock/
│       └── mock_payment_provider.dart    # Mock for testing
│
├── repository/                           # Data persistence
│   ├── payment_repository.dart           # Main repository
│   ├── transaction_cache.dart            # Transaction caching
│   └── receipt_storage.dart              # Receipt persistence
│
├── config/                               # Configuration
│   ├── payment_config.dart               # Main configuration
│   ├── provider_config.dart              # Provider-specific configs
│   └── environment_config.dart           # Environment-based settings
│
├── utils/                                # Utilities
│   ├── encryption_utils.dart             # Encryption/decryption
│   ├── validation_utils.dart             # Input validation
│   ├── currency_utils.dart               # Currency formatting
│   ├── network_utils.dart                # Network helpers
│   └── payment_logger.dart               # Logging
│
├── constants/                            # Constants
│   ├── payment_constants.dart            # General constants
│   ├── error_messages.dart               # Error message strings
│   └── api_endpoints.dart                # API endpoint URLs
│
├── exceptions/                           # Custom exceptions
│   ├── payment_exceptions.dart           # Payment-specific exceptions
│   ├── provider_exceptions.dart          # Provider-specific exceptions
│   └── validation_exceptions.dart        # Validation exceptions
│
├── ui/                                   # UI components (optional)
│   ├── screens/
│   │   ├── payment_method_selection_screen.dart
│   │   ├── payment_processing_screen.dart
│   │   ├── subscription_management_screen.dart
│   │   └── transaction_history_screen.dart
│   └── widgets/
│       ├── payment_card_widget.dart
│       ├── payment_button.dart
│       ├── subscription_card.dart
│       └── transaction_list_item.dart
│
└── tests/                                # Tests
    ├── unit/
    │   ├── models_test.dart
    │   ├── services_test.dart
    │   ├── providers_test.dart
    │   └── utils_test.dart
    ├── integration/
    │   ├── payment_flow_test.dart
    │   ├── subscription_flow_test.dart
    │   └── iap_flow_test.dart
    ├── widget/
    │   └── ui_test.dart
    └── mocks/
        ├── mock_payment_provider.dart
        ├── mock_repository.dart
        └── mock_services.dart
```

---

## Core Interfaces & Contracts

### IPaymentProvider Interface

```dart
/// Base interface that all payment providers must implement
abstract class IPaymentProvider {
  /// Provider identifier (e.g., 'stripe', 'paypal', 'razorpay', 'google_play', 'apple_iap')
  String get providerId;

  /// Human-readable provider name
  String get providerName;

  /// Whether this provider is currently enabled
  bool get isEnabled;

  /// Supported currencies by this provider
  List<String> get supportedCurrencies;

  /// Supported payment methods (card, wallet, bank_transfer, etc.)
  List<PaymentMethod> get supportedMethods;

  /// Whether provider supports subscriptions
  bool get supportsSubscriptions;

  /// Whether provider supports refunds
  bool get supportsRefunds;

  /// Initialize the provider with configuration
  Future<void> initialize(ProviderConfig config);

  /// Dispose and cleanup resources
  Future<void> dispose();

  /// Process a one-time payment
  Future<PaymentResult> processPayment(PaymentRequest request);

  /// Create a subscription
  Future<SubscriptionResult> createSubscription(SubscriptionRequest request);

  /// Cancel a subscription
  Future<void> cancelSubscription(String subscriptionId, {CancellationReason? reason});

  /// Update subscription (e.g., change plan)
  Future<SubscriptionResult> updateSubscription(
    String subscriptionId,
    SubscriptionUpdate update,
  );

  /// Get subscription details
  Future<Subscription> getSubscription(String subscriptionId);

  /// Validate a receipt/transaction
  Future<ReceiptValidation> validateReceipt(String receiptData);

  /// Refund a transaction
  Future<RefundResult> refundTransaction(String transactionId, {double? amount});

  /// Get transaction history
  Future<List<Transaction>> getTransactionHistory({
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  });

  /// Get transaction details
  Future<Transaction> getTransaction(String transactionId);

  /// Check payment status
  Future<PaymentStatus> checkPaymentStatus(String transactionId);
}
```

### PaymentManager Service

```dart
/// Main orchestration service for all payment operations
class PaymentManager {
  /// Singleton instance
  static PaymentManager? _instance;
  static PaymentManager get instance => _instance!;

  /// Initialize with configuration
  static Future<void> initialize(PaymentConfig config);

  /// Get available payment providers
  List<ProviderInfo> getAvailableProviders();

  /// Process payment with specified or auto-selected provider
  Future<PaymentResult> processPayment(
    PaymentRequest request, {
    String? preferredProviderId,
  });

  /// Create subscription with specified or auto-selected provider
  Future<SubscriptionResult> createSubscription(
    SubscriptionRequest request, {
    String? preferredProviderId,
  });

  /// Get active subscriptions
  Future<List<Subscription>> getActiveSubscriptions();

  /// Cancel subscription
  Future<void> cancelSubscription(
    String subscriptionId, {
    CancellationReason? reason,
  });

  /// Validate receipt
  Future<ReceiptValidation> validateReceipt(
    String receiptData,
    String providerId,
  );

  /// Get transaction history (all providers)
  Future<List<Transaction>> getTransactionHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? providerId,
  });

  /// Refund transaction
  Future<RefundResult> refundTransaction(
    String transactionId,
    String providerId, {
    double? amount,
  });

  /// Get provider by ID
  IPaymentProvider? getProvider(String providerId);

  /// Enable provider at runtime
  Future<void> enableProvider(String providerId);

  /// Disable provider at runtime
  Future<void> disableProvider(String providerId);
}
```

---

## Service Contracts

### ReceiptValidator

```dart
/// Validates payment receipts with backend server
class ReceiptValidator {
  /// Validate receipt with backend
  Future<ReceiptValidation> validateWithServer(
    String receiptData,
    String providerId,
  );

  /// Validate receipt locally (basic checks)
  ReceiptValidation validateLocally(String receiptData);

  /// Cache validated receipt
  Future<void> cacheValidation(ReceiptValidation validation);

  /// Get cached validation
  Future<ReceiptValidation?> getCachedValidation(String receiptId);
}
```

### SubscriptionManager

```dart
/// Manages subscription lifecycle
class SubscriptionManager {
  /// Get all active subscriptions
  Future<List<Subscription>> getActiveSubscriptions();

  /// Check if subscription is active
  Future<bool> isSubscriptionActive(String subscriptionId);

  /// Check if subscription is in grace period
  Future<bool> isInGracePeriod(String subscriptionId);

  /// Get subscription expiry date
  Future<DateTime?> getExpiryDate(String subscriptionId);

  /// Handle subscription renewal
  Future<void> handleRenewal(SubscriptionRenewalEvent event);

  /// Handle subscription cancellation
  Future<void> handleCancellation(SubscriptionCancellationEvent event);

  /// Sync subscriptions with provider
  Future<void> syncSubscriptions(String providerId);
}
```

### PaymentRepository

```dart
/// Persists payment data locally
class PaymentRepository {
  /// Save transaction
  Future<void> saveTransaction(Transaction transaction);

  /// Get transaction by ID
  Future<Transaction?> getTransaction(String transactionId);

  /// Get all transactions
  Future<List<Transaction>> getAllTransactions({
    DateTime? startDate,
    DateTime? endDate,
    String? providerId,
  });

  /// Save receipt
  Future<void> saveReceipt(Receipt receipt);

  /// Get receipt
  Future<Receipt?> getReceipt(String receiptId);

  /// Save subscription
  Future<void> saveSubscription(Subscription subscription);

  /// Get subscription
  Future<Subscription?> getSubscription(String subscriptionId);

  /// Clear all data (GDPR compliance)
  Future<void> clearAllData();

  /// Export data for user (GDPR compliance)
  Future<Map<String, dynamic>> exportUserData();
}
```

---

## Data Models

### PaymentRequest

```dart
class PaymentRequest {
  final String requestId;           // Unique request ID
  final double amount;               // Payment amount
  final String currency;             // ISO currency code (USD, EUR, INR)
  final String description;          // Payment description
  final Customer? customer;          // Customer information
  final Map<String, dynamic>? metadata;  // Additional metadata
  final PaymentMethod? preferredMethod;  // Preferred payment method
  final String? callbackUrl;         // Webhook callback URL
  final bool savePaymentMethod;      // Save for future use
}
```

### PaymentResult

```dart
class PaymentResult {
  final String transactionId;       // Unique transaction ID
  final PaymentStatus status;        // Payment status
  final double amount;               // Paid amount
  final String currency;             // Currency
  final String providerId;           // Provider used
  final DateTime timestamp;          // Transaction timestamp
  final String? receiptUrl;          // Receipt URL
  final String? receiptData;         // Receipt data (for validation)
  final Map<String, dynamic>? metadata;  // Additional data
  final PaymentError? error;         // Error if failed
}
```

### PaymentStatus Enum

```dart
enum PaymentStatus {
  pending,          // Payment initiated, awaiting completion
  processing,       // Payment being processed
  succeeded,        // Payment successful
  failed,           // Payment failed
  canceled,         // Payment canceled by user
  refunded,         // Payment refunded
  partiallyRefunded // Payment partially refunded
}
```

### Subscription

```dart
class Subscription {
  final String subscriptionId;      // Unique subscription ID
  final String customerId;           // Customer ID
  final String planId;               // Subscription plan ID
  final SubscriptionStatus status;   // Current status
  final DateTime startDate;          // Subscription start
  final DateTime? endDate;           // Subscription end (if canceled)
  final DateTime? trialEndDate;      // Trial period end
  final DateTime currentPeriodStart; // Current billing period start
  final DateTime currentPeriodEnd;   // Current billing period end
  final double amount;               // Recurring amount
  final String currency;             // Currency
  final BillingInterval interval;    // Billing frequency
  final String providerId;           // Provider ID
  final bool cancelAtPeriodEnd;      // Cancel at end of period
  final Map<String, dynamic>? metadata;
}
```

### SubscriptionStatus Enum

```dart
enum SubscriptionStatus {
  trialing,         // In trial period
  active,           // Active subscription
  pastDue,          // Payment failed, in grace period
  canceled,         // Canceled by user
  expired,          // Subscription expired
  paused,           // Temporarily paused
}
```

### Transaction

```dart
class Transaction {
  final String transactionId;       // Unique transaction ID
  final TransactionType type;        // Type (payment, refund, subscription)
  final double amount;               // Amount
  final String currency;             // Currency
  final PaymentStatus status;        // Status
  final String providerId;           // Provider used
  final DateTime timestamp;          // Transaction time
  final String? customerId;          // Customer ID
  final String? subscriptionId;      // Subscription ID (if applicable)
  final String? receiptUrl;          // Receipt URL
  final Map<String, dynamic>? metadata;
}
```

### Receipt

```dart
class Receipt {
  final String receiptId;            // Unique receipt ID
  final String transactionId;        // Associated transaction
  final String providerId;           // Provider ID
  final String receiptData;          // Raw receipt data
  final ReceiptStatus status;        // Validation status
  final DateTime createdAt;          // Receipt creation time
  final DateTime? validatedAt;       // Validation time
  final Map<String, dynamic>? validationResult;  // Validation details
}
```

### PaymentError

```dart
class PaymentError {
  final PaymentErrorCode code;       // Error code
  final String message;              // Error message
  final String? providerErrorCode;   // Provider-specific error code
  final String? providerErrorMessage;  // Provider error message
  final bool isRetryable;            // Can retry
  final Map<String, dynamic>? details;  // Additional details
}
```

---

## Flow Diagrams

### One-Time Payment Flow

```
User -> App: Initiate Payment
App -> PaymentManager: processPayment(request)
PaymentManager -> Provider Selection: Select provider (Stripe/PayPal/Razorpay/IAP)

[Provider Initialization]
PaymentManager -> Provider: initialize(config)
Provider -> PaymentManager: Ready

[Payment Processing]
PaymentManager -> Provider: processPayment(request)
Provider -> Payment Gateway: API call with credentials
Payment Gateway -> Provider: Payment response
Provider -> PaymentManager: PaymentResult

[Validation & Storage]
PaymentManager -> ReceiptValidator: validateReceipt(receiptData)
ReceiptValidator -> Backend Server: POST /api/validate-receipt
Backend Server -> ReceiptValidator: Validation result
PaymentManager -> PaymentRepository: saveTransaction(transaction)
PaymentManager -> App: PaymentResult

App -> User: Display success/failure

[Error Handling]
If Provider fails:
  PaymentManager -> Fallback Provider: Retry with alternate provider
  OR
  PaymentManager -> App: PaymentResult(error)
```

### Subscription Creation Flow

```
User -> App: Subscribe to Plan
App -> PaymentManager: createSubscription(request)

[Plan Validation]
PaymentManager -> Subscription Catalog: Validate plan exists
PaymentManager -> Provider Selection: Select provider

[Subscription Setup]
PaymentManager -> Provider: createSubscription(request)
Provider -> Payment Gateway: Create subscription API call

[Trial Period Check]
If trial period:
  Provider -> Payment Gateway: Setup trial
  Payment Gateway -> Provider: Trial started
Else:
  Provider -> Payment Gateway: Charge immediately
  Payment Gateway -> Provider: Payment result

Provider -> PaymentManager: SubscriptionResult

[Storage & Webhooks]
PaymentManager -> SubscriptionManager: Save subscription
PaymentManager -> PaymentRepository: saveSubscription(subscription)
PaymentManager -> Analytics: Track subscription_created
PaymentManager -> Webhook Handler: Setup webhook listener
PaymentManager -> App: SubscriptionResult

App -> User: Display subscription details

[Renewal Cycle - Automated]
Payment Gateway -> Webhook Handler: subscription.renewal (webhook)
Webhook Handler -> SubscriptionManager: handleRenewal(event)
SubscriptionManager -> PaymentRepository: Update subscription
SubscriptionManager -> User: Send renewal notification
```

### Receipt Validation Flow

```
App -> PaymentManager: validateReceipt(receiptData, providerId)

[Local Validation]
PaymentManager -> ReceiptValidator: validateLocally(receiptData)
ReceiptValidator -> PaymentManager: Basic validation result

If basic validation fails:
  PaymentManager -> App: ReceiptValidation(invalid)
  Exit

[Server Validation]
PaymentManager -> ReceiptValidator: validateWithServer(receiptData, providerId)
ReceiptValidator -> Backend API: POST /api/v1/receipts/validate
  Headers: {
    Authorization: Bearer <token>
    Content-Type: application/json
  }
  Body: {
    receipt_data: <encrypted receipt>,
    provider_id: <provider>,
    transaction_id: <id>
  }

Backend API -> Provider Validation Service:
  If Stripe: Verify with Stripe API
  If PayPal: Verify with PayPal API
  If Google: Verify with Google Play Developer API
  If Apple: Verify with Apple App Store API

Provider Validation Service -> Backend API: Validation response
Backend API -> ReceiptValidator: ReceiptValidation result

[Caching]
ReceiptValidator -> PaymentRepository: cacheValidation(result)
ReceiptValidator -> PaymentManager: ReceiptValidation result

PaymentManager -> App: ReceiptValidation result
App -> User: Display validation status
```

### Provider Selection Algorithm

```
Input: PaymentRequest with preferredProviderId (optional)

[Step 1: Check Preferred Provider]
If preferredProviderId specified:
  If provider is enabled and supports request:
    Return provider
  Else:
    Log warning: Preferred provider unavailable
    Continue to auto-selection

[Step 2: Auto-Selection Based on Request]
If request.type == IN_APP_PURCHASE:
  If Platform.isAndroid:
    Return GooglePlayBillingProvider
  Else if Platform.isIOS:
    Return AppleIAPProvider

If request.type == ONE_TIME_PAYMENT or SUBSCRIPTION:
  Filter providers by:
    - isEnabled == true
    - supports currency (request.currency in supportedCurrencies)
    - supports payment method (if preferredMethod specified)

  [Step 3: Priority Selection]
  Sort filtered providers by:
    1. Lowest transaction fees
    2. Fastest processing time
    3. Highest success rate (historical data)
    4. User preference (saved in user settings)

  Return top provider

[Step 4: Fallback]
If no provider available:
  Throw PaymentProviderUnavailableException
```

---

## Configuration System

### Build-Time Configuration

**Option 1: Environment Variables** (Recommended for sensitive keys)

```dart
// lib/features/payment/config/environment_config.dart
class EnvironmentConfig {
  static const String stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue: '',
  );

  static const String paypalClientId = String.fromEnvironment(
    'PAYPAL_CLIENT_ID',
    defaultValue: '',
  );

  static const bool enableStripe = bool.fromEnvironment(
    'ENABLE_STRIPE',
    defaultValue: true,
  );

  static const bool enablePayPal = bool.fromEnvironment(
    'ENABLE_PAYPAL',
    defaultValue: true,
  );

  static const bool enableRazorpay = bool.fromEnvironment(
    'ENABLE_RAZORPAY',
    defaultValue: false,
  );
}

// Build command:
// flutter build apk --dart-define=STRIPE_PUBLISHABLE_KEY=pk_live_xxx --dart-define=ENABLE_STRIPE=true
```

**Option 2: Configuration File** (Easier for non-sensitive settings)

```dart
// assets/config/payment_config.json
{
  "providers": {
    "stripe": {
      "enabled": true,
      "environment": "sandbox"
    },
    "paypal": {
      "enabled": true,
      "environment": "sandbox"
    },
    "razorpay": {
      "enabled": false
    },
    "google_play": {
      "enabled": true
    },
    "apple_iap": {
      "enabled": true
    }
  },
  "features": {
    "enableRefunds": true,
    "enableSubscriptions": true,
    "autoRetry": true,
    "maxRetries": 3
  }
}
```

### Runtime Configuration

```dart
// lib/features/payment/config/payment_config.dart
class PaymentConfig {
  final Map<String, ProviderConfig> providers;
  final bool enableAnalytics;
  final bool enableLogging;
  final String? backendUrl;
  final Duration requestTimeout;

  PaymentConfig({
    required this.providers,
    this.enableAnalytics = true,
    this.enableLogging = true,
    this.backendUrl,
    this.requestTimeout = const Duration(seconds: 30),
  });

  /// Load from JSON file
  static Future<PaymentConfig> fromAsset(String path) async {
    final jsonString = await rootBundle.loadString(path);
    final json = jsonDecode(jsonString);
    return PaymentConfig.fromJson(json);
  }

  /// Load from remote config (Firebase Remote Config, etc.)
  static Future<PaymentConfig> fromRemoteConfig() async {
    // Fetch from Firebase Remote Config or backend API
    // This allows enabling/disabling providers without app update
  }
}

// Usage in main.dart:
await PaymentManager.initialize(
  await PaymentConfig.fromAsset('assets/config/payment_config.json'),
);

// Enable/disable provider at runtime:
await PaymentManager.instance.disableProvider('stripe');
await PaymentManager.instance.enableProvider('paypal');
```

### Provider-Specific Configuration

```dart
// lib/features/payment/config/provider_config.dart
abstract class ProviderConfig {
  final String providerId;
  final bool enabled;
  final PaymentEnvironment environment;

  ProviderConfig({
    required this.providerId,
    required this.enabled,
    required this.environment,
  });
}

class StripeConfig extends ProviderConfig {
  final String publishableKey;
  final String? merchantId;
  final bool enableApplePay;
  final bool enableGooglePay;

  StripeConfig({
    required this.publishableKey,
    this.merchantId,
    this.enableApplePay = true,
    this.enableGooglePay = true,
    required PaymentEnvironment environment,
    bool enabled = true,
  }) : super(
    providerId: 'stripe',
    enabled: enabled,
    environment: environment,
  );
}

class PayPalConfig extends ProviderConfig {
  final String clientId;
  final String returnUrl;
  final String cancelUrl;

  PayPalConfig({
    required this.clientId,
    required this.returnUrl,
    required this.cancelUrl,
    required PaymentEnvironment environment,
    bool enabled = true,
  }) : super(
    providerId: 'paypal',
    enabled: enabled,
    environment: environment,
  );
}

enum PaymentEnvironment {
  production,
  sandbox,
  development,
}
```

---

## Security & Compliance

### PCI-DSS Compliance

**Critical Security Rules:**

1. **Never Store Card Data on Client**
   - Use tokenization (Stripe, PayPal tokens)
   - Card data only exists in memory during input
   - Immediately clear sensitive data after use

2. **Secure Communication**
   ```dart
   // All API calls must use HTTPS
   // Certificate pinning recommended
   class NetworkService {
     static final dio = Dio(
       BaseOptions(
         baseUrl: 'https://api.payment.com',
         connectTimeout: Duration(seconds: 30),
         receiveTimeout: Duration(seconds: 30),
         headers: {
           'Content-Type': 'application/json',
         },
       ),
     )..interceptors.add(CertificatePinningInterceptor());
   }
   ```

3. **Encryption at Rest**
   ```dart
   // Use flutter_secure_storage for sensitive data
   class EncryptionService {
     final _storage = FlutterSecureStorage();

     Future<void> saveSecurely(String key, String value) async {
       await _storage.write(key: key, value: value);
     }

     Future<String?> readSecurely(String key) async {
       return await _storage.read(key: key);
     }
   }
   ```

### Data Privacy (GDPR/CCPA)

```dart
// PaymentRepository must implement data export & deletion
class PaymentRepository {
  /// Export all user payment data (GDPR Article 15)
  Future<Map<String, dynamic>> exportUserData(String userId) async {
    return {
      'transactions': await getAllTransactions(userId: userId),
      'subscriptions': await getSubscriptions(userId: userId),
      'payment_methods': await getPaymentMethods(userId: userId),
      'exported_at': DateTime.now().toIso8601String(),
    };
  }

  /// Delete all user payment data (GDPR Article 17)
  Future<void> deleteUserData(String userId) async {
    await _deleteTransactions(userId);
    await _deleteSubscriptions(userId);
    await _deletePaymentMethods(userId);
    await _deleteReceipts(userId);

    // Log deletion for compliance
    await _logDataDeletion(userId, DateTime.now());
  }
}
```

### Fraud Prevention

```dart
class FraudDetectionService {
  /// Check for suspicious patterns
  Future<FraudCheckResult> checkTransaction(PaymentRequest request) async {
    final checks = [
      _checkVelocity(request),          // Too many transactions
      _checkAmount(request),             // Unusual amount
      _checkLocation(request),           // Location mismatch
      _checkDevice(request),             // Device fingerprint
    ];

    final results = await Future.wait(checks);

    if (results.any((r) => r.isHighRisk)) {
      return FraudCheckResult.blocked;
    } else if (results.any((r) => r.isMediumRisk)) {
      return FraudCheckResult.requiresVerification;
    }

    return FraudCheckResult.approved;
  }
}
```

### Receipt Validation Security

```dart
// Server-side receipt validation endpoint
// POST /api/v1/receipts/validate
//
// Security measures:
// 1. Authentication required (JWT token)
// 2. Rate limiting (10 requests/minute per user)
// 3. Receipt data encrypted in transit
// 4. Validate receipt signature
// 5. Check receipt hasn't been used before (replay attack prevention)
// 6. Verify receipt timestamp (prevent old receipt reuse)

class ReceiptValidationRequest {
  final String receiptData;        // Encrypted receipt
  final String providerId;         // Provider identifier
  final String transactionId;      // Transaction ID
  final String userId;             // User ID
  final String deviceId;           // Device identifier
  final DateTime timestamp;        // Request timestamp
  final String signature;          // HMAC signature
}

// Signature calculation:
// HMAC-SHA256(receiptData + providerId + transactionId + userId + timestamp, secret)
```

---

## Testing & QA Plan

### Unit Tests

**Models Tests** (`tests/unit/models_test.dart`)
```dart
testWidgets('PaymentRequest validation', (tester) async {
  // Test valid request
  final validRequest = PaymentRequest(
    amount: 99.99,
    currency: 'USD',
    description: 'Test payment',
  );
  expect(validRequest.isValid, true);

  // Test invalid amount
  expect(
    () => PaymentRequest(amount: -1, currency: 'USD'),
    throwsA(isA<ValidationException>()),
  );

  // Test invalid currency
  expect(
    () => PaymentRequest(amount: 10, currency: 'INVALID'),
    throwsA(isA<ValidationException>()),
  );
});
```

**Provider Tests** (`tests/unit/providers_test.dart`)
```dart
test('StripeProvider processes payment successfully', () async {
  final mockStripe = MockStripeSDK();
  final provider = StripeProvider(mockStripe);

  when(mockStripe.confirmPayment(any))
    .thenAnswer((_) async => StripePaymentResult(success: true));

  final result = await provider.processPayment(PaymentRequest(
    amount: 50.0,
    currency: 'USD',
  ));

  expect(result.status, PaymentStatus.succeeded);
  verify(mockStripe.confirmPayment(any)).called(1);
});

test('Provider fallback on failure', () async {
  final mockProvider1 = MockPaymentProvider();
  final mockProvider2 = MockPaymentProvider();

  when(mockProvider1.processPayment(any))
    .thenThrow(PaymentException('Provider unavailable'));
  when(mockProvider2.processPayment(any))
    .thenAnswer((_) async => PaymentResult.success());

  final manager = PaymentManager([mockProvider1, mockProvider2]);
  final result = await manager.processPayment(PaymentRequest(...));

  expect(result.status, PaymentStatus.succeeded);
  expect(result.providerId, mockProvider2.providerId);
});
```

### Integration Tests

**Payment Flow Test** (`tests/integration/payment_flow_test.dart`)
```dart
testWidgets('Complete payment flow - Stripe', (tester) async {
  // 1. Initialize payment system
  await PaymentManager.initialize(testConfig);

  // 2. Create payment request
  final request = PaymentRequest(
    amount: 25.99,
    currency: 'USD',
    description: 'Test product',
  );

  // 3. Process payment
  final result = await PaymentManager.instance.processPayment(
    request,
    preferredProviderId: 'stripe',
  );

  // 4. Verify result
  expect(result.status, PaymentStatus.succeeded);
  expect(result.amount, 25.99);
  expect(result.transactionId, isNotEmpty);

  // 5. Verify transaction saved
  final transaction = await PaymentRepository.instance
    .getTransaction(result.transactionId);
  expect(transaction, isNotNull);
  expect(transaction!.status, PaymentStatus.succeeded);

  // 6. Verify receipt validation
  final validation = await PaymentManager.instance
    .validateReceipt(result.receiptData!, 'stripe');
  expect(validation.isValid, true);
});
```

**Subscription Flow Test** (`tests/integration/subscription_flow_test.dart`)
```dart
testWidgets('Complete subscription lifecycle', (tester) async {
  // 1. Create subscription
  final subResult = await PaymentManager.instance.createSubscription(
    SubscriptionRequest(
      planId: 'monthly_premium',
      customerId: 'test_user_123',
      trialDays: 7,
    ),
  );

  expect(subResult.subscription.status, SubscriptionStatus.trialing);

  // 2. Check subscription is active
  final isActive = await SubscriptionManager.instance
    .isSubscriptionActive(subResult.subscription.subscriptionId);
  expect(isActive, true);

  // 3. Update subscription
  await PaymentManager.instance.updateSubscription(
    subResult.subscription.subscriptionId,
    SubscriptionUpdate(planId: 'yearly_premium'),
  );

  // 4. Cancel subscription
  await PaymentManager.instance.cancelSubscription(
    subResult.subscription.subscriptionId,
    reason: CancellationReason.userRequested,
  );

  // 5. Verify cancellation
  final subscription = await SubscriptionManager.instance
    .getSubscription(subResult.subscription.subscriptionId);
  expect(subscription.status, SubscriptionStatus.canceled);
});
```

### Widget Tests

**Payment UI Tests** (`tests/widget/ui_test.dart`)
```dart
testWidgets('Payment method selection screen', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: PaymentMethodSelectionScreen()),
  );

  // Verify providers shown
  expect(find.text('Stripe'), findsOneWidget);
  expect(find.text('PayPal'), findsOneWidget);
  expect(find.text('Google Pay'), findsOneWidget);

  // Select provider
  await tester.tap(find.text('Stripe'));
  await tester.pumpAndSettle();

  // Verify selection
  expect(find.byIcon(Icons.check), findsOneWidget);
});
```

### End-to-End Tests

**Sandbox Testing Checklist:**

1. **Stripe Sandbox**
   - Test card: `4242 4242 4242 4242` (Success)
   - Test card: `4000 0000 0000 0002` (Decline)
   - Test 3D Secure card: `4000 0025 0000 3155`
   - Test subscription creation/cancellation
   - Test refund flow

2. **PayPal Sandbox**
   - Create sandbox buyer/seller accounts
   - Test checkout flow
   - Test subscription billing
   - Test refund processing

3. **Razorpay Test Mode**
   - Use test API keys
   - Test INR transactions
   - Test UPI, cards, netbanking
   - Test webhook delivery

4. **Google Play Billing Test**
   - Use test SKUs: `android.test.purchased`, `android.test.canceled`
   - Test consumable purchases
   - Test non-consumable purchases
   - Test subscription management
   - Test license testing with test accounts

5. **Apple IAP Sandbox**
   - Create sandbox tester accounts
   - Test auto-renewable subscriptions
   - Test consumable/non-consumable products
   - Test receipt validation

### Performance Testing

```dart
// Test payment processing performance
test('Payment processing under 3 seconds', () async {
  final stopwatch = Stopwatch()..start();

  final result = await PaymentManager.instance.processPayment(
    PaymentRequest(amount: 10.0, currency: 'USD'),
  );

  stopwatch.stop();

  expect(result.status, PaymentStatus.succeeded);
  expect(stopwatch.elapsedMilliseconds, lessThan(3000));
});

// Test concurrent transactions
test('Handle 10 concurrent transactions', () async {
  final requests = List.generate(
    10,
    (i) => PaymentRequest(amount: i + 1.0, currency: 'USD'),
  );

  final results = await Future.wait(
    requests.map((r) => PaymentManager.instance.processPayment(r)),
  );

  expect(results.length, 10);
  expect(
    results.every((r) => r.status == PaymentStatus.succeeded),
    true,
  );
});
```

### QA Test Plan

**Manual Testing Scenarios:**

1. **Happy Path Tests**
   - ✅ Successful one-time payment (each provider)
   - ✅ Successful subscription creation
   - ✅ Successful subscription cancellation
   - ✅ Successful refund

2. **Error Handling Tests**
   - ✅ Declined card/payment
   - ✅ Network timeout
   - ✅ Invalid API keys
   - ✅ Insufficient funds
   - ✅ Expired card
   - ✅ Provider service outage

3. **Edge Cases**
   - ✅ Payment with $0.01 (minimum amount)
   - ✅ Payment with large amount ($999,999.99)
   - ✅ Rapid successive payments
   - ✅ Payment while offline (should queue)
   - ✅ Payment with special characters in description
   - ✅ Multiple subscriptions per user
   - ✅ Subscription upgrade/downgrade

4. **Security Tests**
   - ✅ Invalid API keys rejected
   - ✅ Expired tokens rejected
   - ✅ Receipt validation detects fake receipts
   - ✅ Man-in-the-middle attack prevention (cert pinning)
   - ✅ Sensitive data not logged
   - ✅ PCI-DSS compliance (no card data stored)

5. **Platform-Specific Tests**
   - ✅ iOS: Apple Pay integration
   - ✅ iOS: Apple IAP flow
   - ✅ Android: Google Pay integration
   - ✅ Android: Google Play Billing flow
   - ✅ Web: Stripe web checkout

6. **Configuration Tests**
   - ✅ Disable provider at build time
   - ✅ Disable provider at runtime
   - ✅ Switch between sandbox/production
   - ✅ Remote config updates

---

## Implementation Checklist

### Phase 1: Foundation (Week 1)
- [ ] Create folder structure
- [ ] Define core interfaces (`IPaymentProvider`)
- [ ] Implement data models (all models)
- [ ] Implement exceptions
- [ ] Setup configuration system
- [ ] Create PaymentRepository (with Hive)
- [ ] Implement encryption utilities

### Phase 2: Core Services (Week 2)
- [ ] Implement PaymentManager
- [ ] Implement SubscriptionManager
- [ ] Implement ReceiptValidator
- [ ] Implement TransactionLogger
- [ ] Create mock payment provider for testing

### Phase 3: Payment Providers (Week 3-4)
- [ ] Stripe provider implementation
  - [ ] One-time payments
  - [ ] Subscriptions
  - [ ] Refunds
  - [ ] Apple Pay / Google Pay
- [ ] PayPal provider implementation
  - [ ] One-time payments
  - [ ] Subscriptions
- [ ] Razorpay provider implementation
  - [ ] One-time payments
  - [ ] Subscriptions
  - [ ] Indian payment methods

### Phase 4: In-App Purchases (Week 5)
- [ ] Google Play Billing provider
  - [ ] Consumable products
  - [ ] Non-consumable products
  - [ ] Subscriptions
  - [ ] Receipt validation
- [ ] Apple IAP provider
  - [ ] Consumable products
  - [ ] Non-consumable products
  - [ ] Auto-renewable subscriptions
  - [ ] Receipt validation (App Store Server API)

### Phase 5: UI Components (Week 6)
- [ ] Payment method selection screen
- [ ] Payment processing screen
- [ ] Subscription management screen
- [ ] Transaction history screen
- [ ] Payment card widget
- [ ] Subscription card widget

### Phase 6: Testing (Week 7)
- [ ] Unit tests (80%+ coverage)
- [ ] Integration tests
- [ ] Widget tests
- [ ] Sandbox testing (all providers)
- [ ] Performance testing
- [ ] Security audit

### Phase 7: Documentation & Deployment (Week 8)
- [ ] Complete README.md
- [ ] Complete TESTING_GUIDE.md
- [ ] Create example app
- [ ] Security compliance documentation
- [ ] API documentation
- [ ] Migration guide (for existing apps)
- [ ] Release v1.0.0

---

## Dependencies Required

Add to `pubspec.yaml`:

```yaml
dependencies:
  # Payment providers
  flutter_stripe: ^10.0.0              # Stripe SDK
  flutter_paypal_payment: ^1.0.6       # PayPal SDK
  razorpay_flutter: ^1.3.6             # Razorpay SDK

  # In-app purchases
  in_app_purchase: ^3.1.11             # Google Play & Apple IAP
  in_app_purchase_android: ^0.3.0      # Android-specific
  in_app_purchase_storekit: ^0.3.6    # iOS-specific

  # Storage & security
  flutter_secure_storage: ^9.0.0       # Secure storage
  hive: ^2.2.3                         # Local database
  hive_flutter: ^1.1.0                 # Hive Flutter support
  encrypt: ^5.0.3                      # Encryption

  # Networking
  http: ^1.1.0                         # HTTP client
  dio: ^5.4.0                          # Advanced HTTP

  # Utilities
  uuid: ^4.2.1                         # UUID generation
  intl: ^0.18.1                        # Currency formatting
  connectivity_plus: ^5.0.2            # Network connectivity

  # State management (already in project)
  flutter_riverpod: ^2.4.9

dev_dependencies:
  # Testing
  mockito: ^5.4.4                      # Mocking
  build_runner: ^2.4.6                 # Code generation
  hive_generator: ^2.0.1               # Hive adapters
```

---

## Next Steps

1. **Review & Approve Specification**
   - Review this document with stakeholders
   - Clarify any ambiguities
   - Approve architecture and approach

2. **Setup Development Environment**
   - Create provider accounts (Stripe, PayPal, Razorpay)
   - Setup sandbox/test environments
   - Obtain test API keys

3. **Begin Implementation**
   - Follow implementation checklist
   - Start with Phase 1 (Foundation)
   - Implement incrementally with tests

4. **Integration Testing**
   - Test with real sandbox environments
   - Validate all flows end-to-end
   - Performance testing

5. **Production Deployment**
   - Security audit
   - Compliance verification (PCI-DSS, GDPR)
   - Gradual rollout with monitoring

---

**Document Status**: Ready for Implementation
**Estimated Implementation Time**: 8 weeks (1 developer)
**Complexity**: High
**Dependencies**: External SDKs, Backend API (for receipt validation)
