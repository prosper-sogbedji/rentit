import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rentit/main.dart';

void main() {
  testWidgets('RentIt app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const RentItApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
