# Setup Guide

Complete setup instructions for payment, UPI, and onboarding modules from scratch.

## Table of Contents

- [Module Structure](#module-structure)
- [Dependencies](#dependencies)
- [Payment Module Setup](#payment-module-setup)
- [UPI Module Setup](#upi-module-setup)
- [Onboarding Module Setup](#onboarding-module-setup)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)
- [Production Checklist](#production-checklist)

---

## Module Structure

### Directory Organization

This package contains **THREE independent modules**:

```
lib/
│
├── payment/                           # 💳 PAYMENT INTEGRATION MODULE
│   ├── payment.dart                   # Main entry point
│   │
│   ├── config/                        # Configuration
│   │   ├── payment_config.dart        # Module configuration
│   │   │   - Provider selection
│   │   │   - Environment settings
│   │   │   - Default provider
│   │   └── provider_config.dart       # Provider-specific config
│   │       - API credentials
│   │       - Provider settings
│   │
│   ├── models/                        # Data Models
│   │   ├── payment_request.dart       # Payment input
│   │   ├── payment_result.dart        # Payment output
│   │   ├── payment_error.dart         # Error details
│   │   ├── transaction.dart           # Transaction record
│   │   ├── receipt.dart               # Receipt/invoice
│   │   ├── customer.dart              # Customer info
│   │   ├── subscription.dart          # Subscription data
│   │   └── product.dart               # Product/item info
│   │
│   ├── providers/                     # Payment Providers
│   │   ├── base/
│   │   │   └── payment_provider_interface.dart  # Interface
│   │   └── mock/
│   │       └── mock_payment_provider.dart       # Testing
│   │
│   ├── services/                      # Core Services
│   │   └── payment_manager.dart       # Main service
│   │
│   └── exceptions/                    # Error Handling
│       └── payment_exceptions.dart
│
├── upi_payment/                       # 🇮🇳 UPI PAYMENT MODULE
│   ├── upi_payment.dart               # Main entry point
│   ├── models/                        # UPI models
│   └── exceptions/                    # UPI errors
│
└── onboarding/                        # 🚀 ONBOARDING MODULE
    ├── onboarding.dart                # Main entry point
    ├── models/                        # Page models
    ├── services/                      # Persistence & analytics
    ├── widgets/                       # UI components
    └── templates/                     # Pre-built templates
```

### Component Responsibilities

**payment/**
- Multi-provider payment integration
- Unified API across providers
- Subscription management
- Receipt generation

**upi_payment/**
- India-specific UPI payments
- Platform channel integration
- UPI app detection
- Deep linking

**onboarding/**
- User onboarding flows
- Persistent tracking
- Analytics integration
- Pre-built templates

---

## Dependencies

### pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Core
  uuid: ^4.5.2                    # For unique IDs
  shared_preferences: ^2.5.3      # For persistence

  # Payment Providers (Optional - add as needed)
  # stripe_flutter: ^10.2.0       # Stripe integration
  # flutter_paypal_payment: ^1.0.8  # PayPal
  # razorpay_flutter: ^1.3.7      # Razorpay (India)
  # in_app_purchase: ^3.1.13      # Google/Apple IAP

  # Optional - For permissions
  permission_handler: ^12.0.1     # Android/iOS permissions
```

### Install Dependencies

```bash
flutter pub get
```

---

## Payment Module Setup

### Step 1: Copy Module Files

```bash
# Copy payment directory to your project
cp -r feature_test/payment/lib/payment /path/to/your/project/lib/
```

Verify structure:
```
your_project/
└── lib/
    └── payment/
        ├── payment.dart
        ├── config/
        ├── models/
        ├── providers/
        ├── services/
        └── exceptions/
```

---

### Step 2: Initialize Payment Manager

#### Basic Initialization (Testing)

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'payment/payment.dart';

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

---

#### Production Initialization

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'payment/payment.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PaymentManager.initialize(
    PaymentConfig(
      providers: _getProviderConfigs(),
      defaultProvider: PaymentProvider.stripe,
      environment: _getEnvironment(),
    ),
  );

  runApp(MyApp());
}

Map<PaymentProvider, ProviderConfig> _getProviderConfigs() {
  // Get API keys from environment variables
  // NEVER commit these to version control
  final stripeKey = const String.fromEnvironment('STRIPE_KEY');
  final paypalKey = const String.fromEnvironment('PAYPAL_CLIENT_ID');
  final razorpayKey = const String.fromEnvironment('RAZORPAY_KEY');

  return {
    // Stripe
    if (stripeKey.isNotEmpty)
      PaymentProvider.stripe: ProviderConfig(
        enabled: true,
        credentials: {
          'publishableKey': stripeKey,
        },
      ),

    // PayPal
    if (paypalKey.isNotEmpty)
      PaymentProvider.paypal: ProviderConfig(
        enabled: true,
        credentials: {
          'clientId': paypalKey,
        },
      ),

    // Razorpay
    if (razorpayKey.isNotEmpty)
      PaymentProvider.razorpay: ProviderConfig(
        enabled: true,
        credentials: {
          'apiKey': razorpayKey,
        },
      ),

    // Fallback to mock if no keys provided
    PaymentProvider.mock: ProviderConfig(
      enabled: stripeKey.isEmpty && paypalKey.isEmpty && razorpayKey.isEmpty,
    ),
  };
}

PaymentEnvironment _getEnvironment() {
  // Check if running in production mode
  return const bool.fromEnvironment('dart.vm.product')
      ? PaymentEnvironment.production
      : PaymentEnvironment.sandbox;
}
```

Run with environment variables:
```bash
flutter run --dart-define=STRIPE_KEY=pk_test_...
```

---

### Step 3: Configure Payment Providers

#### Stripe Setup

1. Create account: https://stripe.com
2. Get API keys from Dashboard → Developers → API keys
3. Add publishable key to your app:

```dart
PaymentProvider.stripe: ProviderConfig(
  enabled: true,
  credentials: {
    'publishableKey': 'pk_test_...',  // Test key
    // 'publishableKey': 'pk_live_...',  // Production key
  },
),
```

**Platform Setup:**

**Android** (`android/app/build.gradle`):
```gradle
android {
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}
```

**iOS** (`ios/Podfile`):
```ruby
platform :ios, '13.0'
```

---

#### PayPal Setup

1. Create account: https://developer.paypal.com
2. Create app in Dashboard
3. Get Client ID

```dart
PaymentProvider.paypal: ProviderConfig(
  enabled: true,
  credentials: {
    'clientId': 'your_client_id',
    'secret': 'your_secret',  // Server-side only!
  },
),
```

---

#### Razorpay Setup (India)

1. Create account: https://razorpay.com
2. Get API keys from Dashboard → Settings → API Keys

```dart
PaymentProvider.razorpay: ProviderConfig(
  enabled: true,
  credentials: {
    'apiKey': 'rzp_test_...',      // Test key
    // 'apiKey': 'rzp_live_...',   // Production key
  },
),
```

**Android** (`android/app/proguard-rules.pro`):
```
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keepattributes JavascriptInterface
```

---

#### Google Play Billing (Android IAP)

1. Setup Google Play Console
2. Create in-app products
3. Add dependency:

```yaml
dependencies:
  in_app_purchase: ^3.1.13
```

4. Configure:

```dart
PaymentProvider.googlePlay: ProviderConfig(
  enabled: true,
  credentials: {
    // No credentials needed - handled by Play Store
  },
),
```

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="com.android.vending.BILLING" />
```

---

#### Apple IAP (iOS)

1. Setup App Store Connect
2. Create in-app purchases
3. Add dependency:

```yaml
dependencies:
  in_app_purchase: ^3.1.13
```

4. Configure:

```dart
PaymentProvider.appleIAP: ProviderConfig(
  enabled: true,
  credentials: {
    // No credentials needed - handled by App Store
  },
),
```

**iOS** (`ios/Runner/Info.plist`):
No additional configuration needed.

---

## UPI Module Setup

### ⚠️ Important Requirements

- **Platform**: Android only
- **Min SDK**: 26 (Android 8.0+)
- **Requires**: Android platform code implementation
- **Region**: India only

---

### Step 1: Copy UPI Module

```bash
cp -r feature_test/payment/lib/upi_payment /path/to/your/project/lib/
```

---

### Step 2: Android Platform Setup

**Complete setup guide:** `upi_payment/PROCESS_SETUP.md`

#### Quick Overview:

1. **Add Method Channel** (`android/app/src/main/kotlin/MainActivity.kt`):

```kotlin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.yourapp/upi"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "initiatePayment" -> {
                        // Implement UPI payment logic
                        // See PROCESS_SETUP.md for complete implementation
                        result.notImplemented()
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
```

2. **Update AndroidManifest.xml**:

```xml
<manifest>
    <queries>
        <!-- UPI apps -->
        <package android:name="com.google.android.apps.nbu.paisa.user" />
        <package android:name="com.phonepe.app" />
        <package android:name="net.one97.paytm" />
        <package android:name="in.org.npci.upiapp" />
    </queries>
</manifest>
```

3. **Set Min SDK** (`android/app/build.gradle`):

```gradle
android {
    defaultConfig {
        minSdkVersion 26  // Required for UPI
    }
}
```

---

### Step 3: Test UPI Setup

```dart
import 'upi_payment/upi_payment.dart';
import 'package:uuid/uuid.dart';

Future<void> testUpi() async {
  final request = UpiPaymentRequest(
    payeeVpa: 'test@upi',
    payeeName: 'Test Merchant',
    transactionId: 'TXN_${Uuid().v4()}',
    transactionRef: 'REF_${DateTime.now().millisecondsSinceEpoch}',
    amount: 1.00,
    currency: 'INR',
  );

  print('UPI Request created: ${request.transactionId}');

  // Note: Requires Android implementation
  // See upi_payment/PROCESS_SETUP.md
}
```

---

## Onboarding Module Setup

### Step 1: Copy Onboarding Module

```bash
cp -r feature_test/payment/lib/onboarding /path/to/your/project/lib/
```

Verify structure:
```
your_project/
└── lib/
    └── onboarding/
        ├── onboarding.dart
        ├── models/
        ├── services/
        ├── widgets/
        └── templates/
```

---

### Step 2: Create Onboarding Pages

```dart
// lib/onboarding/app_onboarding_pages.dart
import 'package:flutter/material.dart';
import 'package:your_app/onboarding/onboarding.dart';

List<OnboardingPage> getAppOnboardingPages() {
  return [
    OnboardingPage.withIcon(
      title: 'Welcome',
      description: 'Welcome to our amazing app!',
      icon: Icons.waving_hand,
      iconColor: Colors.blue,
      backgroundColor: Colors.white,
    ),

    OnboardingPage.withImage(
      title: 'Feature 1',
      description: 'Discover our first amazing feature.',
      imagePath: 'assets/images/onboarding_1.png',
      backgroundColor: Colors.blue.shade50,
    ),

    OnboardingPage.withImage(
      title: 'Feature 2',
      description: 'Learn about another great feature.',
      imagePath: 'assets/images/onboarding_2.png',
      backgroundColor: Colors.green.shade50,
    ),

    OnboardingPage.withIcon(
      title: 'Get Started',
      description: 'Ready to begin your journey?',
      icon: Icons.check_circle,
      iconColor: Colors.green,
      backgroundColor: Colors.white,
    ),
  ];
}
```

---

### Step 3: Add Images (Optional)

If using image-based pages:

1. Add images to `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/images/onboarding_1.png
    - assets/images/onboarding_2.png
```

2. Place images in `assets/images/` directory

---

### Step 4: Initialize Onboarding Service

```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'onboarding/onboarding.dart';
import 'onboarding/app_onboarding_pages.dart';

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
            return _buildOnboarding(context);
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

  Widget _buildOnboarding(BuildContext context) {
    return OnboardingScreen(
      config: OnboardingConfig(
        pages: getAppOnboardingPages(),
        onComplete: () async {
          final service = OnboardingService(version: '1.0.0');
          await service.markComplete();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
          );
        },
        onSkip: () async {
          final service = OnboardingService(version: '1.0.0');
          await service.markComplete();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
          );
        },
        showSkipButton: true,
        skipButtonText: 'Skip',
        nextButtonText: 'Next',
        doneButtonText: 'Get Started',
      ),
    );
  }
}
```

---

### Step 5: Reset Onboarding (Development)

```dart
// For testing, reset onboarding
Future<void> resetOnboarding() async {
  final service = OnboardingService(version: '1.0.0');
  await service.initialize();
  await service.reset();
  print('Onboarding reset. Will show on next launch.');
}

// In your dev menu or debug screen:
ElevatedButton(
  onPressed: resetOnboarding,
  child: Text('Reset Onboarding'),
);
```

---

## Testing

### Test Payment Module

```dart
Future<void> testPayment() async {
  print('=== Testing Payment Module ===');

  // 1. Initialize
  await PaymentManager.initialize(
    PaymentConfig(
      providers: {
        PaymentProvider.mock: ProviderConfig(enabled: true),
      },
      defaultProvider: PaymentProvider.mock,
    ),
  );
  print('✅ Initialized');

  // 2. Process payment
  final request = PaymentRequest(
    amount: 9.99,
    currency: 'USD',
    description: 'Test Payment',
  );

  final result = await PaymentManager.instance.processPayment(request);

  if (result.isSuccess) {
    print('✅ Payment successful');
    print('   Transaction ID: ${result.transactionId}');
  } else {
    print('❌ Payment failed: ${result.error?.message}');
  }
}
```

Run:
```dart
// In main.dart or debug screen
ElevatedButton(
  onPressed: testPayment,
  child: Text('Test Payment'),
);
```

---

### Test UPI Module

```dart
Future<void> testUpi() async {
  print('=== Testing UPI Module ===');

  final request = UpiPaymentRequest(
    payeeVpa: 'test@upi',
    payeeName: 'Test Merchant',
    transactionId: 'TXN_TEST_123',
    transactionRef: 'REF_${DateTime.now().millisecondsSinceEpoch}',
    amount: 1.00,
    currency: 'INR',
  );

  print('✅ UPI Request created');
  print('   VPA: ${request.payeeVpa}');
  print('   Amount: ₹${request.amount}');
  print('   Txn ID: ${request.transactionId}');

  print('⚠️  Requires Android platform code');
  print('   See: upi_payment/PROCESS_SETUP.md');
}
```

---

### Test Onboarding Module

```dart
Future<void> testOnboarding() async {
  print('=== Testing Onboarding Module ===');

  final service = OnboardingService(version: '1.0.0');
  await service.initialize();

  final shouldShow = await service.shouldShowOnboarding();
  print('Should show onboarding: $shouldShow');

  if (!shouldShow) {
    print('Resetting onboarding...');
    await service.reset();
    print('✅ Onboarding reset');
  }

  print('✅ Onboarding module ready');
}
```

---

## Troubleshooting

### Payment Module Issues

#### ❌ "PaymentManager not initialized"

**Cause:** Trying to use PaymentManager before initialization.

**Fix:**
```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize BEFORE runApp
  await PaymentManager.initialize(config);

  runApp(MyApp());
}
```

---

#### ❌ "No payment provider available"

**Cause:** All providers are disabled or not configured.

**Fix:**
```dart
// Ensure at least one provider is enabled
PaymentConfig(
  providers: {
    PaymentProvider.mock: ProviderConfig(enabled: true),  // At least mock
  },
)
```

---

#### ❌ "Provider credentials missing"

**Cause:** API keys not provided for production providers.

**Fix:**
```dart
// Use environment variables
flutter run --dart-define=STRIPE_KEY=pk_test_...

// Check if key exists
final stripeKey = const String.fromEnvironment('STRIPE_KEY');
if (stripeKey.isEmpty) {
  print('Warning: STRIPE_KEY not provided');
}
```

---

### UPI Module Issues

#### ❌ "UPI not supported on this platform"

**Cause:** Running on iOS or web (UPI is Android-only).

**Fix:**
```dart
if (Platform.isAndroid) {
  // Show UPI option
} else {
  // Hide UPI option
}
```

---

#### ❌ "Method channel not implemented"

**Cause:** Android platform code not added.

**Fix:** Follow complete setup guide in `upi_payment/PROCESS_SETUP.md`

---

#### ❌ "Min SDK version too low"

**Cause:** Android SDK < 26.

**Fix:**
```gradle
// android/app/build.gradle
android {
    defaultConfig {
        minSdkVersion 26
    }
}
```

---

### Onboarding Module Issues

#### ❌ "Onboarding shows every time"

**Cause:** Not calling `markComplete()`.

**Fix:**
```dart
onComplete: () async {
  final service = OnboardingService(version: '1.0.0');
  await service.markComplete();  // Must call this

  Navigator.pushReplacement(...);
},
```

---

#### ❌ "Images not showing"

**Cause:** Assets not added to `pubspec.yaml`.

**Fix:**
```yaml
flutter:
  assets:
    - assets/images/
```

Then run:
```bash
flutter clean
flutter pub get
```

---

#### ❌ "SharedPreferences error"

**Cause:** Not initialized properly.

**Fix:**
```dart
final service = OnboardingService(version: '1.0.0');
await service.initialize();  // Must initialize first

final shouldShow = await service.shouldShowOnboarding();
```

---

## Production Checklist

### Payment Module
- [ ] Remove mock provider
- [ ] Add real provider credentials via environment variables
- [ ] NEVER commit API keys to version control
- [ ] Implement server-side payment verification
- [ ] Add error handling and logging
- [ ] Test with real provider (sandbox mode)
- [ ] Configure webhooks (for Stripe, etc.)
- [ ] Add receipt generation
- [ ] Implement refund flow
- [ ] Test subscription flows
- [ ] Add payment analytics
- [ ] Configure for production environment
- [ ] Test on physical devices

### UPI Module
- [ ] Complete Android platform implementation
- [ ] Test with all major UPI apps
- [ ] Implement server verification
- [ ] Add transaction logging
- [ ] Test deep linking
- [ ] Handle UPI app not installed
- [ ] Add timeout handling
- [ ] Test on physical Android devices
- [ ] Add analytics tracking

### Onboarding Module
- [ ] Create final onboarding pages
- [ ] Add high-quality images/icons
- [ ] Test on different screen sizes
- [ ] Verify persistence works
- [ ] Add analytics tracking
- [ ] Test skip functionality
- [ ] Version onboarding properly
- [ ] Test on physical devices
- [ ] Ensure smooth animations

### General
- [ ] Add comprehensive error handling
- [ ] Implement logging
- [ ] Add analytics
- [ ] Test on iOS and Android
- [ ] Test edge cases
- [ ] Performance testing
- [ ] Security audit
- [ ] User acceptance testing

---

**Setup complete! Ready for production!**
