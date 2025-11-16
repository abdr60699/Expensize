
# Payment Integration Module

**Version**: 1.0.0
**Status**: Production Ready
**Last Updated**: 2025-11-14

A comprehensive, production-ready payment integration module for Flutter applications that supports multiple payment backends (Stripe, PayPal, Razorpay) and native in-app purchases (Google Play Billing / Apple IAP).

---

## Features

✅ **Multiple Payment Providers**
- Stripe (credit cards, Apple Pay, Google Pay)
- PayPal (web checkout, subscriptions)
- Razorpay (Indian payment methods - UPI, cards, netbanking)

✅ **Native In-App Purchases**
- Google Play Billing (consumables, non-consumables, subscriptions)
- Apple App Store IAP (auto-renewable subscriptions, one-time purchases)

✅ **Transaction Types**
- One-time payments
- Recurring subscriptions
- Subscription management (cancel, update, pause)

✅ **Robust Features**
- Server-side receipt validation
- Secure local storage (encrypted)
- Offline transaction queue
- Comprehensive error handling
- Retry logic with exponential backoff

✅ **Flexible Configuration**
- Enable/disable providers at build time or runtime
- Environment-based configuration (sandbox/production)
- Remote config support (Firebase Remote Config compatible)

✅ **Security & Compliance**
- PCI-DSS compliant architecture
- No card data stored on client
- HTTPS with certificate pinning
- GDPR/CCPA data export and deletion

---

## Quick Start

### 1. Installation

Add to your `pubspec.yaml`:

```yaml
dependencies:
  # Payment providers (add as needed)
  flutter_stripe: ^10.0.0              # For Stripe
  flutter_paypal_payment: ^1.0.6       # For PayPal
  razorpay_flutter: ^1.3.6             # For Razorpay
  in_app_purchase: ^3.1.11             # For IAP (Google/Apple)

  # Required dependencies (already in project)
  flutter_secure_storage: ^9.0.0
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  http: ^1.1.0
```

### 2. Configuration

Create `assets/config/payment_config.json`:

```json
{
  "providers": {
    "stripe": {
      "enabled": true,
      "environment": "sandbox",
      "publishableKey": "pk_test_YOUR_KEY",
      "enableApplePay": true,
      "enableGooglePay": true
    },
    "paypal": {
      "enabled": true,
      "environment": "sandbox",
      "clientId": "YOUR_PAYPAL_CLIENT_ID",
      "returnUrl": "myapp://payment/success",
      "cancelUrl": "myapp://payment/cancel"
    },
    "razorpay": {
      "enabled": false,
      "environment": "sandbox",
      "keyId": "YOUR_RAZORPAY_KEY"
    },
    "google_play": {
      "enabled": true,
      "autoConsume": true
    },
    "apple_iap": {
      "enabled": true,
      "autoFinishTransactions": true
    }
  },
  "backendUrl": "https://api.yourapp.com",
  "enableAnalytics": true,
  "enableLogging": true,
  "isTestMode": true
}
```

### 3. Initialize

In your `main.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:reuablewidgets/features/payment/payment.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load payment configuration
  final config = await PaymentConfig.fromAsset(
    'assets/config/payment_config.json',
  );

  // Initialize payment manager
  await PaymentManager.initialize(config);

  runApp(MyApp());
}
```

### 4. Process a Payment

```dart
import 'package:reuablewidgets/features/payment/payment.dart';

Future<void> makePayment() async {
  try {
    final request = PaymentRequest(
      amount: 29.99,
      currency: 'USD',
      description: 'Premium Subscription - 1 Month',
      customer: Customer(
        email: 'user@example.com',
        name: 'John Doe',
      ),
    );

    final result = await PaymentManager.instance.processPayment(
      request,
      preferredProviderId: 'stripe', // Optional: auto-selects if not specified
    );

    if (result.isSuccess) {
      print('Payment successful! Transaction ID: ${result.transactionId}');
      print('Receipt: ${result.receiptUrl}');
    } else {
      print('Payment failed: ${result.error?.message}');
    }
  } on PaymentException catch (e) {
    print('Payment error: ${e.message}');
  }
}
```

### 5. Create a Subscription

```dart
Future<void> createSubscription() async {
  try {
    final request = SubscriptionRequest(
      planId: 'monthly_premium',
      customerId: 'user_123',
      trialDays: 7, // 7-day free trial
    );

    final result = await PaymentManager.instance.createSubscription(
      request,
      preferredProviderId: 'stripe',
    );

    if (result.success) {
      print('Subscription created: ${result.subscription.subscriptionId}');
      print('Status: ${result.subscription.status}');
      print('Next billing: ${result.subscription.nextBillingDate}');
    }
  } on PaymentException catch (e) {
    print('Subscription error: ${e.message}');
  }
}
```

### 6. In-App Purchase (Google Play / Apple)

