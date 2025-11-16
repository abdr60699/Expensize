
# Payment Module Testing Guide

**Version**: 1.0.0
**Last Updated**: 2025-11-14

This guide covers testing strategies for the Payment Integration Module.

---

## Table of Contents

1. [Unit Testing](#unit-testing)
2. [Integration Testing](#integration-testing)
3. [Widget Testing](#widget-testing)
4. [End-to-End Testing](#end-to-end-testing)
5. [Sandbox Testing](#sandbox-testing)
6. [Performance Testing](#performance-testing)
7. [Security Testing](#security-testing)

---

## Unit Testing

### Testing Models

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:reuablewidgets/features/payment/payment.dart';

void main() {
  group('PaymentRequest', () {
    test('validates correct request', () {
      final request = PaymentRequest(
        amount: 10.0,
        currency: 'USD',
        description: 'Test payment',
      );

      expect(request.isValid, true);
      expect(request.validationError, null);
    });

    test('rejects invalid amount', () {
      final request = PaymentRequest(
        amount: -1.0,
        currency: 'USD',
        description: 'Test',
      );

      expect(request.isValid, false);
      expect(request.validationError, isNotNull);
    });

    test('rejects invalid currency', () {
      final request = PaymentRequest(
        amount: 10.0,
        currency: 'INVALID',
        description: 'Test',
      );

      expect(request.isValid, false);
    });

    test('generates unique request IDs', () {
      final request1 = PaymentRequest(
        amount: 10.0,
        currency: 'USD',
        description: 'Test',
      );

      final request2 = PaymentRequest(
        amount: 10.0,
        currency: 'USD',
        description: 'Test',
      );

      expect(request1.requestId, isNot(equals(request2.requestId)));
    });

    test('serializes to JSON correctly', () {
      final request = PaymentRequest(
        amount: 25.99,
        currency: 'USD',
        description: 'Premium subscription',
      );

      final json = request.toJson();

      expect(json['amount'], 25.99);
      expect(json['currency'], 'USD');
      expect(json['description'], 'Premium subscription');
    });

    test('deserializes from JSON correctly', () {
      final json = {
        'requestId': 'req_123',
        'amount': 29.99,
        'currency': 'EUR',
        'description': 'Test payment',
      };

      final request = PaymentRequest.fromJson(json);

      expect(request.requestId, 'req_123');
      expect(request.amount, 29.99);
      expect(request.currency, 'EUR');
      expect(request.description, 'Test payment');
    });
  });

  group('PaymentResult', () {
    test('creates successful result', () {
      final result = PaymentResult.success(
        transactionId: 'txn_123',
        amount: 10.0,
        currency: 'USD',
        providerId: 'stripe',
      );

      expect(result.isSuccess, true);
      expect(result.isFailed, false);
      expect(result.status, PaymentStatus.succeeded);
    });

    test('creates failed result', () {
      final error = PaymentError.cardDeclined();
      final result = PaymentResult.failed(
        transactionId: 'txn_123',
        amount: 10.0,
        currency: 'USD',
        providerId: 'stripe',
        error: error,
      );

      expect(result.isFailed, true);
      expect(result.isSuccess, false);
      expect(result.error, isNotNull);
      expect(result.error!.code, PaymentErrorCode.cardDeclined);
    });
  });

  group('Subscription', () {
    test('calculates days remaining correctly', () {
      final subscription = Subscription(
        subscriptionId: 'sub_123',
        customerId: 'cust_123',
        planId: 'monthly',
        status: SubscriptionStatus.active,
        startDate: DateTime.now(),
        currentPeriodStart: DateTime.now(),
        currentPeriodEnd: DateTime.now().add(Duration(days: 30)),
        amount: 9.99,
        currency: 'USD',
        interval: BillingInterval.monthly,
        providerId: 'stripe',
      );

      expect(subscription.daysRemaining, greaterThan(29));
      expect(subscription.daysRemaining, lessThanOrEqual(30));
    });

    test('identifies active subscription', () {
      final subscription = Subscription(
        subscriptionId: 'sub_123',
        customerId: 'cust_123',
        planId: 'monthly',
        status: SubscriptionStatus.active,
        startDate: DateTime.now(),
        currentPeriodStart: DateTime.now(),
        currentPeriodEnd: DateTime.now().add(Duration(days: 30)),
        amount: 9.99,
        currency: 'USD',
        interval: BillingInterval.monthly,
        providerId: 'stripe',
      );

      expect(subscription.isActive, true);
      expect(subscription.isCanceled, false);
    });

    test('identifies trialing subscription', () {
      final subscription = Subscription(
        subscriptionId: 'sub_123',
        customerId: 'cust_123',
        planId: 'monthly',
        status: SubscriptionStatus.trialing,
        startDate: DateTime.now(),
        trialEndDate: DateTime.now().add(Duration(days: 7)),
        currentPeriodStart: DateTime.now(),
        currentPeriodEnd: DateTime.now().add(Duration(days: 7)),
        amount: 9.99,
        currency: 'USD',
        interval: BillingInterval.monthly,
        providerId: 'stripe',
      );

      expect(subscription.isTrialing, true);
      expect(subscription.trialDaysRemaining, greaterThan(6));
    });
  });
}
```

### Testing Payment Provider

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:reuablewidgets/features/payment/payment.dart';

void main() {
  group('MockPaymentProvider', () {
    late MockPaymentProvider provider;

    setUp(() {
      provider = MockPaymentProvider();
    });

    tearDown(() async {
      await provider.dispose();
    });

    test('initializes successfully', () async {
      expect(provider.isInitialized, false);

      await provider.initialize(
        StripeConfig(publishableKey: 'test_key'),
      );

      expect(provider.isInitialized, true);
      expect(provider.isEnabled, true);
    });

    test('processes payment successfully', () async {
      await provider.initialize(StripeConfig(publishableKey: 'test'));

      final request = PaymentRequest(
        amount: 50.0,
        currency: 'USD',
        description: 'Test payment',
      );

      final result = await provider.processPayment(request);

      expect(result.status, PaymentStatus.succeeded);
      expect(result.amount, 50.0);
      expect(result.transactionId, isNotEmpty);
      expect(result.receiptData, isNotNull);
    });

    test('throws exception for invalid request', () async {
      await provider.initialize(StripeConfig(publishableKey: 'test'));

      final request = PaymentRequest(
        amount: -1.0,
        currency: 'USD',
        description: 'Invalid',
      );

      expect(
        () => provider.processPayment(request),
        throwsA(isA<PaymentValidationException>()),
      );
    });

    test('supports configured currencies', () {
      expect(provider.supportsCurrency('USD'), true);
      expect(provider.supportsCurrency('EUR'), true);
      expect(provider.supportsCurrency('XYZ'), false);
    });

    test('creates subscription successfully', () async {
      await provider.initialize(StripeConfig(publishableKey: 'test'));

      final request = SubscriptionRequest(
        planId: 'monthly',
        customerId: 'cust_123',
        trialDays: 7,
      );

      final result = await provider.createSubscription(request);

      expect(result.success, true);
      expect(result.subscription.status, SubscriptionStatus.trialing);
      expect(result.subscription.planId, 'monthly');
    });

    test('cancels subscription', () async {
      await provider.initialize(StripeConfig(publishableKey: 'test'));

      // Create subscription
      final createRequest = SubscriptionRequest(
        planId: 'monthly',
        customerId: 'cust_123',
      );

      final created = await provider.createSubscription(createRequest);
      final subscriptionId = created.subscription.subscriptionId;

      // Cancel subscription
      await provider.cancelSubscription(
        subscriptionId,
        reason: CancellationReason.userRequested,
      );

      // Verify cancellation
      final subscription = await provider.getSubscription(subscriptionId);
      expect(subscription.status, SubscriptionStatus.canceled);
      expect(subscription.cancellationReason, CancellationReason.userRequested);
    });

    test('validates receipt', () async {
      await provider.initialize(StripeConfig(publishableKey: 'test'));

      final validation = await provider.validateReceipt('test_receipt_data');

      expect(validation.isValid, true);
      expect(validation.productId, isNotNull);
    });

    test('processes refund', () async {
      await provider.initialize(StripeConfig(publishableKey: 'test'));

      // Create payment
      final paymentRequest = PaymentRequest(
        amount: 100.0,
        currency: 'USD',
        description: 'Test',
      );

      final payment = await provider.processPayment(paymentRequest);

      // Refund payment
      final refundResult = await provider.refundTransaction(
        payment.transactionId,
        amount: 50.0,
      );

      expect(refundResult.success, true);
      expect(refundResult.refundTransaction.amount, 50.0);
      expect(refundResult.refundTransaction.type, TransactionType.partialRefund);
    });
  });
}
```

---

## Integration Testing

### Complete Payment Flow

```dart
testWidgets('Complete payment flow with mock provider', (tester) async {
  // Initialize PaymentManager
  final config = PaymentConfig(
    providers: {
      'mock': StripeConfig(publishableKey: 'test_key'),
    },
    isTestMode: true,
  );

  await PaymentManager.initialize(config);

  // Create payment request
  final request = PaymentRequest(
    amount: 25.99,
    currency: 'USD',
    description: 'Test product',
    customer: Customer(
      email: 'test@example.com',
      name: 'Test User',
    ),
  );

  // Process payment
  final result = await PaymentManager.instance.processPayment(
    request,
    preferredProviderId: 'mock',
  );

  // Verify result
  expect(result.status, PaymentStatus.succeeded);
  expect(result.amount, 25.99);
  expect(result.transactionId, isNotEmpty);

  // Verify transaction was saved
  final transactions = await PaymentManager.instance.getTransactionHistory(
    providerId: 'mock',
  );

  expect(transactions, isNotEmpty);
  expect(transactions.first.amount, 25.99);
});
```

---

## Sandbox Testing

### Stripe Sandbox

```dart
// Test cards for Stripe sandbox
const stripeTestCards = {
  'success': '4242424242424242',
  'decline': '4000000000000002',
  'insufficientFunds': '4000000000009995',
  'expired': '4000000000000069',
  'processingError': '4000000000000119',
  '3dSecure': '4000002500003155',
};

test('Stripe sandbox - successful payment', () async {
  final provider = StripeProvider();
  await provider.initialize(
    StripeConfig(
      publishableKey: 'pk_test_YOUR_KEY',
      environment: PaymentEnvironment.sandbox,
    ),
  );

  final request = PaymentRequest(
    amount: 10.0,
    currency: 'USD',
    description: 'Sandbox test',
  );

  final result = await provider.processPayment(request);

  expect(result.isSuccess, true);
});
```

### Google Play Billing Test

```dart
// Test SKUs for Google Play
const googlePlayTestSKUs = {
  'purchased': 'android.test.purchased',
  'canceled': 'android.test.canceled',
  'refunded': 'android.test.refunded',
  'unavailable': 'android.test.item_unavailable',
};

test('Google Play - test purchase', () async {
  final provider = GooglePlayBillingProvider();
  await provider.initialize(GooglePlayConfig());

  final request = PaymentRequest(
    amount: 0,
    currency: 'USD',
    description: 'Test product',
    orderId: googlePlayTestSKUs['purchased'],
    preferredMethod: PaymentMethod.inAppPurchase,
  );

  final result = await provider.processPayment(request);

  expect(result.isSuccess, true);
});
```

---

## Performance Testing

```dart
test('Payment processing completes within 3 seconds', () async {
  final stopwatch = Stopwatch()..start();

  final result = await PaymentManager.instance.processPayment(
    PaymentRequest(
      amount: 10.0,
      currency: 'USD',
      description: 'Performance test',
    ),
  );

  stopwatch.stop();

  expect(result.isSuccess, true);
  expect(stopwatch.elapsedMilliseconds, lessThan(3000));
});

test('Handles 10 concurrent payments', () async {
  final requests = List.generate(
    10,
    (i) => PaymentRequest(
      amount: (i + 1).toDouble(),
      currency: 'USD',
      description: 'Concurrent test $i',
    ),
  );

  final results = await Future.wait(
    requests.map((r) => PaymentManager.instance.processPayment(r)),
  );

  expect(results.length, 10);
  expect(results.every((r) => r.isSuccess), true);
});
```

---

## Security Testing

```dart
group('Security Tests', () {
  test('Prevents duplicate transactions', () async {
    final request = PaymentRequest(
      requestId: 'duplicate_test_123',
      amount: 10.0,
      currency: 'USD',
      description: 'Test',
    );

    // First payment should succeed
    final result1 = await PaymentManager.instance.processPayment(request);
    expect(result1.isSuccess, true);

    // Second payment with same requestId should fail
    expect(
      () => PaymentManager.instance.processPayment(request),
      throwsA(isA<DuplicateTransactionException>()),
    );
  });

  test('Validates API keys', () {
    expect(
      () => StripeConfig(publishableKey: ''),
      throwsA(isA<ArgumentError>()),
    );
  });

  test('Receipt validation detects tampering', () async {
    final fakeReceipt = 'fake_receipt_data_12345';

    final validation = await PaymentManager.instance.validateReceipt(
      fakeReceipt,
      'stripe',
    );

    expect(validation.isValid, false);
    expect(validation.errorMessage, isNotNull);
  });
});
```

---

## Test Coverage Requirements

Aim for:
- **Unit Tests**: 80%+ code coverage
- **Integration Tests**: All major flows covered
- **E2E Tests**: Happy path + critical error scenarios

Run coverage:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## Manual Testing Checklist

### Payment Flow
- [ ] Successful payment with each provider
- [ ] Declined payment handling
- [ ] Network timeout handling
- [ ] User cancellation
- [ ] Invalid card details
- [ ] Insufficient funds

### Subscription Flow
- [ ] Create subscription with trial
- [ ] Create subscription without trial
- [ ] Cancel subscription
- [ ] Update subscription plan
- [ ] Subscription renewal
- [ ] Failed renewal (grace period)

### IAP Flow
- [ ] Purchase consumable product
- [ ] Purchase non-consumable product
- [ ] Subscribe to auto-renewable subscription
- [ ] Restore purchases
- [ ] Receipt validation

### Error Scenarios
- [ ] No internet connection
- [ ] Provider service outage
- [ ] Invalid API keys
- [ ] Rate limiting
- [ ] Currency not supported

---

## CI/CD Integration

```yaml
# .github/workflows/test.yml
name: Test Payment Module

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
```

---

## Debugging Tips

### Enable Verbose Logging

```dart
final config = PaymentConfig(
  providers: {...},
  enableLogging: true, // Enable logging
);

await PaymentManager.initialize(config);
```

### Capture Network Traffic

Use tools like:
- Charles Proxy
- Proxyman
- Wireshark

To inspect API calls to payment providers.

### Test in Airplane Mode

```dart
// Test offline handling
await connectivityService.disableNetwork();

final result = await PaymentManager.instance.processPayment(request);

// Should queue transaction for later
expect(result.status, PaymentStatus.pending);
```

---

## Best Practices

1. **Always test in sandbox first** before production
2. **Never commit API keys** to version control
3. **Mock external dependencies** in unit tests
4. **Test error scenarios** as thoroughly as happy paths
5. **Use test coverage tools** to identify gaps
6. **Automate tests** in CI/CD pipeline
7. **Test on real devices** for IAP flows

---

For more information, see [README.md](README.md) and [PAYMENT_MODULE_SPECIFICATION.md](PAYMENT_MODULE_SPECIFICATION.md).
