// This is a basic Flutter widget test.

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_glowup_app/main.dart';

void main() {
  testWidgets('App starts with SplashPage', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GlowUpApp());

    // Verify that the app starts properly
    expect(find.text('GlowUp Clinic'), findsOneWidget);
  });
}
