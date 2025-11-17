// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:applock/main.dart';

void main() {
  testWidgets('App Lock Example app smoke test', (WidgetTester tester) async {
    // Create test app lock manager
    final appLockManager = AppLockManager(
      config: const AppLockConfig(
        pinMinLength: 4,
        maxAttempts: 5,
        lockoutDuration: Duration(minutes: 5),
        autoLockTimeout: Duration(seconds: 30),
        allowBiometrics: true,
      ),
    );
    await appLockManager.initialize();

    // Build our app and trigger a frame.
    await tester.pumpWidget(AppLockExampleApp(manager: appLockManager));

    // Verify that the app builds successfully.
    expect(find.byType(AppLockExampleApp), findsOneWidget);
  });
}
