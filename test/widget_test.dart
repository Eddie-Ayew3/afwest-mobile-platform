import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:afwest_guard_app/main.dart';

void main() {
  testWidgets('Guard app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: GuardApp(),
      ),
    );

    // Verify that the app loads
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
