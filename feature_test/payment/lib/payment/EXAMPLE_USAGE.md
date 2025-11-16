# Payment Module - Example Usage

Complete examples demonstrating all features of the Payment Integration Module.

---

## Table of Contents

1. [Basic Setup](#basic-setup)
2. [One-Time Payments](#one-time-payments)
3. [Subscriptions](#subscriptions)
4. [In-App Purchases](#in-app-purchases)
5. [Refunds](#refunds)
6. [Error Handling](#error-handling)
7. [UI Examples](#ui-examples)

---

## Basic Setup

### Step 1: Create Configuration File

Create `assets/config/payment_config.json`:

```json
{
  "providers": {
    "stripe": {
      "enabled": true,
      "environment": "sandbox",
      "publishableKey": "pk_test_YOUR_STRIPE_KEY",
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
    "google_play": {
      "enabled": true,
      "autoConsume": true,
      "enablePendingPurchases": true
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

### Step 2: Initialize in main.dart

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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payment Demo',
      home: PaymentDemoScreen(),
    );
  }
}
```

---

## One-Time Payments

### Example 1: Simple Payment

```dart
import 'package:flutter/material.dart';
import 'package:reuablewidgets/features/payment/payment.dart';

class SimplePaymentScreen extends StatelessWidget {
  Future<void> _processPayment(BuildContext context) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      // Create payment request
      final request = PaymentRequest(
        amount: 29.99,
        currency: 'USD',
        description: 'Premium Feature Unlock',
        customer: Customer(
          email: 'user@example.com',
          name: 'John Doe',
        ),
      );

      // Process payment
      final result = await PaymentManager.instance.processPayment(request);

      // Dismiss loading
      Navigator.pop(context);

      // Handle result
      if (result.isSuccess) {
        _showSuccessDialog(context, result);
      } else {
        _showErrorDialog(context, result.error?.message);
      }
    } on PaymentException catch (e) {
      Navigator.pop(context);
      _showErrorDialog(context, e.message);
    }
  }

  void _showSuccessDialog(BuildContext context, PaymentResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Successful!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transaction ID: ${result.transactionId}'),
            SizedBox(height: 8),
            Text('Amount: \$${result.amount}'),
            SizedBox(height: 8),
            if (result.receiptUrl != null)
              TextButton(
                onPressed: () {
                  // Open receipt URL
                },
                child: Text('View Receipt'),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String? message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Failed'),
        content: Text(message ?? 'An error occurred'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Make Payment')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _processPayment(context),
          child: Text('Pay \$29.99'),
        ),
      ),
    );
  }
}
```

### Example 2: Payment with Provider Selection

```dart
class PaymentWithProviderSelectionScreen extends StatefulWidget {
  @override
  _PaymentWithProviderSelectionScreenState createState() =>
      _PaymentWithProviderSelectionScreenState();
}

class _PaymentWithProviderSelectionScreenState
    extends State<PaymentWithProviderSelectionScreen> {
  String? _selectedProvider;
  List<ProviderInfo> _availableProviders = [];

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  void _loadProviders() {
    setState(() {
      _availableProviders = PaymentManager.instance.getAvailableProviders();
      if (_availableProviders.isNotEmpty) {
        _selectedProvider = _availableProviders.first.providerId;
      }
    });
  }

  Future<void> _processPayment() async {
    if (_selectedProvider == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a payment provider')),
      );
      return;
    }

    try {
      final request = PaymentRequest(
        amount: 49.99,
        currency: 'USD',
        description: 'Annual Subscription',
        customer: Customer(
          email: 'user@example.com',
          name: 'Jane Smith',
        ),
      );

      final result = await PaymentManager.instance.processPayment(
        request,
        preferredProviderId: _selectedProvider,
      );

      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment successful! ${result.transactionId}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on PaymentException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Payment Method')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Choose Payment Provider',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            SizedBox(height: 16),
            ..._availableProviders.map((provider) {
              return RadioListTile<String>(
                title: Text(provider.providerName),
                subtitle: Text(
                  'Supports: ${provider.supportedCurrencies.take(3).join(", ")}',
                ),
                value: provider.providerId,
                groupValue: _selectedProvider,
                onChanged: (value) {
                  setState(() {
                    _selectedProvider = value;
                  });
                },
              );
            }).toList(),
            Spacer(),
            ElevatedButton(
              onPressed: _processPayment,
              child: Text('Pay \$49.99'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Subscriptions

### Example 3: Create Subscription

```dart
class SubscriptionScreen extends StatelessWidget {
  Future<void> _createSubscription(BuildContext context) async {
    try {
      final request = SubscriptionRequest(
        planId: 'monthly_premium',
        customerId: 'user_12345',
        trialDays: 7, // 7-day free trial
      );

      final result = await PaymentManager.instance.createSubscription(
        request,
        preferredProviderId: 'stripe',
      );

      if (result.success) {
        final sub = result.subscription;

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Subscription Created!'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Plan: ${sub.planId}'),
                Text('Status: ${sub.status.name}'),
                if (sub.isTrialing)
                  Text('Trial ends: ${sub.trialEndDate}'),
                Text('Next billing: ${sub.nextBillingDate}'),
                Text('Amount: \$${sub.amount} ${sub.currency}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    } on PaymentException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Subscribe')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _createSubscription(context),
          child: Text('Start 7-Day Free Trial'),
        ),
      ),
    );
  }
}
```

### Example 4: Subscription Management

```dart
class SubscriptionManagementScreen extends StatefulWidget {
  final String subscriptionId;
  final String providerId;

  SubscriptionManagementScreen({
    required this.subscriptionId,
    required this.providerId,
  });

  @override
  _SubscriptionManagementScreenState createState() =>
      _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState
    extends State<SubscriptionManagementScreen> {
  Subscription? _subscription;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    try {
      final provider = PaymentManager.instance.getProvider(widget.providerId);
      if (provider != null) {
        final sub = await provider.getSubscription(widget.subscriptionId);
        setState(() {
          _subscription = sub;
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading subscription')),
      );
    }
  }

  Future<void> _cancelSubscription() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Subscription?'),
        content: Text('Your subscription will remain active until the end of the current billing period.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await PaymentManager.instance.cancelSubscription(
          widget.subscriptionId,
          widget.providerId,
          reason: CancellationReason.userRequested,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Subscription canceled successfully')),
        );

        _loadSubscription(); // Reload to show updated status
      } on PaymentException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text('Subscription')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_subscription == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Subscription')),
        body: Center(child: Text('Subscription not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Manage Subscription')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard('Plan', _subscription!.planId),
            _buildInfoCard('Status', _subscription!.status.name),
            _buildInfoCard('Amount', '\$${_subscription!.amount} ${_subscription!.currency}'),
            _buildInfoCard('Billing Interval', _subscription!.interval.name),
            _buildInfoCard('Next Billing Date', _subscription!.nextBillingDate.toString().split(' ')[0]),
            _buildInfoCard('Days Remaining', '${_subscription!.daysRemaining}'),

            if (_subscription!.isTrialing)
              _buildInfoCard('Trial Ends', _subscription!.trialEndDate.toString().split(' ')[0]),

            Spacer(),

            if (_subscription!.isActive)
              ElevatedButton(
                onPressed: _cancelSubscription,
                child: Text('Cancel Subscription'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  minimumSize: Size(double.infinity, 48),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(value),
          ],
        ),
      ),
    );
  }
}
```

---

## In-App Purchases

### Example 5: IAP Purchase Flow

```dart
import 'dart:io' show Platform;

class IAPPurchaseScreen extends StatelessWidget {
  Future<void> _purchaseProduct(BuildContext context) async {
    try {
      // Determine provider based on platform
      final providerId = Platform.isAndroid ? 'google_play' : 'apple_iap';

      // Create payment request
      final request = PaymentRequest(
        amount: 0, // Amount determined by store
        currency: 'USD',
        description: 'Premium Upgrade',
        orderId: 'com.yourapp.premium', // Product SKU
        preferredMethod: PaymentMethod.inAppPurchase,
      );

      // Process purchase
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
          // Grant access to premium features
          await _grantPremiumAccess(validation);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Purchase successful! Welcome to Premium!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw PaymentException(
            message: 'Receipt validation failed: ${validation.errorMessage}',
          );
        }
      }
    } on UserCanceledPaymentException {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Purchase canceled')),
      );
    } on PaymentException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Purchase failed: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _grantPremiumAccess(ReceiptValidation validation) async {
    // Save purchase to local storage
    // Update user's premium status
    // Sync with backend
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upgrade to Premium')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star, size: 100, color: Colors.amber),
            SizedBox(height: 24),
            Text(
              'Premium Features',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            Text('✓ Ad-free experience'),
            Text('✓ Unlimited downloads'),
            Text('✓ Priority support'),
            Text('✓ Exclusive content'),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _purchaseProduct(context),
              child: Text('Upgrade for \$9.99'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Refunds

### Example 6: Process Refund

```dart
class RefundScreen extends StatelessWidget {
  final String transactionId;
  final String providerId;
  final double originalAmount;

  RefundScreen({
    required this.transactionId,
    required this.providerId,
    required this.originalAmount,
  });

  Future<void> _processRefund(
    BuildContext context,
    double? amount,
  ) async {
    try {
      final refundResult = await PaymentManager.instance.refundTransaction(
        transactionId,
        providerId,
        amount: amount, // null for full refund
      );

      if (refundResult.success) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Refund Processed'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Refund ID: ${refundResult.refundTransaction.transactionId}'),
                Text('Amount: \$${refundResult.refundTransaction.amount}'),
                Text('Status: ${refundResult.refundTransaction.status.name}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      } else {
        throw PaymentException(message: refundResult.error ?? 'Refund failed');
      }
    } on RefundFailedException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Refund failed: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Process Refund')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Transaction: $transactionId',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8),
            Text('Original Amount: \$${originalAmount}'),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _processRefund(context, null),
              child: Text('Full Refund (\$${originalAmount})'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _processRefund(context, originalAmount / 2),
              child: Text('Partial Refund (\$${originalAmount / 2})'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Error Handling

### Example 7: Comprehensive Error Handling

```dart
Future<void> _processPaymentWithErrorHandling(BuildContext context) async {
  try {
    final request = PaymentRequest(
      amount: 99.99,
      currency: 'USD',
      description: 'Test payment',
    );

    final result = await PaymentManager.instance.processPayment(request);

    if (result.isSuccess) {
      _showSuccess(context, result);
    }
  } on PaymentDeclinedException catch (e) {
    _showError(
      context,
      'Card Declined',
      'Your payment method was declined. Please try a different card.',
    );
  } on PaymentNetworkException catch (e) {
    _showError(
      context,
      'Network Error',
      'Please check your internet connection and try again.',
      canRetry: true,
    );
  } on PaymentValidationException catch (e) {
    _showError(
      context,
      'Invalid Payment Details',
      e.message,
    );
  } on UserCanceledPaymentException catch (e) {
    // User canceled - just dismiss, no error
    Navigator.pop(context);
  } on CurrencyNotSupportedException catch (e) {
    _showError(
      context,
      'Currency Not Supported',
      'This payment provider does not support ${e.currency}. Please select another provider.',
    );
  } on PaymentTimeoutException catch (e) {
    _showError(
      context,
      'Request Timeout',
      'The payment request timed out. Please try again.',
      canRetry: true,
    );
  } on PaymentException catch (e) {
    _showError(
      context,
      'Payment Error',
      e.message,
    );
  } catch (e) {
    _showError(
      context,
      'Unexpected Error',
      'An unexpected error occurred. Please contact support.',
    );
  }
}

void _showError(
  BuildContext context,
  String title,
  String message, {
  bool canRetry = false,
}) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        if (canRetry)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _processPaymentWithErrorHandling(context); // Retry
            },
            child: Text('Retry'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}

void _showSuccess(BuildContext context, PaymentResult result) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Success!'),
      content: Text('Payment completed successfully.\nTransaction ID: ${result.transactionId}'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}
```

---

For more examples and detailed documentation, see [README.md](README.md) and [PAYMENT_MODULE_SPECIFICATION.md](PAYMENT_MODULE_SPECIFICATION.md).
