import 'dart:async';

import 'package:better_spent/domain/entities/expense.dart';
import 'package:better_spent/features/expenses/presentation/utils/expense_screen_actions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockExpenseActionProvider extends Mock
    implements ExpenseActionProvider {}

class _FakeExpense extends Fake implements Expense {}

void main() {
  late _MockExpenseActionProvider provider;

  setUpAll(() {
    registerFallbackValue(_FakeExpense());
  });

  setUp(() {
    provider = _MockExpenseActionProvider();
  });

  group('ExpenseScreenActions.updateExpense', () {
    test('returns immediately when offline', () async {
      final expense = Expense(
        id: 'expense-1',
        amount: 12.5,
        category: 'Food',
        note: 'Lunch',
        date: DateTime(2026, 4, 12),
      );
      final completer = Completer<void>();
      when(() => provider.isOnline).thenReturn(false);
      when(
        () => provider.updateExpense(any()),
      ).thenAnswer((_) => completer.future);

      await ExpenseScreenActions.updateExpense(
        provider: provider,
        expense: expense,
      ).timeout(const Duration(milliseconds: 100));

      verify(() => provider.updateExpense(expense)).called(1);
      expect(completer.isCompleted, isFalse);
    });

    test('waits for repository update when online', () async {
      final expense = Expense(
        id: 'expense-1',
        amount: 12.5,
        category: 'Food',
        note: 'Lunch',
        date: DateTime(2026, 4, 12),
      );
      final completer = Completer<void>();
      when(() => provider.isOnline).thenReturn(true);
      when(
        () => provider.updateExpense(any()),
      ).thenAnswer((_) => completer.future);

      var finished = false;
      final result = ExpenseScreenActions.updateExpense(
        provider: provider,
        expense: expense,
      ).then((_) => finished = true);

      await Future<void>.delayed(const Duration(milliseconds: 10));
      verify(() => provider.updateExpense(expense)).called(1);
      expect(finished, isFalse);

      completer.complete();
      await result;
      expect(finished, isTrue);
    });
  });
}
