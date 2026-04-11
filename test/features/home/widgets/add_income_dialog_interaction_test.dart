import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:better_spent/features/home/presentation/widgets/add_income_dialog.dart';

void main() {
  testWidgets('AddIncomeDialog close icon dismisses dialog', (tester) async {
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

    expect(find.byType(AddIncomeDialog), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(find.byType(AddIncomeDialog), findsNothing);
  });
}
