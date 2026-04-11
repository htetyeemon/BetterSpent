import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:better_spent/core/widgets/app_text_field.dart';

void main() {
  testWidgets('AppTextField shows validation error', (tester) async {
    final formKey = GlobalKey<FormState>();
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            key: formKey,
            child: Column(
              children: [
                AppTextField(
                  controller: controller,
                  keyboardType: TextInputType.text,
                  hintText: 'Enter',
                  validator: (value) =>
                      (value == null || value.isEmpty) ? 'Required' : null,
                ),
                TextButton(
                  onPressed: () => formKey.currentState!.validate(),
                  child: const Text('Validate'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Validate'));
    await tester.pump();

    expect(find.text('Required'), findsOneWidget);
  });
}