```dart
Future<void> purchaseProduct() async {
  try {
    // For Android, use 'google_play'
    // For iOS, use 'apple_iap'
    final providerId = Platform.isAndroid ? 'google_play' : 'apple_iap';

    final request = PaymentRequest(
      amount: 0, // Amount determined by store
      currency: 'USD',
      description: 'Premium Upgrade',
      orderId: 'com.yourapp.premium',
      preferredMethod: PaymentMethod.inAppPurchase,
    );

    final result = await PaymentManager.instance.processPayment(
      request,
      preferredProviderId: providerId,
    );

    if (result.isSuccess) {
      // Validate receipt
      final validation = await PaymentManager.instance.validateReceipt(
        result.receiptData!,
        providerId,
      );

      if (validation.isValid) {
        print('Purchase validated successfully!');
        // Grant access to premium features
      }
    }
  } on PaymentException catch (e) {
    print('Purchase error: ${e.message}');
  }
}
```

---

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│               Application Layer                          │
│         (Your UI/Business Logic)                         │
└───────────────────┬─────────────────────────────────────┘
                    │
┌───────────────────▼─────────────────────────────────────┐
│              PaymentManager                              │
│  • Provider selection & routing                          │
│  • Transaction orchestration                             │
│  • Error handling & retry logic                          │
└──┬─────────┬──────────┬──────────┬──────────────────────┘
   │         │          │          │
┌──▼──┐  ┌──▼──┐  ┌───▼───┐  ┌───▼──────┐
│Stripe│  │PayPal│  │Razorpay│  │Google/  │
│      │  │      │  │        │  │Apple IAP│
└──────┘  └──────┘  └────────┘  └──────────┘
          │
┌─────────▼───────────────────────────────────────────────┐
│           IPaymentProvider Interface                     │
│  • processPayment()                                      │
│  • createSubscription()                                  │
│  • validateReceipt()                                     │
│  • refundTransaction()                                   │
└──────────────────────────────────────────────────────────┘
```

---

## Configuration Options

### Build-Time Configuration

**Using Environment Variables** (for CI/CD):

```bash
flutter build apk \
  --dart-define=STRIPE_KEY=pk_live_xxx \
  --dart-define=ENABLE_STRIPE=true \
  --dart-define=ENABLE_PAYPAL=true
```

```dart
// In code
const stripeKey = String.fromEnvironment('STRIPE_KEY');
const enableStripe = bool.fromEnvironment('ENABLE_STRIPE', defaultValue: true);
```

### Runtime Configuration

**Enable/Disable Providers Dynamically**:

```dart
// Disable a provider
await PaymentManager.instance.disableProvider('paypal');

// Enable a provider
await PaymentManager.instance.enableProvider('stripe');

// Get available providers
final providers = PaymentManager.instance.getAvailableProviders();
for (final provider in providers) {
  print('${provider.providerName}: ${provider.isEnabled}');
}
```

**Remote Configuration** (Firebase Remote Config):

```dart
// Fetch config from remote
final remoteConfig = FirebaseRemoteConfig.instance;
await remoteConfig.fetchAndActivate();

final enableStripe = remoteConfig.getBool('enable_stripe');
final enablePayPal = remoteConfig.getBool('enable_paypal');

// Update configuration
if (!enableStripe) {
  await PaymentManager.instance.disableProvider('stripe');
}
```

---

## Error Handling

The module provides comprehensive error types:

```dart
try {
  final result = await PaymentManager.instance.processPayment(request);
} on PaymentDeclinedException catch (e) {
  // Card declined
  showError('Your card was declined. Please try another payment method.');
} on PaymentNetworkException catch (e) {
  // Network error - can retry
  showError('Network error. Please check your connection and try again.');
} on PaymentValidationException catch (e) {
  // Invalid request data
  showError('Invalid payment details: ${e.message}');
} on UserCanceledPaymentException catch (e) {
  // User canceled
  showInfo('Payment canceled');
} on PaymentException catch (e) {
  // Generic error
  showError('Payment failed: ${e.message}');
}
```

---

## Security Best Practices

### 1. Never Store Card Data
```dart
// ❌ WRONG - Never do this
final cardNumber = '4242424242424242';
await saveToLocalStorage(cardNumber);

// ✅ CORRECT - Use tokenization
final paymentMethod = await provider.createPaymentMethod(cardDetails);
// Only store payment method ID, never raw card data
```

### 2. Validate Receipts Server-Side
```dart
// Client requests receipt validation
final validation = await PaymentManager.instance.validateReceipt(
  receiptData,
  providerId,
);

// Your backend should also validate with provider API
// POST /api/v1/receipts/validate
// {
//   "receiptData": "...",
//   "providerId": "stripe",
//   "userId": "user_123"
// }
```

### 3. Use HTTPS and Certificate Pinning
```dart
// Configure HTTP client with certificate pinning
final dio = Dio()
  ..interceptors.add(CertificatePinningInterceptor(
    allowedSHAFingerprints: [
      'sha256/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
    ],
  ));
```

### 4. Implement Rate Limiting
```dart
// Prevent brute-force attacks
final rateLimiter = RateLimiter(
  maxAttempts: 5,
  duration: Duration(minutes: 15),
);

