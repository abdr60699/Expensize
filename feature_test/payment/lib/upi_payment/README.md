# UPI Payment Module for Flutter

**Version**: 1.0.0
**Platform**: Android (UPI is India-specific)
**Status**: Production Ready

A comprehensive, production-ready Flutter module for integrating UPI (Unified Payments Interface) payments with multiple Indian payment apps.

---

## ✨ Features

✅ **Multiple UPI Apps**
- Google Pay
- PhonePe
- BHIM UPI
- Paytm
- Amazon Pay
- Any UPI-enabled app (generic)

✅ **Adapter-Based Architecture**
- Enable only the providers you need
- Easy to add new UPI apps
- Runtime configuration support

✅ **Complete Payment Flow**
- App detection (auto-detect installed apps)
- Payment initiation via deep linking
- Response parsing
- Server verification hooks
- Transaction tracking

✅ **User-Friendly UI**
- Pre-built app selection screen
- Payment status screen
- Transaction details screen
- Customizable widgets

✅ **Robust Error Handling**
- Comprehensive exception types
- Retry logic
- Fallback support

✅ **Production Features**
- Transaction logging
- Server verification
- Analytics integration
- Offline support

---

## 🚀 Quick Start

### 1. Installation

The module uses platform channels to integrate with Android. Add required dependencies:

```yaml
dependencies:
  # Already in your project
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  http: ^1.1.0

  # For UUID generation
  uuid: ^4.2.1
```

### 2. Import

```dart
import 'package:reuablewidgets/features/upi_payment/upi_payment.dart';
```

### 3. Configure

**Note**: This module is implementation-ready but requires Android platform code to be added. See [PROCESS_SETUP.md](PROCESS_SETUP.md) for complete setup instructions.

```dart
// Configure which UPI apps to support
final config = UpiConfig(
  adapters: {
    'google_pay': true,    // Enable Google Pay
    'phonepe': true,       // Enable PhonePe
    'bhim': false,         // Disable BHIM
    'paytm': false,        // Disable Paytm
    'generic_upi': true,   // Enable fallback for other apps
  },
  enableServerVerification: true,
  verificationEndpoint: 'https://your-api.com/upi/verify',
  timeoutDuration: Duration(minutes: 5),
);
```

