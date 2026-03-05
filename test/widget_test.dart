// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:driver_lagbe/app.dart';

void main() {
  testWidgets('Login page renders and opens signup role page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DriverLagbeApp());

    expect(find.text('Driver Lagbe'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);

    final signUpFinder = find.text('Sign up');
    await tester.ensureVisible(signUpFinder);
    await tester.tap(signUpFinder);
    await tester.pumpAndSettle();

    expect(find.text('Are you a driver or a rider?'), findsOneWidget);
    expect(find.text('I am a Rider'), findsOneWidget);
    expect(find.text('I am a Driver'), findsOneWidget);
  });
}
