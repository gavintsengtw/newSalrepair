// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:construction_client/main.dart';

void main() {
  testWidgets('App launch smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Note: This test will fail if .env loading or Provider setup is not handled correctly in test environment.
    // Ideally we should mock dependencies, but for now we just want to ensure it doesn't crash on launch.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify that we are at least showing something (likely login page or loading)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
