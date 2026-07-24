import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:foodbridge/app.dart';

void main() {
  testWidgets('FoodLinkApp builds', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: FoodLinkApp(),
      ),
    );
    await tester.pump();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
