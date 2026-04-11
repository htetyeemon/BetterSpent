import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:better_spent/features/home/presentation/widgets/set_budget_dialog.dart';

void main() {
  testWidgets('SetBudgetDialog close icon dismisses dialog', (tester) async {
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
                    currentBalance: 100,
                    onSave: (_) {},
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

    expect(find.byType(SetBudgetDialog), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.byType(SetBudgetDialog), findsNothing);
  });
}
