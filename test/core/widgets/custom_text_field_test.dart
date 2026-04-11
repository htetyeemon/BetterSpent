import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:better_spent/core/widgets/custom_text_field.dart';

void main() {
  testWidgets('CustomTextField calls onChanged', (tester) async {
    String? latest;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CustomTextField(
            hintText: 'Amount',
            onChanged: (value) => latest = value,
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '123');
    await tester.pump();

    expect(latest, '123');
  });

  testWidgets('CustomTextField renders label text', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomTextField(
            labelText: 'Email',
          ),
        ),
      ),
    );

    expect(find.text('Email'), findsOneWidget);
  });
}