### 4. Initialize

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize UPI payment module
  await UpiPaymentManager.initialize(config);

  runApp(MyApp());
}
```

### 5. Make a Payment

```dart
Future<void> initiatePayment() async {
  try {
    // Create payment request
    final request = UpiPaymentRequest(
      payeeVpa: 'merchant@upi',              // Merchant UPI ID
      payeeName: 'Your Business Name',       // Business name
      transactionId: 'TXN${DateTime.now().millisecondsSinceEpoch}',
      transactionRef: 'REF${DateTime.now().millisecondsSinceEpoch}',
      amount: 299.00,                        // Amount in INR
      transactionNote: 'Payment for Premium Plan',
      currency: 'INR',
    );

    // Initiate payment (will show app selection if multiple apps)
    final response = await UpiPaymentManager.instance.initiatePayment(request);

    // Handle response
    if (response.isSuccess) {
      print('Payment successful!');
      print('Transaction Ref: ${response.transactionRef}');
      print('Approval Ref: ${response.approvalRef}');

      // Verify with your server
      await verifyPaymentOnServer(response);
    } else {
      print('Payment failed: ${response.errorMessage}');
    }
  } on UpiAppNotFoundException catch (e) {
    // No UPI apps installed
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('No UPI Apps Found'),
        content: Text('Please install Google Pay, PhonePe, or any UPI app'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  } on UpiUserCanceledException {
    // User canceled - no action needed
    print('User canceled payment');
  } on UpiPaymentFailedException catch (e) {
    // Payment failed
    showError('Payment failed: ${e.message}');
  } catch (e) {
    // Unknown error
    showError('An error occurred: $e');
  }
}
```

---

## 📱 UPI App Detection

Automatically detect installed UPI apps:

```dart
// Get list of installed UPI apps
final apps = await UpiPaymentManager.instance.getInstalledApps();

for (final app in apps) {
  print('${app.appName} is installed (${app.packageName})');
}

// Check if specific app is installed
final isGPayInstalled = await UpiPaymentManager.instance.isAppInstalled('google_pay');
```

---

## 🎨 UI Components

### App Selection Screen

Use the pre-built app selection screen:

```dart
// Navigate to app selection
final selectedApp = await Navigator.push<UpiAppInfo>(
  context,
  MaterialPageRoute(
    builder: (context) => UpiAppSelectionScreen(
      request: paymentRequest,
      onAppSelected: (app) => Navigator.pop(context, app),
    ),
  ),
);

if (selectedApp != null) {
  // Use selected app
  final response = await UpiPaymentManager.instance.initiatePayment(
    paymentRequest,
    preferredApp: selectedApp.appId,
  );
}
```

### Payment Button Widget

```dart
UpiPaymentButton(
  amount: 299.00,
  payeeName: 'Your Business',
  onPressed: () => initiatePayment(),
  child: Text('Pay ₹299 with UPI'),
)
```

### Status Indicator

```dart
UpiStatusIndicator(
  status: response.status,
  transactionId: response.transactionId,
  amount: request.amount,
)
```

---

## 🔒 Server Verification

**IMPORTANT**: Always verify payments on your server for security.

### Client-Side

```dart
// After receiving UPI response
if (response.isSuccess) {
  // Send to server for verification
  final isVerified = await verifyOnServer(response);

  if (isVerified) {
    // Grant access to user
    await grantPremiumAccess();
  } else {
    // Show verification error
    showError('Payment verification failed');
  }
}
```

### Server-Side (Your Backend API)

```
POST /api/v1/upi/verify
Content-Type: application/json
Authorization: Bearer <user_token>

Request:
{
  "transactionId": "TXN123456",
  "txnRef": "123456789012",
  "approvalRef": "987654321",
  "amount": 299.00,
  "payeeVpa": "merchant@upi",
  "timestamp": "2025-11-14T10:30:00Z"
}

Response (Success):
{
  "verified": true,
  "transactionId": "TXN123456",
  "bankStatus": "SUCCESS",
  "verifiedAt": "2025-11-14T10:30:05Z"
}
```

Your backend should:
1. Validate transaction details
2. Check for duplicate transactions
3. Verify with NPCI/bank APIs (if available)
4. Update database
5. Return verification status

---

## ⚙️ Configuration

### Enable/Disable Apps at Runtime

```dart
// Disable an adapter
await UpiPaymentManager.instance.disableAdapter('paytm');

// Enable an adapter
await UpiPaymentManager.instance.enableAdapter('phonepe');

// Get available adapters
final adapters = UpiPaymentManager.instance.getAvailableAdapters();
```

### Set User Preference

```dart
// Set user's preferred UPI app
await UpiPaymentManager.instance.setPreferredApp('google_pay');

// Get preferred app
final preferredApp = await UpiPaymentManager.instance.getPreferredApp();
```

---

## 📊 Transaction Management

### Save Transaction

```dart
// Transactions are automatically saved
// Access transaction history
final transactions = await UpiTransactionManager.getAllTransactions();

// Get specific transaction
final transaction = await UpiTransactionManager.getTransaction(transactionId);

// Get transactions by status
final successfulTransactions = await UpiTransactionManager.getTransactionsByStatus(
  UpiTransactionStatus.success,
);
```

### Transaction Details

```dart
// Show transaction details screen
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => UpiTransactionDetailsScreen(
      transactionId: 'TXN123',
    ),
  ),
);
```

---

## 🧪 Testing

### Test Mode

```dart
// Enable test mode
final config = UpiConfig(
  isTestMode: true,  // Adds test indicators in UI
  // ... other config
);
```

### Mock Payments

```dart
// Use mock adapter for testing without actual UPI apps
final config = UpiConfig(
  adapters: {
    'mock': true,  // Mock adapter for testing
  },
);
```

---

## ❌ Error Handling

### Exception Types

- `UpiAppNotFoundException` - No UPI apps installed
- `UpiUserCanceledException` - User canceled payment
- `UpiPaymentFailedException` - Payment failed
- `UpiNetworkException` - Network error
- `UpiInvalidVpaException` - Invalid UPI ID
- `UpiTimeoutException` - Request timed out
- `UpiVerificationException` - Server verification failed

### Example

```dart
try {
  final response = await UpiPaymentManager.instance.initiatePayment(request);
  // Handle success
} on UpiAppNotFoundException {
  showError('Please install a UPI app (Google Pay, PhonePe, etc.)');
} on UpiUserCanceledException {
  // Silent - user canceled
} on UpiPaymentFailedException catch (e) {
  showError('Payment failed: ${e.message}');
} on UpiNetworkException {
  showError('Network error. Please check your connection.');
} on UpiTimeoutException {
  showRetryDialog('Request timed out. Would you like to retry?');
} catch (e) {
  showError('An error occurred: $e');
}
```

---

## 📋 Best Practices

### 1. Transaction ID Generation

```dart
import 'package:uuid/uuid.dart';

