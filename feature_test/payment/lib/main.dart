/// Payment & Onboarding Module - Example Application
///
/// This app demonstrates three key modules:
/// 1. Payment Integration (Stripe, PayPal, Razorpay, In-App Purchases)
/// 2. UPI Payment (Indian UPI payment system - Android only)
/// 3. Onboarding (App intro and walkthrough screens)
///
/// IMPORTANT: This is a demonstration app showing the module architecture.
/// To use actual payment providers, you'll need to:
/// - Set up provider accounts (Stripe, PayPal, Razorpay)
/// - Configure API keys
/// - Implement platform-specific code (especially for UPI)
/// - Follow the setup guides in each module's directory

import 'package:flutter/material.dart';
import 'onboarding/onboarding.dart';
import 'payment/payment.dart';
import 'upi_payment/upi_payment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize onboarding service
  final onboardingService = OnboardingService(version: '1.0.0');
  await onboardingService.initialize();

  runApp(PaymentModuleApp(onboardingService: onboardingService));
}

class PaymentModuleApp extends StatelessWidget {
  final OnboardingService onboardingService;

  const PaymentModuleApp({super.key, required this.onboardingService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Payment & Onboarding Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: FutureBuilder<bool>(
        future: onboardingService.shouldShowOnboarding(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Show onboarding if needed
          if (snapshot.data == true) {
            return OnboardingDemoScreen(
              onComplete: () async {
                await onboardingService.markComplete();
                // Navigate to main app
              },
            );
          }

          // Show main app
          return const MainAppScreen();
        },
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Onboarding Demo Screen
class OnboardingDemoScreen extends StatelessWidget {
  final VoidCallback onComplete;

  const OnboardingDemoScreen({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    final config = OnboardingConfig(
      pages: [
        OnboardingPage.withIcon(
          title: 'Welcome to Payment Demo',
          description:
              'Comprehensive payment integration module for Flutter with support for multiple providers.',
          icon: Icons.payment_rounded,
          iconColor: Colors.indigo,
          backgroundColor: Colors.indigo.shade50,
        ),
        OnboardingPage.withIcon(
          title: 'Multiple Payment Methods',
          description:
              'Support for Stripe, PayPal, Razorpay, and native in-app purchases (Google Play & App Store).',
          icon: Icons.credit_card,
          iconColor: Colors.green,
          backgroundColor: Colors.green.shade50,
        ),
        OnboardingPage.withIcon(
          title: 'UPI Payments (India)',
          description:
              'Integrated UPI payment support for Indian market with Google Pay, PhonePe, Paytm, and more.',
          icon: Icons.account_balance_wallet,
          iconColor: Colors.orange,
          backgroundColor: Colors.orange.shade50,
        ),
        OnboardingPage.withIcon(
          title: 'Ready to Start',
          description:
              'All modules are ready for testing. Configure your provider credentials to enable live payments.',
          icon: Icons.rocket_launch,
          iconColor: Colors.purple,
          backgroundColor: Colors.purple.shade50,
        ),
      ],
      onComplete: () {
        onComplete();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainAppScreen()),
        );
      },
      showSkipButton: true,
      onSkip: () {
        onComplete();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainAppScreen()),
        );
      },
    );

    return OnboardingScreen(config: config);
  }
}

/// Main Application Screen
class MainAppScreen extends StatelessWidget {
  const MainAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment & Onboarding Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Integration Modules',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This app demonstrates three powerful modules for Flutter applications.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Payment Module Section
          _buildSectionTitle(context, 'Payment Module'),
          const SizedBox(height: 8),
          _buildModuleCard(
            context,
            icon: Icons.payment,
            iconColor: Colors.indigo,
            title: 'Payment Integration',
            description: 'Stripe, PayPal, Razorpay, In-App Purchases',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PaymentDemoScreen()),
            ),
          ),
          const SizedBox(height: 16),

          // UPI Payment Section
          _buildSectionTitle(context, 'UPI Payment (India)'),
          const SizedBox(height: 8),
          _buildModuleCard(
            context,
            icon: Icons.account_balance_wallet,
            iconColor: Colors.orange,
            title: 'UPI Payment Integration',
            description: 'Google Pay, PhonePe, BHIM, Paytm, Amazon Pay',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const UpiPaymentDemoScreen()),
            ),
          ),
          const SizedBox(height: 16),

          // Onboarding Section
          _buildSectionTitle(context, 'Onboarding'),
          const SizedBox(height: 8),
          _buildModuleCard(
            context,
            icon: Icons.tour,
            iconColor: Colors.purple,
            title: 'Onboarding Module',
            description: 'App intro and walkthrough screens',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => OnboardingDemoScreen(onComplete: () {})),
            ),
          ),
          const SizedBox(height: 24),

          // Features Card
          Card(
            color: Colors.blue.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Key Features',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '• Multiple payment providers with unified API\n'
                    '• Native in-app purchases (iOS & Android)\n'
                    '• UPI integration for Indian market\n'
                    '• One-time payments and subscriptions\n'
                    '• Receipt validation and refund support\n'
                    '• Customizable onboarding screens\n'
                    '• Persistent completion tracking\n'
                    '• Mock providers for testing',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.2),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

