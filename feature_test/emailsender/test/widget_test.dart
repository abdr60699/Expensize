import 'package:flutter_test/flutter_test.dart';
import 'package:emailsender/main.dart';

void main() {
  testWidgets('EmailSenderApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const EmailSenderApp());

    // Verify that the app loads
    expect(find.text('Email Configuration'), findsOneWidget);
  });
}
