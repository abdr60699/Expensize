# Integration Guide

How to integrate payment, UPI, and onboarding modules into any Flutter application.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Module Structure](#module-structure)
- [Installation](#installation)
- [Payment Integration](#payment-integration)
- [UPI Integration](#upi-integration)
- [Onboarding Integration](#onboarding-integration)
- [Combined Usage](#combined-usage)
- [Best Practices](#best-practices)
- [Testing](#testing)
- [Migration Guide](#migration-guide)

---

## Prerequisites

- Flutter SDK >=3.4.1
- Platform-specific requirements:
  - **UPI**: Android only, Min SDK 26
  - **IAP**: iOS/Android with app store setup
- Payment provider accounts (for production)

---

## Module Structure

This package contains **THREE independent modules**:

```
lib/
├── payment/          # Payment integration (multi-provider)
├── upi_payment/      # UPI payments (India-specific)
└── onboarding/       # User onboarding

You can use:
- Only payment module
- Only UPI payment module
- Only onboarding module
- Any combination of the above
```

---

## Installation

### Step 1: Copy Modules

```bash
# Copy the entire payment directory to your project
cp -r feature_test/payment/lib/* /path/to/your/project/lib/
```

### Step 2: Add Dependencies

In your `pubspec.yaml`:

```yaml
dependencies:
  # Core
  uuid: ^4.5.2                    # For unique IDs
  shared_preferences: ^2.5.3      # For persistence

  # Payment providers (add as needed)
  # stripe_flutter: ^latest        # For Stripe
  # flutter_paypal: ^latest        # For PayPal
  # razorpay_flutter: ^latest      # For Razorpay
  # in_app_purchase: ^latest       # For IAP

  # UPI (Android only)
  # No additional packages needed (uses method channels)

  # Onboarding
  # No additional packages needed (uses built-in widgets)
```

### Step 3: Install

```bash
flutter pub get
```

---

## Payment Integration

### Basic Integration (5 Minutes)

#### 1. Import Module

```dart
import 'package:your_app/payment/payment.dart';
```

#### 2. Initialize Payment Manager

```dart
// lib/main.dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize with mock provider for testing
  await PaymentManager.initialize(
    PaymentConfig(
      providers: {
        PaymentProvider.mock: ProviderConfig(enabled: true),
      },
      defaultProvider: PaymentProvider.mock,
      environment: PaymentEnvironment.sandbox,
    ),
  );

  runApp(MyApp());
}
```

#### 3. Process Payment

```dart
class CheckoutScreen extends StatelessWidget {
  Future<void> _processPayment() async {
    final request = PaymentRequest(
      amount: 29.99,
      currency: 'USD',
      description: 'Premium Plan',
    );

    final result = await PaymentManager.instance.processPayment(request);

    if (result.isSuccess) {
      print('Payment successful: ${result.transactionId}');
      // Grant access, show success screen
    } else {
      print('Payment failed: ${result.error?.message}');
      // Show error, retry option
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _processPayment,
      child: Text('Pay Now'),
    );
  }
}
```

---

### Advanced Integration

#### Payment Service Wrapper

```dart
// lib/services/payment_service.dart
import 'package:your_app/payment/payment.dart';

class PaymentService {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal();

  Future<void> initialize() async {
    await PaymentManager.initialize(
      PaymentConfig(
        providers: _getProviders(),
        defaultProvider: PaymentProvider.stripe,
        environment: _getEnvironment(),
      ),
    );
  }

  Map<PaymentProvider, ProviderConfig> _getProviders() {
    // In production, use environment variables
    final stripeKey = const String.fromEnvironment('STRIPE_KEY');

    return {
      PaymentProvider.stripe: ProviderConfig(
        enabled: stripeKey.isNotEmpty,
        credentials: {
          'publishableKey': stripeKey,
        },
      ),
      PaymentProvider.mock: ProviderConfig(
        enabled: stripeKey.isEmpty,  // Use mock if no real key
      ),
    };
  }

  PaymentEnvironment _getEnvironment() {
    return const bool.fromEnvironment('dart.vm.product')
        ? PaymentEnvironment.production
        : PaymentEnvironment.sandbox;
  }

  Future<PaymentResult> checkout({
    required double amount,
    required String currency,
    required String description,
    Map<String, dynamic>? metadata,
  }) async {
    final request = PaymentRequest(
      amount: amount,
      currency: currency,
      description: description,
      metadata: metadata,
    );

    try {
      return await PaymentManager.instance.processPayment(request);
    } catch (e) {
      return PaymentResult(
        isSuccess: false,
        error: PaymentError(
          code: 'UNKNOWN_ERROR',
          message: e.toString(),
        ),
      );
    }
  }

  Future<Subscription> createSubscription({
    required String customerId,
    required String planId,
    required String paymentMethod,
    int? trialDays,
  }) async {
    return await PaymentManager.instance.createSubscription(
      customerId: customerId,
      planId: planId,
      paymentMethod: paymentMethod,
      trialDays: trialDays,
    );
  }

  Future<void> cancelSubscription(String subscriptionId) async {
    await PaymentManager.instance.cancelSubscription(
      subscriptionId,
      cancelAtPeriodEnd: true,
    );
  }
}
```

---

#### Repository Pattern

```dart
// lib/repositories/payment_repository.dart
import 'package:your_app/payment/payment.dart';
import 'package:your_app/services/api_client.dart';

class PaymentRepository {
  final PaymentService _paymentService;
  final ApiClient _apiClient;

  PaymentRepository({
    PaymentService? paymentService,
    ApiClient? apiClient,
  })  : _paymentService = paymentService ?? PaymentService(),
        _apiClient = apiClient ?? ApiClient();

  /// Process payment and update backend
  Future<PaymentResult> processPayment({
    required double amount,
    required String productId,
    required String userId,
  }) async {
    // 1. Create payment intent on server
    final intentResponse = await _apiClient.post(
      '/payments/intent',
      body: {
        'amount': amount,
        'userId': userId,
        'productId': productId,
      },
    );

    // 2. Process payment with provider
    final result = await _paymentService.checkout(
      amount: amount,
      currency: 'USD',
      description: 'Product: $productId',
      metadata: {
        'userId': userId,
        'productId': productId,
        'intentId': intentResponse['intentId'],
      },
    );

    // 3. Confirm payment on server
    if (result.isSuccess) {
      await _apiClient.post(
        '/payments/confirm',
        body: {
          'transactionId': result.transactionId,
          'intentId': intentResponse['intentId'],
        },
      );
    }

    return result;
  }

  /// Subscribe user to plan
  Future<Subscription> subscribe({
    required String userId,
    required String planId,
  }) async {
    // 1. Create customer on payment provider
    final customer = await _createCustomer(userId);

    // 2. Create subscription
    final subscription = await _paymentService.createSubscription(
      customerId: customer.id,
      planId: planId,
      paymentMethod: customer.defaultPaymentMethod!,
      trialDays: 7,
    );

    // 3. Update subscription status on server
    await _apiClient.post(
      '/subscriptions',
      body: {
        'userId': userId,
        'subscriptionId': subscription.id,
        'planId': planId,
        'status': subscription.status,
      },
    );

    return subscription;
  }

  Future<Customer> _createCustomer(String userId) async {
    // Implementation depends on provider
    throw UnimplementedError();
  }
}
```

---

## UPI Integration

### Platform Setup Required

⚠️ **IMPORTANT**: UPI requires Android platform code implementation.

See detailed setup guide: `upi_payment/PROCESS_SETUP.md`

---

### Basic UPI Integration

#### 1. Import Module

```dart
import 'package:your_app/upi_payment/upi_payment.dart';
import 'package:uuid/uuid.dart';
```

#### 2. Create Payment Request

```dart
class UpiCheckoutScreen extends StatelessWidget {
  Future<void> _initiateUpiPayment() async {
    final request = UpiPaymentRequest(
      payeeVpa: 'merchant@upi',           // Your UPI ID
      payeeName: 'Your Business Name',
      transactionId: 'TXN_${Uuid().v4()}',
      transactionRef: 'REF_${DateTime.now().millisecondsSinceEpoch}',
      amount: 299.00,
      currency: 'INR',
      transactionNote: 'Premium Plan Payment',
    );

    // Note: Requires platform implementation
    // final response = await UpiPaymentManager.instance.initiatePayment(request);

    // For now, show mock response
    _showPlatformSetupRequired();
  }

  void _showPlatformSetupRequired() {
    print('UPI requires Android platform code.');
    print('See: upi_payment/PROCESS_SETUP.md');
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _initiateUpiPayment,
      child: Text('Pay with UPI'),
    );
  }
}
```

---

### Advanced UPI Integration

#### UPI Service Wrapper

```dart
// lib/services/upi_service.dart
import 'package:your_app/upi_payment/upi_payment.dart';
import 'package:uuid/uuid.dart';

class UpiService {
  static final UpiService _instance = UpiService._internal();
  factory UpiService() => _instance;
  UpiService._internal();

  final String _merchantVpa = 'merchant@upi';
  final String _merchantName = 'My Business';

  Future<UpiPaymentResponse> initiatePayment({
    required double amount,
    required String orderId,
    String? note,
  }) async {
    final request = UpiPaymentRequest(
      payeeVpa: _merchantVpa,
      payeeName: _merchantName,
      transactionId: _generateTransactionId(),
      transactionRef: _generateTransactionRef(),
      amount: amount,
      currency: 'INR',
      transactionNote: note ?? 'Order #$orderId',
      metadata: {
        'orderId': orderId,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    // Requires platform implementation
    // final response = await UpiPaymentManager.instance.initiatePayment(request);
    // return response;

    throw UnsupportedError('UPI requires Android platform code');
  }

  Future<bool> verifyPaymentOnServer(UpiPaymentResponse response) async {
    // Implement server verification
    // NEVER trust client-side payment verification
    throw UnimplementedError();
  }

  String _generateTransactionId() {
    return 'TXN_${Uuid().v4().replaceAll('-', '')}';
  }

  String _generateTransactionRef() {
    return 'REF_${DateTime.now().millisecondsSinceEpoch}';
  }
}
```

---

## Onboarding Integration

### Basic Integration (2 Minutes)

#### 1. Import Module

```dart
import 'package:your_app/onboarding/onboarding.dart';
```

#### 2. Create Onboarding Pages

```dart
// lib/onboarding/pages.dart
import 'package:flutter/material.dart';
import 'package:your_app/onboarding/onboarding.dart';

List<OnboardingPage> getOnboardingPages() {
  return [
    OnboardingPage.withIcon(
      title: 'Welcome to MyApp',
      description: 'The best way to manage your finances!',
      icon: Icons.waving_hand,
      iconColor: Colors.blue,
    ),

    OnboardingPage.withImage(
      title: 'Track Expenses',
      description: 'Monitor your spending and save more money.',
      imagePath: 'assets/onboarding/expenses.png',
    ),

    OnboardingPage.withIcon(
      title: 'Set Budgets',
      description: 'Create budgets and stick to them.',
      icon: Icons.account_balance_wallet,
      iconColor: Colors.green,
    ),

    OnboardingPage.withIcon(
      title: 'Get Started',
      description: 'Ready to take control of your finances?',
      icon: Icons.check_circle,
      iconColor: Colors.orange,
    ),
  ];
}
```

#### 3. Show Onboarding

```dart
// lib/main.dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<bool>(
        future: _shouldShowOnboarding(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen();
          }

          if (snapshot.data == true) {
            return _buildOnboardingScreen(context);
          }

          return HomeScreen();
        },
      ),
    );
  }

  Future<bool> _shouldShowOnboarding() async {
    final service = OnboardingService(version: '1.0.0');
    await service.initialize();
    return await service.shouldShowOnboarding();
  }

  Widget _buildOnboardingScreen(BuildContext context) {
    return OnboardingScreen(
      config: OnboardingConfig(
        pages: getOnboardingPages(),
        onComplete: () async {
          // Mark complete
          final service = OnboardingService(version: '1.0.0');
          await service.markComplete();

          // Navigate to home
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
          );
        },
        showSkipButton: true,
      ),
    );
  }
}
```

---

### Advanced Integration

#### Onboarding Service Wrapper

```dart
// lib/services/onboarding_service_wrapper.dart
import 'package:your_app/onboarding/onboarding.dart';

class OnboardingServiceWrapper {
  final OnboardingService _service;
  final OnboardingAnalytics _analytics;

  OnboardingServiceWrapper()
      : _service = OnboardingService(version: '1.0.0'),
        _analytics = OnboardingAnalytics();

  Future<void> initialize() async {
    await _service.initialize();
  }

  Future<bool> shouldShow() async {
    final should = await _service.shouldShowOnboarding();

    if (should) {
      await _analytics.trackOnboardingStart();
    }

    return should;
  }

  Future<void> markComplete() async {
    await _service.markComplete();
    await _analytics.trackComplete();
  }

  Future<void> trackPageView(int index, String title) async {
    await _analytics.trackPageView(
      pageIndex: index,
      title: title,
    );
  }

  Future<void> trackSkip(int pageIndex) async {
    await _analytics.trackSkip(pageIndex: pageIndex);
  }

  Future<void> reset() async {
    await _service.reset();
  }
}
```

---

#### Custom Onboarding Screen

```dart
// lib/screens/custom_onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:your_app/onboarding/onboarding.dart';

class CustomOnboardingScreen extends StatefulWidget {
  @override
  State<CustomOnboardingScreen> createState() => _CustomOnboardingScreenState();
}

class _CustomOnboardingScreenState extends State<CustomOnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<OnboardingPage> _pages = getOnboardingPages();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _skip,
                child: Text('Skip'),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingPageWidget(
                    page: _pages[index],
                  );
                },
              ),
            ),

            // Page indicator
            PageIndicator(
              pageCount: _pages.length,
              currentPage: _currentPage,
            ),

            SizedBox(height: 32),

            // Navigation button
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: ElevatedButton(
                onPressed: _currentPage == _pages.length - 1
                    ? _complete
                    : _next,
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                ),
              ),
            ),

            SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _next() {
    _pageController.nextPage(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _skip() async {
    await _complete();
  }

  Future<void> _complete() async {
    final service = OnboardingService(version: '1.0.0');
    await service.markComplete();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
```

---

## Combined Usage

### Payment with Onboarding

```dart
// Show onboarding, then prompt for subscription
class AppInitializer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _shouldShowOnboarding(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen();
        }

        if (snapshot.data == true) {
          return OnboardingScreen(
            config: OnboardingConfig(
              pages: getOnboardingPages(),
              onComplete: () async {
                await _completeOnboarding();

                // After onboarding, show subscription offer
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SubscriptionOfferScreen(),
                  ),
                );
              },
            ),
          );
        }

        return HomeScreen();
      },
    );
  }

  Future<bool> _shouldShowOnboarding() async {
    final service = OnboardingService(version: '1.0.0');
    await service.initialize();
    return await service.shouldShowOnboarding();
  }

  Future<void> _completeOnboarding() async {
    final service = OnboardingService(version: '1.0.0');
    await service.markComplete();
  }
}
```

---

### Multi-Payment Options with UPI

```dart
class MultiPaymentCheckout extends StatelessWidget {
  final double amount;
  final String orderId;

  const MultiPaymentCheckout({
    required this.amount,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Card payment option
        PaymentMethodTile(
          icon: Icons.credit_card,
          title: 'Credit/Debit Card',
          subtitle: 'Visa, Mastercard, Amex',
          onTap: () => _payWithCard(context),
        ),

        // UPI payment option (India only)
        if (isIndianRegion())
          PaymentMethodTile(
            icon: Icons.account_balance_wallet,
            title: 'UPI',
            subtitle: 'Google Pay, PhonePe, Paytm',
            onTap: () => _payWithUpi(context),
          ),
      ],
    );
  }

  Future<void> _payWithCard(BuildContext context) async {
    final result = await PaymentService().checkout(
      amount: amount,
      currency: 'USD',
      description: 'Order #$orderId',
    );

    _handlePaymentResult(context, result);
  }

  Future<void> _payWithUpi(BuildContext context) async {
    try {
      final response = await UpiService().initiatePayment(
        amount: amount,
        orderId: orderId,
      );

      if (response.isSuccess) {
        // Verify on server before confirming
        final verified = await UpiService().verifyPaymentOnServer(response);

        if (verified) {
          _showSuccess(context);
        } else {
          _showError(context, 'Payment verification failed');
        }
      }
    } catch (e) {
      _showError(context, e.toString());
    }
  }

  void _handlePaymentResult(BuildContext context, PaymentResult result) {
    if (result.isSuccess) {
      _showSuccess(context);
    } else {
      _showError(context, result.error!.message);
    }
  }

  void _showSuccess(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PaymentSuccessScreen()),
    );
  }

  void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Payment Failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  bool isIndianRegion() {
    // Check user's region/country
    return true;  // Simplified
  }
}
```

---

## Best Practices

### 1. Environment Variables

```dart
// NEVER commit API keys
// Use environment variables

// Run with:
// flutter run --dart-define=STRIPE_KEY=pk_test_...

final stripeKey = const String.fromEnvironment('STRIPE_KEY');
final razorpayKey = const String.fromEnvironment('RAZORPAY_KEY');
```

---

### 2. Server-Side Verification

```dart
// ALWAYS verify payments on server
Future<bool> verifyPayment(String transactionId) async {
  final response = await http.post(
    Uri.parse('https://your-api.com/verify-payment'),
    body: {'transactionId': transactionId},
  );

  return response.statusCode == 200;
}
```

---

### 3. Error Handling

```dart
try {
  final result = await PaymentManager.instance.processPayment(request);

  if (result.isSuccess) {
    // Success
  } else {
    // Handle specific errors
    switch (result.error?.code) {
      case 'CARD_DECLINED':
        showError('Card was declined');
        break;
      case 'INSUFFICIENT_FUNDS':
        showError('Insufficient funds');
        break;
      default:
        showError(result.error?.message ?? 'Payment failed');
    }
  }
} on PaymentException catch (e) {
  showError(e.message);
} catch (e) {
  showError('An unexpected error occurred');
}
```

---

### 4. Testing

```dart
// Use mock provider for testing
@visibleForTesting
Future<void> initializeForTesting() async {
  await PaymentManager.initialize(
    PaymentConfig(
      providers: {
        PaymentProvider.mock: ProviderConfig(enabled: true),
      },
      defaultProvider: PaymentProvider.mock,
      environment: PaymentEnvironment.sandbox,
    ),
  );
}
```

---

## Testing

### Unit Tests

```dart
// test/payment_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/payment/payment.dart';

void main() {
  setUpAll(() async {
    await PaymentManager.initialize(
      PaymentConfig(
        providers: {
          PaymentProvider.mock: ProviderConfig(enabled: true),
        },
        defaultProvider: PaymentProvider.mock,
      ),
    );
  });

  test('Mock payment succeeds', () async {
    final request = PaymentRequest(
      amount: 9.99,
      currency: 'USD',
      description: 'Test payment',
    );

    final result = await PaymentManager.instance.processPayment(request);

    expect(result.isSuccess, true);
    expect(result.transactionId, isNotNull);
  });
}
```

---

## Migration Guide

### From other payment libraries

```dart
// Before (e.g., direct Stripe)
import 'package:stripe_flutter/stripe_flutter.dart';

final paymentIntent = await Stripe.instance.createPaymentMethod(...);

// After
import 'package:your_app/payment/payment.dart';

final result = await PaymentManager.instance.processPayment(request);
```

---

## Integration Checklist

### Payment Module
- [ ] Copy payment module files
- [ ] Add dependencies
- [ ] Initialize PaymentManager
- [ ] Configure providers
- [ ] Add environment variables for API keys
- [ ] Test with mock provider
- [ ] Implement error handling
- [ ] Add server-side verification
- [ ] Test with real provider (sandbox)
- [ ] Configure for production

### UPI Module
- [ ] Copy upi_payment module files
- [ ] Review PROCESS_SETUP.md
- [ ] Implement Android method channel
- [ ] Test with UPI apps
- [ ] Add server verification
- [ ] Test transaction flow

### Onboarding Module
- [ ] Copy onboarding module files
- [ ] Create onboarding pages
- [ ] Configure OnboardingService
- [ ] Test first launch flow
- [ ] Test skip functionality
- [ ] Add analytics tracking
- [ ] Test persistence

---

**Ready to accept payments and onboard users!**
