// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:payment/main.dart';
import 'package:payment/onboarding/services/onboarding_service.dart';

void main() {
  testWidgets('Payment module app smoke test', (WidgetTester tester) async {
    // Initialize onboarding service for testing
    final onboardingService = OnboardingService(version: '1.0.0');
    await onboardingService.initialize();

    // Build our app and trigger a frame.
    await tester.pumpWidget(PaymentModuleApp(onboardingService: onboardingService));

    // Wait for async operations
    await tester.pumpAndSettle();

    // Verify that the app loads
    expect(find.text('Payment & Onboarding Demo'), findsWidgets);
  });
}
