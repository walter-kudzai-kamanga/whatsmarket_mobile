import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mutswe/main.dart';

void main() {
  testWidgets('home screen loads nearby services', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Nearby Services'), findsOneWidget);
    expect(find.text('Moyo Plumbing'), findsOneWidget);
    expect(find.text('Bright Spark Electric'), findsOneWidget);
  });
}
