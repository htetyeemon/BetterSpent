import 'package:flutter_test/flutter_test.dart';
import 'package:better_spent/domain/entities/expense.dart';

void main() {
  test('Expense copyWith overrides selected fields', () {
    final expense = Expense(
      id: '1',
      amount: 20,
      category: 'Food',
      date: DateTime(2026, 2, 17),
      note: 'Initial',
    );

    final updated = expense.copyWith(amount: 30, note: 'Updated');
    expect(updated.amount, 30);
    expect(updated.note, 'Updated');
    expect(updated.category, 'Food');
  });
}
