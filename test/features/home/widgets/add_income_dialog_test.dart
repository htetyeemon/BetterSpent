import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:better_spent/features/home/presentation/widgets/add_income_dialog.dart';

Future<void> _openDialog(
  WidgetTester tester, {
  required void Function(double) onSave,
  String mode = 'add',
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () {
                AddIncomeDialog.show(
                  context,
                  currencySymbol: '\$',
                  onSave: onSave,
                  mode: mode,
                );
              },
              child: const Text('Open'),
            );
          },
        ),
      ),
    ),
  );

  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows add mode labels by default', (tester) async {
    await _openDialog(tester, onSave: (_) {});

    expect(find.text('Add Income'), findsOneWidget);
    expect(find.text('Add'), findsOneWidget);
  });

  testWidgets('shows update mode labels when mode is update', (tester) async {
    await _openDialog(tester, onSave: (_) {}, mode: 'update');

    expect(find.text('Update Income'), findsOneWidget);
    expect(find.text('Update'), findsOneWidget);
  });

  testWidgets('shows validation error when empty', (tester) async {
    await _openDialog(tester, onSave: (_) {});

    await tester.tap(find.text('Add'));
    await tester.pump();

    expect(find.text('Please enter an amount'), findsOneWidget);
  });

  testWidgets('calls onSave with valid amount', (tester) async {
    double? saved;

    await _openDialog(tester, onSave: (value) => saved = value);

    await tester.enterText(find.byType(TextFormField), '150');
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();

    expect(saved, 150);
  });
}
