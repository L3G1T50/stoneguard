// widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidneyshield/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(integrityOk: true));
    // The splash screen renders
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