if (await rateLimiter.isLimited(userId)) {
  throw PaymentException(
    message: 'Too many payment attempts. Please try again later.',
    code: PaymentErrorCode.rateLimitExceeded,
  );
}
```

---

## Testing

### Unit Tests

```dart
test('Payment with valid request succeeds', () async {
  final provider = MockPaymentProvider();
  await provider.initialize(MockConfig());

  final request = PaymentRequest(
    amount: 10.0,
    currency: 'USD',
    description: 'Test payment',
  );

  final result = await provider.processPayment(request);

  expect(result.status, PaymentStatus.succeeded);
  expect(result.amount, 10.0);
});
```

### Integration Tests

```dart
testWidgets('Complete payment flow', (tester) async {
  await PaymentManager.initialize(testConfig);

  final request = PaymentRequest(
    amount: 25.99,
    currency: 'USD',
    description: 'Test product',
  );

  final result = await PaymentManager.instance.processPayment(request);

  expect(result.isSuccess, true);
  expect(result.transactionId, isNotEmpty);
});
```

### Sandbox Testing

**Stripe Test Cards**:
- Success: `4242 4242 4242 4242`
- Decline: `4000 0000 0000 0002`
- 3D Secure: `4000 0025 0000 3155`

**PayPal Sandbox**:
- Create test accounts at https://developer.paypal.com/

**Google Play Test Accounts**:
- Use license testing with test accounts in Play Console

**Apple IAP Sandbox**:
- Create sandbox testers in App Store Connect

---

## Transaction History

```dart
// Get all transactions
final transactions = await PaymentManager.instance.getTransactionHistory();

// Get transactions for specific provider
final stripeTransactions = await PaymentManager.instance.getTransactionHistory(
  providerId: 'stripe',
);

// Get transactions in date range
final recentTransactions = await PaymentManager.instance.getTransactionHistory(
  startDate: DateTime.now().subtract(Duration(days: 30)),
  endDate: DateTime.now(),
  limit: 50,
);

// Display transactions
for (final transaction in transactions) {
  print('${transaction.timestamp}: ${transaction.displayAmount} - ${transaction.status}');
}
```

---

## Subscription Management

```dart
// Get active subscriptions
final subscriptions = await subscriptionManager.getActiveSubscriptions();

// Check if subscription is active
final isActive = await subscriptionManager.isSubscriptionActive(subscriptionId);

// Get subscription details
final subscription = await PaymentManager.instance.getProvider('stripe')
  .getSubscription(subscriptionId);

print('Status: ${subscription.status}');
print('Next billing: ${subscription.nextBillingDate}');
print('Days remaining: ${subscription.daysRemaining}');

// Cancel subscription
await PaymentManager.instance.cancelSubscription(
  subscriptionId,
  'stripe',
  reason: CancellationReason.userRequested,
);

// Update subscription (change plan)
await provider.updateSubscription(
  subscriptionId,
  SubscriptionUpdate(planId: 'yearly_premium'),
);
```

---

## Refunds

```dart
// Full refund
final refundResult = await PaymentManager.instance.refundTransaction(
  transactionId,
  'stripe',
);

// Partial refund
final partialRefund = await PaymentManager.instance.refundTransaction(
  transactionId,
  'stripe',
  amount: 10.0, // Refund $10 of the original amount
);

if (refundResult.success) {
  print('Refund processed: ${refundResult.refundTransaction.transactionId}');
} else {
  print('Refund failed: ${refundResult.error}');
}
```

---

## GDPR Compliance

```dart
// Export user payment data
final userData = await paymentRepository.exportUserData(userId);
// Returns JSON with all transactions, subscriptions, payment methods

// Delete user payment data
await paymentRepository.deleteUserData(userId);
// Permanently deletes all user payment data
```

---

## Troubleshooting

### Provider Not Initialized
```
Error: PaymentProviderException: Provider not initialized
```
**Solution**: Ensure you call `PaymentManager.initialize(config)` before using the module.

### Currency Not Supported
```
Error: CurrencyNotSupportedException: Currency INR is not supported by provider stripe
```
**Solution**: Use Razorpay for INR transactions, or check provider's supported currencies.

### Receipt Validation Failed
```
Error: ReceiptValidation(isValid: false)
```
**Solution**:
1. Check receipt data is correctly encoded
2. Ensure backend validation server is running
3. Verify API keys are correct
4. Check if receipt has already been used (duplicate)

---

## API Reference

See [PAYMENT_MODULE_SPECIFICATION.md](PAYMENT_MODULE_SPECIFICATION.md) for complete API documentation.

---

## Support & Contributing

- **Issues**: Report bugs or request features
- **Documentation**: [Full specification](PAYMENT_MODULE_SPECIFICATION.md)
- **Testing Guide**: [Testing documentation](TESTING_GUIDE.md)

---

## License

This payment module is part of the Reusable Widgets Flutter project.

---

## Changelog

### v1.0.0 (2025-11-14)
- Initial release
- Support for Stripe, PayPal, Razorpay
- Google Play Billing and Apple IAP support
- Subscription management
- Receipt validation
- Comprehensive error handling
