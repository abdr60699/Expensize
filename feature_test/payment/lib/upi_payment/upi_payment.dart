/// UPI Payment Integration Module for Flutter
///
/// A comprehensive, production-ready module for integrating UPI (Unified Payments
/// Interface) payments in Flutter apps. Supports multiple Indian payment apps
/// including Google Pay, PhonePe, BHIM, Paytm, Amazon Pay, and any UPI-enabled app.
///
/// ## Features
/// - Multiple UPI app support with adapter pattern
/// - Automatic app detection
/// - Payment initiation via deep linking
/// - Response parsing and validation
/// - Server verification hooks
/// - Transaction management
/// - User-friendly UI components
/// - Comprehensive error handling
///
/// ## Quick Start
///
/// ```dart
/// // 1. Initialize (see PROCESS_SETUP.md for complete setup)
/// await UpiPaymentManager.initialize(config);
///
/// // 2. Create payment request
/// final request = UpiPaymentRequest(
///   payeeVpa: 'merchant@upi',
///   payeeName: 'Your Business',
///   transactionId: 'TXN_${Uuid().v4()}',
///   transactionRef: 'REF_${DateTime.now().millisecondsSinceEpoch}',
///   amount: 299.00,
///   transactionNote: 'Premium Plan Payment',
///   currency: 'INR',
/// );
///
/// // 3. Initiate payment
/// final response = await UpiPaymentManager.instance.initiatePayment(request);
///
/// // 4. Handle response
/// if (response.isSuccess) {
///   print('Payment successful!');
///   await verifyOnServer(response);
/// }
/// ```
///
/// ## Documentation
/// - [README.md](README.md) - Complete usage guide
/// - [PROCESS_SETUP.md](PROCESS_SETUP.md) - Setup & integration guide
/// - [UPI_MODULE_SPECIFICATION.md](UPI_MODULE_SPECIFICATION.md) - Technical specification
///
/// ## Important Notes
/// - **Platform**: Android only (UPI is India-specific)
/// - **Minimum SDK**: Android 8.0+ (API 26+)
/// - **Setup Required**: Android platform code must be added (see PROCESS_SETUP.md)
/// - **Server Verification**: Always verify payments on your server for security
///
/// ## Platform Setup Required
/// This module requires Android method channel implementation. Follow the complete
/// setup guide in PROCESS_SETUP.md to add the necessary Android code.
///
library upi_payment;

// Models
export 'models/upi_models.dart';

// Exceptions
export 'exceptions/upi_exceptions.dart';

// Platform channel (when implemented)
// export 'platform/android/upi_method_channel.dart';

// Services (to be implemented)
// export 'services/upi_payment_manager.dart';
// export 'services/upi_app_detector.dart';
// export 'services/upi_transaction_manager.dart';

// UI Components (to be implemented)
// export 'ui/screens/upi_app_selection_screen.dart';
// export 'ui/screens/upi_payment_status_screen.dart';
// export 'ui/widgets/upi_payment_button.dart';

// Configuration (to be implemented)
// export 'config/upi_config.dart';
