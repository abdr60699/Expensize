/// Payment Integration Module
///
/// A comprehensive payment integration module supporting multiple payment
/// providers (Stripe, PayPal, Razorpay) and native in-app purchases
/// (Google Play Billing, Apple IAP).
///
/// ## Features
/// - One-time payments and subscriptions
/// - Multiple payment providers with unified API
/// - Receipt validation
/// - Refund support
/// - Runtime provider configuration
/// - Comprehensive error handling
///
/// ## Quick Start
///
/// ```dart
/// // 1. Initialize
/// await PaymentManager.initialize(config);
///
/// // 2. Process payment
/// final result = await PaymentManager.instance.processPayment(request);
///
/// // 3. Handle result
/// if (result.isSuccess) {
///   print('Payment successful: ${result.transactionId}');
/// }
/// ```
///
/// See [README.md](README.md) for complete documentation.
library payment;

// Core exports
export 'config/payment_config.dart';
export 'config/provider_config.dart';

// Models
export 'models/payment_models.dart';

// Exceptions
export 'exceptions/payment_exceptions.dart';

// Services
export 'services/payment_manager.dart';

// Providers (base interface)
export 'providers/base/payment_provider_interface.dart';

// Mock provider (for testing)
export 'providers/mock/mock_payment_provider.dart';
