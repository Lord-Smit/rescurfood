import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodbridge/app.dart';

void main() {
  testWidgets('FoodBridgeApp builds', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FoodBridgeApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
