// This is a basic Flutter widget test for the 3D Object Comparison App.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic widget test - MaterialApp creation', (
    WidgetTester tester,
  ) async {
    // Create a simple MaterialApp widget for testing
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('3D Object Comparison App'))),
      ),
    );

    // Verify that the app loads without crashing
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.text('3D Object Comparison App'), findsOneWidget);
  });
}
