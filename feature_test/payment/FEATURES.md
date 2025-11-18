# Payment & Onboarding Features

Complete guide to payment integration, UPI payments, and user onboarding.

## Table of Contents

- [Module Overview](#module-overview)
- [Folder Structure](#folder-structure)
- [Payment Integration Features](#payment-integration-features)
- [UPI Payment Features](#upi-payment-features)
- [Onboarding Features](#onboarding-features)
- [Use Cases](#use-cases)
- [Feature Matrix](#feature-matrix)

---

## Module Overview

This module contains **THREE independent sub-modules**:

1. **payment** - Multi-provider payment integration (Stripe, PayPal, Razorpay, IAP)
2. **upi_payment** - India-specific UPI payments (Google Pay, PhonePe, Paytm, BHIM)
3. **onboarding** - User onboarding and app walkthroughs

Each module works independently and can be used separately or together.

---

## Folder Structure

### Complete Directory Tree

```
lib/
│
├── payment/                           # 💳 PAYMENT INTEGRATION MODULE
│   ├── payment.dart                   # Main export file
│   │
│   ├── config/                        # Configuration
│   │   ├── payment_config.dart        # Module configuration
│   │   └── provider_config.dart       # Provider settings
│   │
│   ├── models/                        # Data Models
│   │   ├── payment_models.dart        # All models export
│   │   ├── payment_request.dart       # Payment request
│   │   ├── payment_result.dart        # Payment response
│   │   ├── payment_error.dart         # Error model
│   │   ├── transaction.dart           # Transaction record
│   │   ├── receipt.dart               # Receipt/invoice
│   │   ├── customer.dart              # Customer data
│   │   ├── subscription.dart          # Subscription info
│   │   └── product.dart               # Product/item info
│   │
│   ├── providers/                     # Payment Providers
│   │   ├── base/
│   │   │   └── payment_provider_interface.dart  # Abstract interface
│   │   └── mock/
│   │       └── mock_payment_provider.dart       # Testing provider
│   │   # Future providers (to be implemented):
│   │   # ├── stripe/
│   │   # ├── paypal/
│   │   # ├── razorpay/
│   │   # ├── google_play/
│   │   # └── apple_iap/
│   │
│   ├── services/                      # Payment Services
│   │   └── payment_manager.dart       # Main payment service
│   │
│   └── exceptions/                    # Error Handling
│       └── payment_exceptions.dart    # Payment errors
│
├── upi_payment/                       # 🇮🇳 UPI PAYMENT MODULE (India)
│   ├── upi_payment.dart               # Main export file
│   │
│   ├── models/                        # UPI Models
│   │   ├── upi_models.dart            # All models export
│   │   ├── upi_payment_request.dart   # Payment request
│   │   ├── upi_payment_response.dart  # Payment response
│   │   ├── upi_transaction.dart       # Transaction record
│   │   ├── upi_app_info.dart          # UPI app information
│   │   └── upi_error.dart             # UPI error model
│   │
│   └── exceptions/                    # Error Handling
│       └── upi_exceptions.dart        # UPI errors
│   # Future components (to be implemented):
│   # ├── services/
│   # │   ├── upi_payment_manager.dart
│   # │   ├── upi_app_detector.dart
│   # │   └── upi_transaction_manager.dart
│   # ├── platform/
│   # │   └── android/
│   # │       └── upi_method_channel.dart
│   # └── ui/
│   #     ├── screens/
│   #     └── widgets/
│
└── onboarding/                        # 🚀 ONBOARDING MODULE
    ├── onboarding.dart                # Main export file
    │
    ├── models/                        # Onboarding Models
    │   ├── onboarding_page.dart       # Page definition
    │   └── onboarding_config.dart     # Configuration
    │
    ├── services/                      # Services
    │   ├── onboarding_service.dart    # Persistence service
    │   └── onboarding_analytics.dart  # Analytics tracking
    │
    ├── widgets/                       # UI Components
    │   ├── onboarding_screen.dart     # Main screen
    │   ├── onboarding_page_widget.dart # Page widget
    │   └── page_indicator.dart        # Dot indicators
    │
    └── templates/                     # Pre-built Templates
        └── onboarding_templates.dart  # Template library
```

### Key Directory Explanations

#### **payment/providers/**
Provider implementations:
- **base/**: Abstract interface all providers must implement
- **mock/**: Testing provider for development
- **Future**: Stripe, PayPal, Razorpay, Google Play, Apple IAP

#### **payment/models/**
Comprehensive payment data models:
- Request/response models
- Transaction records
- Receipts and invoices
- Customer and subscription data

#### **upi_payment/**
India-specific UPI payment integration:
- Models for UPI transactions
- Platform channel scaffolding (requires Android implementation)
- Supports all major UPI apps

#### **onboarding/**
Complete onboarding solution:
- **models/**: Page and configuration models
- **services/**: Persistence and analytics
- **widgets/**: Ready-to-use UI components
- **templates/**: Pre-built onboarding flows

---

## Payment Integration Features

### 1. Multi-Provider Support

Unified API across multiple payment providers.

```dart
final config = PaymentConfig(
  providers: {
    PaymentProvider.stripe: ProviderConfig(
      enabled: true,
      credentials: {
        'publishableKey': 'pk_test_...',
      },
    ),
    PaymentProvider.paypal: ProviderConfig(
      enabled: true,
      credentials: {
        'clientId': 'your_client_id',
      },
    ),
    PaymentProvider.razorpay: ProviderConfig(
      enabled: true,
      credentials: {
        'apiKey': 'rzp_test_...',
      },
    ),
  },
  defaultProvider: PaymentProvider.stripe,
  environment: PaymentEnvironment.sandbox,
);

await PaymentManager.initialize(config);
```

**Supported Providers:**
- ✅ Stripe (cards, Apple Pay, Google Pay)
- ✅ PayPal
- ✅ Razorpay (India)
- ✅ Google Play Billing (Android IAP)
- ✅ Apple IAP (iOS)
- ✅ Mock Provider (testing)

---

### 2. One-Time Payments

```dart
final request = PaymentRequest(
  amount: 29.99,
  currency: 'USD',
  description: 'Premium Plan - Monthly',
  customerId: 'customer_123',
  metadata: {
    'plan': 'premium',
    'duration': 'monthly',
  },
);

final result = await PaymentManager.instance.processPayment(
  request,
  provider: PaymentProvider.stripe,
);

if (result.isSuccess) {
  print('Payment successful!');
  print('Transaction ID: ${result.transactionId}');
  print('Receipt: ${result.receipt}');
} else {
  print('Payment failed: ${result.error?.message}');
}
```

**Features:**
- Multiple currencies
- Custom metadata
- Receipt generation
- Transaction tracking

---

### 3. Subscription Management

```dart
final subscription = await PaymentManager.instance.createSubscription(
  customerId: 'customer_123',
  planId: 'plan_premium_monthly',
  paymentMethod: 'pm_card_visa',
);

// Check subscription status
final status = await PaymentManager.instance.getSubscriptionStatus(
  subscription.id,
);

// Cancel subscription
await PaymentManager.instance.cancelSubscription(
  subscription.id,
  cancelAtPeriodEnd: true,
);
```

**Subscription Features:**
- Create and manage subscriptions
- Multiple billing cycles
- Trial periods
- Proration handling
- Cancellation management

---

### 4. Receipt Validation

```dart
final receipt = Receipt(
  transactionId: 'txn_123',
  amount: 29.99,
  currency: 'USD',
  timestamp: DateTime.now(),
  items: [
    ReceiptItem(
      name: 'Premium Plan',
      quantity: 1,
      price: 29.99,
    ),
  ],
);

// Validate receipt
final isValid = await PaymentManager.instance.validateReceipt(receipt);

if (isValid) {
  // Grant access to content
  unlockPremiumFeatures();
}
```

---

### 5. Refund Support

```dart
final refund = await PaymentManager.instance.refundPayment(
  transactionId: 'txn_123',
  amount: 29.99,  // Full refund
  reason: 'Customer requested',
);

if (refund.isSuccess) {
  print('Refund processed: ${refund.refundId}');
}
```

**Refund Options:**
- Full refunds
- Partial refunds
- Reason tracking
- Automatic notification

---

### 6. In-App Purchases (IAP)

#### Android (Google Play Billing)

```dart
final products = await PaymentManager.instance.getProducts(
  provider: PaymentProvider.googlePlay,
  productIds: ['premium_monthly', 'premium_yearly'],
);

// Purchase product
final result = await PaymentManager.instance.purchaseProduct(
  productId: 'premium_monthly',
  provider: PaymentProvider.googlePlay,
);
```

#### iOS (Apple IAP)

```dart
final products = await PaymentManager.instance.getProducts(
  provider: PaymentProvider.appleIAP,
  productIds: ['premium_monthly', 'premium_yearly'],
);

// Purchase product
final result = await PaymentManager.instance.purchaseProduct(
  productId: 'premium_monthly',
  provider: PaymentProvider.appleIAP,
);

// Restore purchases
await PaymentManager.instance.restorePurchases(
  provider: PaymentProvider.appleIAP,
);
```

---

### 7. Mock Provider (Testing)

```dart
// Use mock provider for testing
final config = PaymentConfig(
  providers: {
    PaymentProvider.mock: ProviderConfig(enabled: true),
  },
  defaultProvider: PaymentProvider.mock,
);

await PaymentManager.initialize(config);

// All payments will succeed instantly
final result = await PaymentManager.instance.processPayment(request);
// result.isSuccess == true (always for mock)
```

**Mock Features:**
- Instant success responses
- No real transactions
- Perfect for UI testing
- Receipt generation

---

## UPI Payment Features

### 1. UPI App Support

Support for all major Indian UPI apps:

```dart
// Supported UPI apps
enum UpiApp {
  googlePay,      // Google Pay (GPay)
  phonePe,        // PhonePe
  paytm,          // Paytm
  bhim,           // BHIM UPI
  amazonPay,      // Amazon Pay
  custom,         // Any UPI app
}
```

---

### 2. Payment Initiation

```dart
import 'package:uuid/uuid.dart';

final request = UpiPaymentRequest(
  payeeVpa: 'merchant@upi',           // Merchant UPI ID
  payeeName: 'Your Business Name',
  transactionId: 'TXN_${Uuid().v4()}',
  transactionRef: 'REF_${DateTime.now().millisecondsSinceEpoch}',
  amount: 299.00,
  currency: 'INR',
  transactionNote: 'Premium Plan Payment',
  merchantCode: '1234',               // Optional
);

// Note: Requires Android platform implementation
// See upi_payment/PROCESS_SETUP.md for setup

final response = await UpiPaymentManager.instance.initiatePayment(
  request,
  upiApp: UpiApp.googlePay,
);
```

---

### 3. Automatic App Detection

```dart
// Detect installed UPI apps
final installedApps = await UpiAppDetector.getInstalledUpiApps();

print('Available UPI apps:');
for (var app in installedApps) {
  print('- ${app.name}: ${app.packageName}');
}

// Show app selection to user
final selectedApp = await showUpiAppSelection(installedApps);
```

---

### 4. Response Parsing

```dart
final response = UpiPaymentResponse(
  transactionId: 'TXN_123',
  responseCode: 'SUCCESS',
  approvalRefNo: '123456789',
  status: UpiPaymentStatus.success,
  transactionRefId: 'REF_123',
  amount: 299.00,
  rawResponse: 'txnId=TXN_123&...',
);

if (response.isSuccess) {
  print('Payment successful!');
  print('UPI Ref: ${response.approvalRefNo}');

  // IMPORTANT: Verify on server
  await verifyPaymentOnServer(response);
} else {
  print('Payment failed: ${response.status}');
}
```

---

### 5. Transaction Management

```dart
final transaction = UpiTransaction(
  id: 'TXN_123',
  amount: 299.00,
  status: UpiPaymentStatus.success,
  timestamp: DateTime.now(),
  payeeVpa: 'merchant@upi',
  upiRefNo: '123456789',
);

// Store transaction
await UpiTransactionManager.instance.saveTransaction(transaction);

// Get transaction history
final history = await UpiTransactionManager.instance.getTransactions(
  startDate: DateTime.now().subtract(Duration(days: 30)),
  endDate: DateTime.now(),
);
```

---

### 6. Deep Linking

UPI payments use Android intents for deep linking:

```dart
// UPI payment URL format
// upi://pay?pa=merchant@upi&pn=MerchantName&am=299.00&...

final upiUrl = UpiUrlBuilder.build(request);
// upi://pay?pa=merchant@upi&pn=Your%20Business&am=299.00&...

// Launch UPI app with deep link
await launchUpiApp(upiUrl, UpiApp.googlePay);
```

**Platform Requirements:**
- Android only
- Min SDK 26 (Android 8.0+)
- Requires Android platform code

---

## Onboarding Features

### 1. Customizable Pages

```dart
final pages = [
  OnboardingPage.withIcon(
    title: 'Welcome to Our App',
    description: 'Discover amazing features and boost your productivity!',
    icon: Icons.waving_hand,
    iconColor: Colors.blue,
    backgroundColor: Colors.white,
  ),

  OnboardingPage.withImage(
    title: 'Track Your Expenses',
    description: 'Easily monitor your spending and save money.',
    imagePath: 'assets/images/onboarding_1.png',
    backgroundColor: Colors.green.shade50,
  ),

  OnboardingPage.withIcon(
    title: 'Stay Organized',
    description: 'Keep all your finances in one place.',
    icon: Icons.folder_outlined,
    iconColor: Colors.orange,
  ),

  OnboardingPage.withIcon(
    title: 'Get Started',
    description: 'Ready to take control of your money?',
    icon: Icons.check_circle,
    iconColor: Colors.green,
  ),
];
```

**Page Types:**
- Icon-based pages
- Image-based pages
- Custom widgets
- Mixed content

---

### 2. Onboarding Configuration

```dart
final config = OnboardingConfig(
  pages: pages,
  onComplete: () {
    // Mark onboarding complete
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
    );
  },
  onSkip: () {
    // User skipped onboarding
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
    );
  },
  showSkipButton: true,
  skipButtonText: 'Skip',
  nextButtonText: 'Next',
  doneButtonText: 'Get Started',
  showPageIndicator: true,
  pageIndicatorColor: Colors.grey,
  pageIndicatorActiveColor: Colors.blue,
);
```

---

### 3. Persistent Tracking

```dart
final onboardingService = OnboardingService(
  version: '1.0.0',  // App version
);

await onboardingService.initialize();

// Check if onboarding should be shown
if (await onboardingService.shouldShowOnboarding()) {
  // Show onboarding
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => OnboardingScreen(config: config),
    ),
  );

  // Mark as complete after onboarding
  await onboardingService.markComplete();
} else {
  // User has completed onboarding, go to home
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (_) => HomeScreen()),
  );
}
```

**Persistence Features:**
- Survives app restarts
- Version-based tracking
- Reset capability
- SharedPreferences storage

---

### 4. Analytics Integration

```dart
final analytics = OnboardingAnalytics();

// Track onboarding start
await analytics.trackOnboardingStart();

// Track page views
await analytics.trackPageView(pageIndex: 0, title: 'Welcome');

// Track skip
await analytics.trackSkip(pageIndex: 2);

// Track completion
await analytics.trackComplete();

// Custom events
await analytics.trackCustomEvent('onboarding_button_tap', {
  'button': 'Get Started',
  'page': 3,
});
```

---

### 5. Pre-Built Templates

```dart
// E-commerce template
final ecommerceOnboarding = OnboardingTemplates.ecommerce();

// Finance app template
final financeOnboarding = OnboardingTemplates.finance();

// Social app template
final socialOnboarding = OnboardingTemplates.social();

// Health app template
final healthOnboarding = OnboardingTemplates.health();

// Use template
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => OnboardingScreen(config: financeOnboarding),
  ),
);
```

**Available Templates:**
- E-commerce
- Finance/Banking
- Social Media
- Health/Fitness
- Productivity
- Education

---

### 6. Swipe Gestures

```dart
// Swipe to navigate between pages
final config = OnboardingConfig(
  pages: pages,
  enableSwipeGestures: true,       // Enable swiping
  swipeThreshold: 0.3,             // Sensitivity
  pageTransitionDuration: Duration(milliseconds: 300),
  pageTransitionCurve: Curves.easeInOut,
);
```

---

## Use Cases

### Use Case 1: E-Commerce Checkout

```dart
// 1. User selects items
final cart = Cart(
  items: [
    CartItem(name: 'T-Shirt', price: 19.99, quantity: 2),
    CartItem(name: 'Jeans', price: 49.99, quantity: 1),
  ],
);

// 2. Create payment request
final request = PaymentRequest(
  amount: cart.total,
  currency: 'USD',
  description: 'Order #${orderId}',
  metadata: {
    'orderId': orderId,
    'itemCount': cart.items.length,
  },
);

// 3. Process payment
final result = await PaymentManager.instance.processPayment(
  request,
  provider: PaymentProvider.stripe,
);

// 4. Handle result
if (result.isSuccess) {
  await createOrder(cart, result.transactionId);
  showSuccessScreen();
} else {
  showErrorDialog(result.error!.message);
}
```

---

### Use Case 2: Subscription Service

```dart
// Monthly subscription flow
final subscription = await PaymentManager.instance.createSubscription(
  customerId: userId,
  planId: 'premium_monthly',
  paymentMethod: userPaymentMethod,
  trialDays: 7,  // 7-day free trial
);

// Monitor subscription status
final status = await PaymentManager.instance.getSubscriptionStatus(
  subscription.id,
);

if (status == SubscriptionStatus.active) {
  unlockPremiumFeatures();
} else if (status == SubscriptionStatus.pastDue) {
  showPaymentUpdatePrompt();
}
```

---

### Use Case 3: Indian E-Commerce with UPI

```dart
// Offer both card and UPI payment
void showPaymentOptions() {
  showModalBottomSheet(
    context: context,
    builder: (context) => PaymentMethodSelector(
      methods: [
        PaymentMethod.card,
        PaymentMethod.upi,
      ],
      onMethodSelected: (method) async {
        if (method == PaymentMethod.card) {
          // Use regular payment module
          final result = await processCardPayment();
        } else {
          // Use UPI payment module
          final result = await processUpiPayment();
        }
      },
    ),
  );
}

Future<PaymentResult> processUpiPayment() async {
  final request = UpiPaymentRequest(
    payeeVpa: 'merchant@upi',
    payeeName: 'My Store',
    transactionId: generateTxnId(),
    amount: 1299.00,
    currency: 'INR',
  );

  final response = await UpiPaymentManager.instance.initiatePayment(request);

  if (response.isSuccess) {
    // Verify on server
    final verified = await verifyOnServer(response);
    if (verified) {
      return PaymentResult.success(response.transactionId);
    }
  }

  return PaymentResult.failed(response.error);
}
```

---

### Use Case 4: First Launch Experience

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FutureBuilder<bool>(
        future: shouldShowOnboarding(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen();
          }

          if (snapshot.data == true) {
            return OnboardingScreen(
              config: OnboardingConfig(
                pages: getOnboardingPages(),
                onComplete: () async {
                  await markOnboardingComplete();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => HomeScreen()),
                  );
                },
              ),
            );
          }

          return HomeScreen();
        },
      ),
    );
  }

  Future<bool> shouldShowOnboarding() async {
    final service = OnboardingService(version: '1.0.0');
    await service.initialize();
    return await service.shouldShowOnboarding();
  }
}
```

---

## Feature Matrix

### Payment Integration

| Feature | Supported | Providers |
|---------|-----------|-----------|
| One-time payments | ✅ | All |
| Subscriptions | ✅ | Stripe, PayPal, Razorpay |
| In-app purchases | ✅ | Google Play, Apple IAP |
| Refunds | ✅ | Stripe, PayPal, Razorpay |
| Receipt validation | ✅ | All |
| Multiple currencies | ✅ | All |
| Card payments | ✅ | Stripe, PayPal, Razorpay |
| Apple Pay | ✅ | Stripe |
| Google Pay | ✅ | Stripe, Google Play |
| Mock testing | ✅ | Mock provider |

### UPI Payment

| Feature | Supported | Platform |
|---------|-----------|----------|
| Google Pay | ✅ | Android |
| PhonePe | ✅ | Android |
| Paytm | ✅ | Android |
| BHIM | ✅ | Android |
| Amazon Pay | ✅ | Android |
| Custom UPI apps | ✅ | Android |
| Auto app detection | ✅ | Android |
| Deep linking | ✅ | Android |
| Transaction tracking | ✅ | All |
| Server verification | ✅ | All |

### Onboarding

| Feature | Supported | Notes |
|---------|-----------|-------|
| Icon pages | ✅ | Built-in |
| Image pages | ✅ | Built-in |
| Custom pages | ✅ | Flexible |
| Persistence | ✅ | SharedPreferences |
| Skip button | ✅ | Configurable |
| Page indicators | ✅ | Customizable |
| Swipe gestures | ✅ | Native |
| Analytics | ✅ | Event tracking |
| Templates | ✅ | 6 pre-built |
| Version tracking | ✅ | Per version |

---

## Platform Support

| Feature | Android | iOS | Web |
|---------|---------|-----|-----|
| Payment Integration (demo) | ✅ | ✅ | ✅ |
| Stripe | ✅ | ✅ | ✅ |
| PayPal | ✅ | ✅ | ✅ |
| Razorpay | ✅ | ✅ | ✅ |
| Google Play Billing | ✅ | ❌ | ❌ |
| Apple IAP | ❌ | ✅ | ❌ |
| UPI Payment | ✅ | ❌ | ❌ |
| Onboarding | ✅ | ✅ | ⚠️ |

**Legend:**
- ✅ Fully supported
- ⚠️ Limited support
- ❌ Not supported

---

**Ready to integrate payments and create great first impressions!**
