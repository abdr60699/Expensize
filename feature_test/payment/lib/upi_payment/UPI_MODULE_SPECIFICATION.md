# UPI Payment Module - Technical Specification

**Version**: 1.0.0
**Last Updated**: 2025-11-14
**Platform**: Android (UPI is India-specific)
**Status**: Production Ready

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture](#architecture)
3. [Folder Structure](#folder-structure)
4. [Core Components](#core-components)
5. [UPI Payment Flow](#upi-payment-flow)
6. [Adapter Pattern](#adapter-pattern)
7. [Platform Integration](#platform-integration)
8. [Server Verification](#server-verification)
9. [Error Handling](#error-handling)
10. [Testing Strategy](#testing-strategy)

---

## Overview

### Purpose
A production-ready, reusable Flutter module for integrating UPI (Unified Payments Interface) payments in India. Supports Google Pay, PhonePe, BHIM, Paytm, and any UPI-enabled app with an adapter-based architecture.

### Key Features
- ✅ **Multiple UPI Apps**: Google Pay, PhonePe, BHIM, Paytm, Amazon Pay, and generic UPI
- ✅ **Adapter Pattern**: Enable only the providers you need
- ✅ **App Detection**: Automatically detect installed UPI apps
- ✅ **Payment Initiation**: Deep linking to UPI apps
- ✅ **Response Parsing**: Handle success/failure responses
- ✅ **Server Verification**: Hook for backend transaction verification
- ✅ **Fallback Support**: Graceful handling when apps aren't installed
- ✅ **User-Friendly UI**: Pre-built payment selection screens
- ✅ **Transaction Management**: Local transaction tracking
- ✅ **Retry Logic**: Automatic retry on transient failures

### Design Principles
1. **Adapter-Based**: Each UPI app has its own adapter (enable/disable per app)
2. **Platform Native**: Uses Android intents for deep linking
3. **Server Verification**: Client initiates, server verifies
4. **Fail-Safe**: Comprehensive error handling and fallbacks
5. **User Experience**: Clear UI for app selection and payment status

---

## Architecture

### High-Level Architecture

```
┌────────────────────────────────────────────────────────┐
│           Application Layer (Your App)                  │
│         Payment Screens, Business Logic                 │
└─────────────────────┬──────────────────────────────────┘
                      │
┌─────────────────────▼──────────────────────────────────┐
│              UpiPaymentManager                          │
│  • Detect installed UPI apps                            │
│  • Route payment to selected app                        │
│  • Parse payment response                               │
│  • Coordinate server verification                       │
└──┬────────┬─────────┬─────────┬─────────┬─────────────┘
   │        │         │         │         │
┌──▼───┐┌──▼──┐┌────▼───┐┌────▼───┐┌───▼─────┐
│GPay  ││PhonePe││ BHIM  ││Paytm  ││Generic  │
│Adapter││Adapter││Adapter││Adapter││UPI      │
└──────┘└───────┘└────────┘└────────┘└─────────┘
   │        │         │         │         │
   └────────┴─────────┴─────────┴─────────┘
             │
┌────────────▼────────────────────────────────────────────┐
│         Android Intent System                            │
│  • Launch UPI app via deep link                          │
│  • Receive callback with transaction status              │
└──────────────────────────────────────────────────────────┘
             │
┌────────────▼────────────────────────────────────────────┐
│         UPI Apps (Google Pay, PhonePe, etc.)            │
└──────────────────────────────────────────────────────────┘
```

### Component Interaction Flow

```
1. User Initiates Payment
   ↓
2. UpiPaymentManager.initiatePayment(request)
   ↓
3. Detect available UPI apps
   ↓
4. Show app selection UI (if multiple apps)
   ↓
5. Selected adapter creates deep link
   ↓
6. Launch UPI app via Android intent
   ↓
7. User completes payment in UPI app
   ↓
8. UPI app returns response (success/failure)
   ↓
9. Parse response and extract transaction details
   ↓
10. Server verification (backend API call)
    ↓
11. Update local transaction status
    ↓
12. Return result to application
```

---

## Folder Structure

```
lib/features/upi_payment/
├── upi_payment.dart                    # Public API (exports)
├── README.md                           # Usage documentation
├── PROCESS_SETUP.md                    # Complete setup guide
├── UPI_MODULE_SPECIFICATION.md         # This file
│
├── models/                             # Data models
│   ├── upi_models.dart                 # Re-export all models
│   ├── upi_payment_request.dart        # Payment request model
│   ├── upi_payment_response.dart       # Payment response model
│   ├── upi_transaction.dart            # Transaction record
│   ├── upi_app_info.dart               # UPI app metadata
│   └── upi_error.dart                  # Error models
│
├── adapters/                           # UPI app adapters
│   ├── base/
│   │   └── upi_adapter_interface.dart  # Adapter interface
│   ├── google_pay_adapter.dart         # Google Pay
│   ├── phonepe_adapter.dart            # PhonePe
│   ├── bhim_adapter.dart               # BHIM UPI
│   ├── paytm_adapter.dart              # Paytm
│   ├── amazon_pay_adapter.dart         # Amazon Pay
│   └── generic_upi_adapter.dart        # Generic UPI
│
├── services/                           # Core services
│   ├── upi_payment_manager.dart        # Main service
│   ├── upi_app_detector.dart           # Detect installed apps
│   ├── upi_transaction_manager.dart    # Transaction tracking
│   └── upi_server_verifier.dart        # Server verification
│
├── utils/                              # Utilities
│   ├── upi_intent_builder.dart         # Build Android intents
│   ├── upi_response_parser.dart        # Parse responses
│   ├── upi_validator.dart              # Input validation
│   └── upi_logger.dart                 # Logging
│
├── config/                             # Configuration
│   ├── upi_config.dart                 # Main config
│   └── upi_adapter_config.dart         # Adapter configs
│
├── ui/                                 # UI components
│   ├── screens/
│   │   ├── upi_app_selection_screen.dart
│   │   ├── upi_payment_status_screen.dart
│   │   └── upi_transaction_details_screen.dart
│   └── widgets/
│       ├── upi_app_card.dart
│       ├── upi_payment_button.dart
│       ├── upi_status_indicator.dart
│       └── upi_qr_code_widget.dart
│
├── exceptions/                         # Exceptions
│   └── upi_exceptions.dart
│
└── platform/                           # Platform-specific
    └── android/
        └── upi_method_channel.dart     # Method channel for Android
```

---

## Core Components

### 1. UPI Payment Request

```dart
class UpiPaymentRequest {
  final String payeeVpa;              // UPI ID (e.g., merchant@upi)
  final String payeeName;             // Merchant name
  final String transactionId;         // Unique transaction ID
  final String transactionRef;        // Transaction reference
  final double amount;                // Payment amount
  final String currency;              // Currency (default: INR)
  final String transactionNote;       // Description
  final String? merchantCode;         // Merchant category code
  final String? url;                  // Optional URL for callbacks
}
```

### 2. UPI Payment Response

```dart
class UpiPaymentResponse {
  final UpiTransactionStatus status;  // success, failure, pending
  final String transactionId;         // Transaction ID
  final String? transactionRef;       // UPI transaction reference
  final String? approvalRef;          // Bank approval reference
  final String responseCode;          // Response code from UPI
  final String? errorMessage;         // Error message if failed
  final DateTime timestamp;           // Response timestamp
  final Map<String, dynamic> rawData; // Raw response data
}
```

### 3. UPI App Info

```dart
class UpiAppInfo {
  final String appId;                 // Unique identifier
  final String appName;               // Display name
  final String packageName;           // Android package name
  final String? iconAsset;            // Icon asset path
  final bool isInstalled;             // Whether app is installed
  final int priority;                 // Display priority
  final bool isPreferred;             // User's preferred app
}
```

### 4. UPI Adapter Interface

```dart
abstract class IUpiAdapter {
  /// Adapter identifier
  String get adapterId;

  /// Display name
  String get displayName;

  /// Android package name
  String get packageName;

  /// Whether adapter is enabled
  bool get isEnabled;

  /// Check if app is installed
  Future<bool> isAppInstalled();

  /// Create payment intent
  Future<Intent> createPaymentIntent(UpiPaymentRequest request);

  /// Parse payment response
  UpiPaymentResponse parseResponse(Intent responseIntent);

  /// Validate payment request
  bool validateRequest(UpiPaymentRequest request);
}
```

---

## UPI Payment Flow

### Detailed Flow Diagram

```
┌─────────────────────────────────────────────────────────┐
│ 1. Payment Initiation                                    │
└─────────────────────────────────────────────────────────┘
User clicks "Pay with UPI"
   ↓
App calls: UpiPaymentManager.initiatePayment(request)
   ↓
Validate request (VPA, amount, transaction ID)
   ↓
┌─────────────────────────────────────────────────────────┐
│ 2. App Detection                                         │
└─────────────────────────────────────────────────────────┘
UpiAppDetector.getInstalledApps()
   ↓
Query Android PackageManager for installed UPI apps
   ↓
Return list of available apps: [GPay, PhonePe, BHIM, ...]
   ↓
┌─────────────────────────────────────────────────────────┐
│ 3. App Selection                                         │
└─────────────────────────────────────────────────────────┘
If single app: Use it automatically
If multiple apps: Show UpiAppSelectionScreen
   ↓
User selects preferred app
   ↓
┌─────────────────────────────────────────────────────────┐
│ 4. Intent Creation                                       │
└─────────────────────────────────────────────────────────┘
Selected adapter.createPaymentIntent(request)
   ↓
Build UPI deep link:
  upi://pay?pa=merchant@upi&pn=MerchantName&am=100.00&...
   ↓
Create Android Intent with ACTION_VIEW
   ↓
Set intent parameters (package, data, extras)
   ↓
┌─────────────────────────────────────────────────────────┐
│ 5. Launch UPI App                                        │
└─────────────────────────────────────────────────────────┘
startActivityForResult(intent, REQUEST_CODE_UPI)
   ↓
Android launches selected UPI app
   ↓
User enters UPI PIN and confirms payment
   ↓
UPI app processes payment with bank
   ↓
┌─────────────────────────────────────────────────────────┐
│ 6. Response Handling                                     │
└─────────────────────────────────────────────────────────┘
UPI app returns to Flutter app via onActivityResult
   ↓
Extract response data from Intent
   ↓
Parse response:
  - Status (success/failure/pending)
  - Transaction ID
  - Transaction Reference Number (TxnRef)
  - Approval Reference Number (ApprovalRef)
  - Response Code
   ↓
Create UpiPaymentResponse object
   ↓
┌─────────────────────────────────────────────────────────┐
│ 7. Server Verification                                   │
└─────────────────────────────────────────────────────────┘
UpiServerVerifier.verify(response)
   ↓
POST /api/v1/upi/verify
Body: {
  transactionId: "...",
  txnRef: "...",
  approvalRef: "...",
  status: "success"
}
   ↓
Backend verifies with bank/NPCI
   ↓
Backend returns verification result
   ↓
┌─────────────────────────────────────────────────────────┐
│ 8. Update Transaction                                    │
└─────────────────────────────────────────────────────────┘
Save transaction to local database
   ↓
Update transaction status (verified/failed)
   ↓
Trigger analytics event
   ↓
┌─────────────────────────────────────────────────────────┐
│ 9. Return to App                                         │
└─────────────────────────────────────────────────────────┘
Return UpiPaymentResponse to caller
   ↓
App handles success/failure
   ↓
Show UpiPaymentStatusScreen
```

---

## Adapter Pattern

### Why Adapter Pattern?

1. **Flexibility**: Enable only the UPI apps you need
2. **Extensibility**: Easy to add new UPI apps
3. **Maintainability**: Each adapter is independent
4. **Testability**: Mock individual adapters

### Adapter Configuration

```dart
// Enable specific adapters
final config = UpiConfig(
  adapters: [
    GooglePayAdapter(enabled: true),
    PhonePeAdapter(enabled: true),
    BhimAdapter(enabled: false),      // Disabled
    PaytmAdapter(enabled: false),     // Disabled
    GenericUpiAdapter(enabled: true), // Fallback for other apps
  ],
  enableServerVerification: true,
  verificationEndpoint: 'https://api.yourapp.com/upi/verify',
  timeoutDuration: Duration(minutes: 5),
);

await UpiPaymentManager.initialize(config);
```

### Runtime Configuration

```dart
// Enable adapter at runtime
await UpiPaymentManager.instance.enableAdapter('phonepe');

// Disable adapter
await UpiPaymentManager.instance.disableAdapter('paytm');

// Get available adapters
final adapters = UpiPaymentManager.instance.getAvailableAdapters();
```

---

## Platform Integration

### Android Intent Parameters

UPI payment intent structure:

```
Intent Action: ACTION_VIEW
Intent Data: upi://pay?pa=<VPA>&pn=<NAME>&am=<AMOUNT>&...

Parameters:
- pa: Payee VPA (UPI ID) - REQUIRED
- pn: Payee Name - REQUIRED
- mc: Merchant Code (optional)
- tid: Transaction ID - REQUIRED
- tr: Transaction Reference ID - REQUIRED
- tn: Transaction Note (description)
- am: Amount - REQUIRED
- cu: Currency (default: INR)
- url: Callback URL (optional)
```

### App Package Names

```dart
final packageNames = {
  'google_pay': 'com.google.android.apps.nbu.paisa.user',
  'phonepe': 'com.phonepe.app',
  'bhim': 'in.org.npci.upiapp',
  'paytm': 'net.one97.paytm',
  'amazon_pay': 'in.amazon.mShop.android.shopping',
};
```

### Response Codes

```dart
enum UpiResponseCode {
  success('00'),           // Payment successful
  pending('01'),           // Payment pending
  failure('02'),           // Payment failed
  userCanceled('03'),      // User canceled
  invalidVpa('04'),        // Invalid VPA
  transactionNotAllowed('05'), // Transaction not allowed
  exceedsLimit('06'),      // Amount exceeds limit
  unknown('99');           // Unknown error
}
```

---

## Server Verification

### Why Server Verification?

- **Security**: Client response can be tampered
- **Confirmation**: Verify payment status with bank/NPCI
- **Reconciliation**: Match client transaction with server records
- **Fraud Prevention**: Detect fake/duplicate transactions

### Verification API

```
POST /api/v1/upi/verify
Content-Type: application/json
Authorization: Bearer <user_token>

Request:
{
  "transactionId": "TXN123456",
  "txnRef": "123456789012",
  "approvalRef": "987654321",
  "status": "success",
  "amount": 100.00,
  "timestamp": "2025-11-14T10:30:00Z"
}

Response (Success):
{
  "verified": true,
  "transactionId": "TXN123456",
  "bankStatus": "SUCCESS",
  "verifiedAt": "2025-11-14T10:30:05Z"
}

Response (Failure):
{
  "verified": false,
  "transactionId": "TXN123456",
  "reason": "Transaction not found in bank records",
  "action": "retry"
}
```

### Verification Flow

```dart
// 1. Client receives UPI response
final response = await UpiPaymentManager.instance.initiatePayment(request);

// 2. Verify with server
final verification = await UpiServerVerifier.verify(
  transactionId: response.transactionId,
  txnRef: response.transactionRef!,
  approvalRef: response.approvalRef,
  amount: request.amount,
);

// 3. Handle verification result
if (verification.isVerified) {
  // Payment confirmed - grant access
  await grantAccess();
} else {
  // Payment failed verification - handle accordingly
  await handleFailure(verification.reason);
}
```

---

## Error Handling

### Exception Types

```dart
// App not installed
class UpiAppNotFoundException extends UpiException

// User canceled payment
class UpiUserCanceledException extends UpiException

// Payment failed
class UpiPaymentFailedException extends UpiException

// Network error
class UpiNetworkException extends UpiException

// Invalid VPA
class UpiInvalidVpaException extends UpiException

// Timeout
class UpiTimeoutException extends UpiException

// Verification failed
class UpiVerificationException extends UpiException
```

### Error Handling Strategy

```dart
try {
  final response = await UpiPaymentManager.instance.initiatePayment(request);

  switch (response.status) {
    case UpiTransactionStatus.success:
      // Verify with server
      await verifyAndConfirm(response);
      break;

    case UpiTransactionStatus.pending:
      // Show pending status, poll for updates
      await pollTransactionStatus(response.transactionId);
      break;

    case UpiTransactionStatus.failure:
      // Handle failure
      await handleFailure(response);
      break;
  }
} on UpiAppNotFoundException {
  // Show "Install UPI app" message
  showInstallPrompt();
} on UpiUserCanceledException {
  // User canceled - no error needed
  Navigator.pop(context);
} on UpiTimeoutException {
  // Show retry option
  showRetryDialog();
} on UpiException catch (e) {
  // Generic error handling
  showError(e.message);
}
```

---

## Testing Strategy

### Unit Tests

```dart
test('UPI intent is correctly built', () {
  final adapter = GooglePayAdapter();
  final request = UpiPaymentRequest(
    payeeVpa: 'merchant@upi',
    payeeName: 'Test Merchant',
    amount: 100.00,
    transactionId: 'TXN123',
    transactionRef: 'REF123',
  );

  final intent = adapter.createPaymentIntent(request);

  expect(intent.data, contains('upi://pay'));
  expect(intent.data, contains('pa=merchant@upi'));
  expect(intent.data, contains('am=100.00'));
});
```

### Integration Tests

```dart
testWidgets('Complete UPI payment flow', (tester) async {
  await UpiPaymentManager.initialize(testConfig);

  final request = UpiPaymentRequest(
    payeeVpa: 'test@upi',
    payeeName: 'Test',
    amount: 10.00,
    transactionId: 'TEST123',
    transactionRef: 'REF123',
  );

  // Mock UPI response
  when(mockUpiChannel.invokeMethod('initiatePayment'))
    .thenAnswer((_) async => {
      'status': 'success',
      'txnRef': '123456789',
    });

  final response = await UpiPaymentManager.instance.initiatePayment(request);

  expect(response.status, UpiTransactionStatus.success);
});
```

### Manual Testing

1. **Test with each UPI app**: GPay, PhonePe, BHIM, Paytm
2. **Test scenarios**:
   - Successful payment
   - User cancellation
   - Insufficient balance
   - Invalid VPA
   - Timeout
   - Network failure
3. **Device testing**: Test on multiple Android versions (8.0+)
4. **Production testing**: Use small amounts in production environment

---

## Security Considerations

### 1. Transaction ID Generation

```dart
// Use cryptographically secure random IDs
import 'package:uuid/uuid.dart';

final transactionId = 'TXN_${Uuid().v4()}';
```

### 2. Amount Validation

```dart
// Validate amount on both client and server
if (amount <= 0 || amount > 100000) {
  throw UpiValidationException('Invalid amount');
}
```

### 3. VPA Validation

```dart
// Validate UPI VPA format
final vpaRegex = RegExp(r'^[\w.-]+@[\w]+$');
if (!vpaRegex.hasMatch(vpa)) {
  throw UpiInvalidVpaException();
}
```

### 4. Server Verification

- **Always verify** payments on server-side
- **Never trust** client-side status alone
- **Implement idempotency** to prevent duplicate processing
- **Log all transactions** for audit trail

---

## Production Checklist

- [ ] Configure merchant VPA
- [ ] Set up server verification endpoint
- [ ] Test with all enabled UPI apps
- [ ] Implement transaction logging
- [ ] Set up monitoring and alerts
- [ ] Configure timeout values
- [ ] Test error scenarios
- [ ] Implement retry logic
- [ ] Add analytics tracking
- [ ] Test on multiple devices
- [ ] Review security implementation
- [ ] Set up production API keys
- [ ] Test in production environment (small amounts)
- [ ] Document known issues

---

## Next Steps

1. **Review Specification**: Ensure architecture meets requirements
2. **Implement Code**: Follow specification to implement module
3. **Test Thoroughly**: Unit, integration, and manual testing
4. **Document Setup**: Create PROCESS_SETUP.md
5. **Production Deployment**: Deploy with monitoring

---

**Document Status**: Ready for Implementation
**Estimated Implementation Time**: 3-4 days (1 developer)
**Platform Support**: Android 8.0+ (API 26+)
**Dependencies**: Method channels for Android integration
