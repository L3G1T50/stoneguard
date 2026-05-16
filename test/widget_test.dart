import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kidneyshield/main.dart';

void main() {
  testWidgets('MyApp smoke test — renders without crashing',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    // The app should mount without throwing.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
