import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plan2shop/main.dart';

void main() {
  testWidgets('Login screen UI test', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const Plan2ShopApp());

    // Ensure the login button exists instead of matching just the text
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);

    // Verify email and password fields exist
    expect(find.byType(TextField), findsNWidgets(2));
  });
}
