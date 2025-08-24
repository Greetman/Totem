import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:totem/main.dart';

void main() {
  testWidgets('App shows loading page initially', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the loading page is shown initially
    expect(find.text('TOTEM'), findsOneWidget);
    expect(find.text('Loading your journey...'), findsOneWidget);
  });

  testWidgets('App shows sign in page after loading', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for loading to complete
    await tester.pump(const Duration(seconds: 3));

    // Verify that the sign in page is shown
    expect(find.text('Sign in to continue your fitness journey'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);
  });

  testWidgets('Sign in form validation works', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Wait for loading to complete
    await tester.pump(const Duration(seconds: 3));

    // Try to sign in without filling fields
    await tester.tap(find.text('Sign In'));
    await tester.pump();

    // Should show validation errors
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });
}