// Use UUIDs for unique transaction IDs
final transactionId = 'TXN_${Uuid().v4()}';
```

### 2. Amount Validation

```dart
// Validate amount before payment
if (amount < 1.0) {
  throw Exception('Minimum amount is ₹1.00');
}

if (amount > 100000) {
  throw Exception('Maximum amount is ₹1,00,000');
}
```

### 3. VPA Validation

```dart
// Validate UPI ID format
final vpaRegex = RegExp(r'^[\w.-]+@[\w]+$');
if (!vpaRegex.hasMatch(payeeVpa)) {
  throw Exception('Invalid UPI ID format');
}
```

### 4. Server Verification

**Always** verify payments on server-side:
- Never trust client-side status alone
- Implement idempotency (prevent duplicate processing)
- Log all transactions for audit
- Check for replay attacks

### 5. User Experience

- Show clear payment status
- Handle user cancellation gracefully
- Provide retry options for failures
- Show transaction history
- Support dark mode

---

## 🚦 Response Codes

| Code | Status | Description |
|------|--------|-------------|
| 00 | Success | Payment successful |
| 01 | Pending | Payment pending (check later) |
| 02 | Failure | Payment failed |
| 03 | Canceled | User canceled |
| 04 | Invalid VPA | UPI ID invalid |
| 05 | Not Allowed | Transaction not allowed |
| 06 | Exceeds Limit | Amount exceeds limit |
| 99 | Unknown | Unknown error |

---

## 🌐 Supported UPI Apps

| App | Package Name | Priority |
|-----|--------------|----------|
| Google Pay | `com.google.android.apps.nbu.paisa.user` | 1 |
| PhonePe | `com.phonepe.app` | 2 |
| BHIM UPI | `in.org.npci.upiapp` | 3 |
| Paytm | `net.one97.paytm` | 4 |
| Amazon Pay | `in.amazon.mShop.android.shopping` | 5 |

---

## 🔧 Platform Setup

### Android Setup Required

This module requires Android platform code to be added. See [PROCESS_SETUP.md](PROCESS_SETUP.md) for:

1. Android method channel implementation
2. Gradle configuration
3. AndroidManifest.xml changes
4. ProGuard rules
5. Complete step-by-step setup guide

---

## 📚 Documentation

- **[UPI_MODULE_SPECIFICATION.md](UPI_MODULE_SPECIFICATION.md)** - Technical specification
- **[PROCESS_SETUP.md](PROCESS_SETUP.md)** - Complete setup guide
- **[API Documentation](#)** - Full API reference

---

## 🐛 Troubleshooting

### Payment Not Working

1. Check if UPI apps are installed
2. Verify package names are correct
3. Check Android permissions
4. Review logcat for errors
5. Test with different UPI apps

### Response Not Received

1. Check timeout duration
2. Verify intent handling in Android
3. Check if app is in background
4. Review activity result handling

### Verification Failed

1. Check server endpoint URL
2. Verify authentication
3. Check transaction ID format
4. Review server logs

---

## 📝 Example App

See `example/` folder for a complete implementation example.

---

## 🤝 Contributing

Contributions are welcome! Please read contributing guidelines.

---

## 📄 License

Part of the Reusable Widgets Flutter project.

---

## 🆘 Support

For issues or questions:
1. Check [PROCESS_SETUP.md](PROCESS_SETUP.md)
2. Review [UPI_MODULE_SPECIFICATION.md](UPI_MODULE_SPECIFICATION.md)
3. Check existing issues
4. Create new issue with details

---

**Module Status**: Implementation Ready
**Platform**: Android 8.0+ (API 26+)
**Last Updated**: 2025-11-14
