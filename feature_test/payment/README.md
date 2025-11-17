# Payment & Onboarding Modules

A comprehensive Flutter application demonstrating three production-ready modules for payment integration, UPI payments, and app onboarding.

## Modules Included

### 1. 💳 Payment Integration Module
Complete payment solution supporting multiple providers with a unified API.

**Supported Providers:**
- Stripe (cards, Apple Pay, Google Pay)
- PayPal
- Razorpay (India)
- Google Play Billing (Android IAP)
- Apple IAP (iOS)
- Mock Provider (for testing)

**Features:**
- One-time payments
- Subscription management
- Receipt validation
- Refund support
- Unified API across providers
- Comprehensive error handling

### 2. 🇮🇳 UPI Payment Module (India-specific)
Native UPI payment integration for Indian market.

**Supported Apps:**
- Google Pay
- PhonePe
- Paytm
- BHIM
- Amazon Pay
- Any UPI-enabled app

**Features:**
- Automatic app detection
- Deep linking for payments
- Response parsing & validation
- Server verification hooks
- Transaction management
- User-friendly UI components

**⚠️ Platform Requirements:**
- Android only (UPI is India-specific)
- Min SDK: 26 (Android 8.0+)
- Requires platform-specific code implementation

### 3. 🚀 Onboarding Module
Beautiful, customizable onboarding screens for first-time users.

**Features:**
- Customizable intro slides
- Icon and image support
- Persistent completion tracking
- Skip functionality
- Swipe gestures
- Page indicators
- Analytics integration ready
- Multiple templates

## Quick Start

### 1. Install Dependencies

```bash
cd path/to/payment
flutter pub get
```

### 2. Run the App

```bash
flutter run
```

The app will:
- Show onboarding on first launch
- Navigate to main screen after completion
- Display all three modules for testing

## Dependencies (Latest Versions)

```yaml
dependencies:
  cupertino_icons: ^1.0.6
  uuid: ^4.5.2
  shared_preferences: ^2.5.3
  permission_handler: ^12.0.1
```

## Documentation

📖 **[TESTING_GUIDE.md](TESTING_GUIDE.md)** - Comprehensive testing guide with:
- Feature checklists
- Manual test scenarios
- Integration examples
- Troubleshooting
- Module documentation links

### Module-Specific Documentation

**Payment Module:**
- [payment/README.md](lib/payment/README.md) - Complete module docs
- [payment/EXAMPLE_USAGE.md](lib/payment/EXAMPLE_USAGE.md) - Code examples
- [payment/TESTING_GUIDE.md](lib/payment/TESTING_GUIDE.md) - Testing guide
- [payment/INTEGRATION.md](lib/payment/INTEGRATION.md) - Integration instructions

**UPI Payment:**
- [upi_payment/README.md](lib/upi_payment/README.md) - Overview
- [upi_payment/PROCESS_SETUP.md](lib/upi_payment/PROCESS_SETUP.md) - Setup guide
- [upi_payment/UPI_MODULE_SPECIFICATION.md](lib/upi_payment/UPI_MODULE_SPECIFICATION.md) - Technical spec
- [upi_payment/EXAMPLE.md](lib/upi_payment/EXAMPLE.md) - Usage examples

**Onboarding:**
- [onboarding/README.md](lib/onboarding/README.md) - Module documentation
- [onboarding/EXAMPLE.md](lib/onboarding/EXAMPLE.md) - Usage examples
- [onboarding/templates/](lib/onboarding/templates/) - Pre-built templates

## Usage Examples

### Payment Integration

```dart
import 'package:payment/payment/payment.dart';

// Initialize
final config = PaymentConfig(
  providers: {
    PaymentProvider.mock: ProviderConfig(enabled: true),
  },
);
await PaymentManager.initialize(config);

// Process payment
final request = PaymentRequest(
  amount: 9.99,
  currency: 'USD',
  description: 'Premium Plan',
);

final result = await PaymentManager.instance.processPayment(request);

if (result.isSuccess) {
  print('Payment successful: ${result.transactionId}');
}
```

### UPI Payment

```dart
import 'package:payment/upi_payment/upi_payment.dart';
import 'package:uuid/uuid.dart';

final request = UpiPaymentRequest(
  payeeVpa: 'merchant@upi',
  payeeName: 'Your Business',
  transactionId: 'TXN_${Uuid().v4()}',
  amount: 299.00,
  currency: 'INR',
);

// Note: Requires platform-specific implementation
// See upi_payment/PROCESS_SETUP.md
```

### Onboarding

```dart
import 'package:payment/onboarding/onboarding.dart';

// Create pages
final pages = [
  OnboardingPage.withIcon(
    title: 'Welcome',
    description: 'Welcome to our app!',
    icon: Icons.waving_hand,
    iconColor: Colors.blue,
  ),
  // Add more pages...
];

// Configure
final config = OnboardingConfig(
  pages: pages,
  onComplete: () => navigateToHome(),
  showSkipButton: true,
);

// Show onboarding
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => OnboardingScreen(config: config),
  ),
);
```