/// Payment Module Demo Screen
class PaymentDemoScreen extends StatelessWidget {
  const PaymentDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Integration'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 32),
                  const SizedBox(height: 16),
                  Text(
                    'Payment Integration Module',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This module provides a unified API for multiple payment providers. '
                    'Configure your provider credentials to enable live payments.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildProviderCard(
            'Mock Payment Provider',
            'For testing without real credentials',
            Icons.science,
            Colors.grey,
          ),
          _buildProviderCard(
            'Stripe',
            'Credit/debit cards, Apple Pay, Google Pay',
            Icons.credit_card,
            Colors.indigo,
          ),
          _buildProviderCard(
            'PayPal',
            'PayPal account payments',
            Icons.paypal,
            Colors.blue,
          ),
          _buildProviderCard(
            'Razorpay',
            'Popular in India - cards, UPI, wallets',
            Icons.account_balance,
            Colors.deepPurple,
          ),
          _buildProviderCard(
            'Google Play Billing',
            'In-app purchases (Android)',
            Icons.android,
            Colors.green,
          ),
          _buildProviderCard(
            'Apple IAP',
            'In-app purchases (iOS)',
            Icons.apple,
            Colors.grey,
          ),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Setup Required',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'To use live payment providers:\n'
                    '1. Create accounts with desired providers\n'
                    '2. Get API keys/credentials\n'
                    '3. Configure in PaymentConfig\n'
                    '4. Implement provider-specific setup\n\n'
                    'See payment/README.md for details.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(
    String name,
    String description,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(name),
        subtitle: Text(description),
        trailing: const Chip(label: Text('Configure')),
      ),
    );
  }
}

/// UPI Payment Demo Screen
class UpiPaymentDemoScreen extends StatelessWidget {
  const UpiPaymentDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UPI Payment'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.account_balance_wallet,
                      color: Colors.orange.shade700, size: 32),
                  const SizedBox(height: 16),
                  Text(
                    'UPI Payment Integration',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Unified Payments Interface (UPI) is an instant payment system for India. '
                    'This module supports all major UPI apps.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildUpiAppCard('Google Pay', Icons.g_mobiledata, Colors.green),
          _buildUpiAppCard('PhonePe', Icons.phone_android, Colors.purple),
          _buildUpiAppCard('Paytm', Icons.account_balance_wallet, Colors.blue),
          _buildUpiAppCard('BHIM', Icons.account_balance, Colors.indigo),
          _buildUpiAppCard('Amazon Pay', Icons.shop, Colors.orange),
          _buildUpiAppCard('Any UPI App', Icons.apps, Colors.grey),
          const SizedBox(height: 16),
          const Card(
            color: Colors.red,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Platform Requirements',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    '⚠️ Android Only: UPI is India-specific\n'
                    '⚠️ Min SDK 26 (Android 8.0+)\n'
                    '⚠️ Platform Code Required: Android method channel implementation needed\n'
                    '⚠️ Setup Required: Follow upi_payment/PROCESS_SETUP.md\n\n'
                    'This is a comprehensive module but requires platform-specific code.',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Features',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Automatic UPI app detection\n'
                    '• Payment via deep linking\n'
                    '• Response parsing & validation\n'
                    '• Server verification hooks\n'
                    '• Transaction management\n'
                    '• User-friendly UI components',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpiAppCard(String name, IconData icon, Color color) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(name),
        trailing: const Icon(Icons.check_circle_outline, color: Colors.green),
      ),
    );
  }
}
