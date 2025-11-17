// This is a basic Flutter widget test for AI/ML Demo app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ai_ml/main.dart';

void main() {
  testWidgets('AI/ML Demo app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AiMlDemoApp());

    // Verify that the app title is present
    expect(find.text('AI/ML Module Demo'), findsOneWidget);
  });
}