### Onboarding with Persistence

```dart
// Initialize service
final service = OnboardingService(version: '1.0.0');
await service.initialize();

// Check and show
if (await service.shouldShowOnboarding()) {
  showOnboarding();
  await service.markComplete();
} else {
  goToHome();
}
```

## Architecture

```
lib/
├── payment/                # Payment integration module
│   ├── config/            # Configuration
│   ├── models/            # Data models
│   ├── providers/         # Provider implementations
│   ├── services/          # Payment manager
│   └── exceptions/        # Error handling
├── upi_payment/           # UPI payment module
│   ├── models/            # UPI models
│   └── exceptions/        # UPI errors
├── onboarding/            # Onboarding module
│   ├── models/            # Models
│   ├── services/          # Persistence & analytics
│   ├── widgets/           # UI components
│   └── templates/         # Templates
└── main.dart             # Demo app
```

## Features

### Payment Module
- ✅ Multiple payment providers
- ✅ Unified API
- ✅ Stripe, PayPal, Razorpay
- ✅ In-app purchases (iOS & Android)
- ✅ Subscriptions
- ✅ Receipt validation
- ✅ Refund support
- ✅ Mock provider for testing

### UPI Payment Module
- ✅ All major UPI apps
- ✅ Automatic app detection
- ✅ Deep linking
- ✅ Transaction management
- ✅ Server verification
- ⚠️ Requires platform code (Android)

### Onboarding Module
- ✅ Customizable pages
- ✅ Icon and image support
- ✅ Persistent tracking
- ✅ Skip functionality
- ✅ Swipe gestures
- ✅ Page indicators
- ✅ Analytics ready

## Platform Support

### Android
- ✅ Payment module (demo)
- ✅ UPI payment (with setup)
- ✅ Onboarding
- ✅ Permissions

### iOS
- ✅ Payment module (demo)
- ❌ UPI payment (Android only)
- ✅ Onboarding
- ✅ Permissions

### Web
- ✅ Payment module (demo)
- ❌ UPI payment
- ✅ Onboarding (limited)

## Testing

The app includes a comprehensive demo showing all three modules:

1. **First Launch** - Shows onboarding with 4 slides
2. **Main Screen** - Access all three modules
3. **Payment Demo** - View all payment providers
4. **UPI Demo** - See UPI integration details
5. **Re-run Onboarding** - Test onboarding again

See [TESTING_GUIDE.md](TESTING_GUIDE.md) for complete testing instructions.

## Setup for Production

### Payment Providers

To enable live payments, you need to:

1. **Create Provider Accounts**
   - Stripe: https://stripe.com
   - PayPal: https://developer.paypal.com
   - Razorpay: https://razorpay.com

2. **Get API Keys**
   - Follow provider documentation
   - Get test and production keys

3. **Configure in App**
   ```dart
   PaymentConfig(
     providers: {
       PaymentProvider.stripe: ProviderConfig(
         enabled: true,
         credentials: {
           'publishableKey': 'pk_live_...',
           'secretKey': 'sk_live_...', // Server-side only!
         },
       ),
     },
   );
   ```

4. **Platform Setup**
   - See individual provider documentation
   - Configure platform-specific requirements

### UPI Integration

For UPI payments, follow the complete setup guide:

📖 [upi_payment/PROCESS_SETUP.md](lib/upi_payment/PROCESS_SETUP.md)

**Key Steps:**
1. Add Android method channel code
2. Configure AndroidManifest.xml
3. Implement UPI intent handling
4. Add deep linking support
5. Test with UPI apps

## Security

### ✅ Implemented
- Mock payment provider for safe testing
- No credentials in code
- Persistent storage for state
- Permission handling

### ⚠️ For Production
- **NEVER** commit API keys
- Use environment variables
- Server-side payment verification
- HTTPS for all API calls
- Follow PCI compliance
- Implement proper logging

## Troubleshooting

**Onboarding shows every time**
- Check `OnboardingService.markComplete()` is called
- Verify shared_preferences is working

**UPI not working**
- UPI is Android-only
- Requires platform code (see PROCESS_SETUP.md)
- Min SDK 26 required

**Payment providers show "Configure"**
- Expected in demo mode
- Need provider accounts and API keys
- See payment/README.md

See [TESTING_GUIDE.md](TESTING_GUIDE.md) for more troubleshooting.

## Status

**Ready for Testing** ✅

All modules are implemented and working in demo mode. Configure provider credentials for live payments.

---

**Last Updated**: November 16, 2025
**Flutter SDK**: 3.4.1+
**Dependencies**: Latest stable versions
**License**: MIT
