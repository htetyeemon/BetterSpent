import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:better_spent/features/home/presentation/widgets/set_budget_dialog.dart';

Future<void> _openDialog(
  WidgetTester tester, {
  required double currentBalance,
  double? currentBudget,
  required void Function(double) onSave,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () {
                SetBudgetDialog.show(
                  context,
                  currencySymbol: '\$',
                  currentBalance: currentBalance,
                  currentBudget: currentBudget,
                  onSave: onSave,
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
  testWidgets('prefills current budget value', (tester) async {
    await _openDialog(
      tester,
      currentBalance: 100,
      currentBudget: 120,
      onSave: (_) {},
    );

    final field = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(field.controller?.text, '120');
  });

  testWidgets('shows validation error when empty', (tester) async {
    await _openDialog(
      tester,
      currentBalance: 100,
      onSave: (_) {},
    );

    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('Please enter a budget amount'), findsOneWidget);
  });

  testWidgets('shows balance error when budget exceeds balance', (tester) async {
    await _openDialog(
      tester,
      currentBalance: 100,
      onSave: (_) {},
    );

    await tester.enterText(find.byType(TextFormField), '200');
    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('Budget cannot exceed your current balance'), findsOneWidget);
  });

  testWidgets('calls onSave with valid amount', (tester) async {
    double? saved;

    await _openDialog(
      tester,
      currentBalance: 100,
      onSave: (value) => saved = value,
    );

    await tester.enterText(find.byType(TextFormField), '80');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(saved, 80);
  });
}
