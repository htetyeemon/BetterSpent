import 'package:flutter_test/flutter_test.dart';
import 'package:better_spent/models/expense_model.dart';

void main() {
  test('ExpenseModel fromJson and toJson round trip', () {
    final model = ExpenseModel(
      id: '1',
      name: 'Coffee',
      category: 'Food',
      amount: 4.5,
      date: DateTime(2026, 2, 17, 9, 0),
      note: 'Latte',
    );

    final json = model.toJson();
    final restored = ExpenseModel.fromJson(json);

    expect(restored.id, model.id);
    expect(restored.name, model.name);
    expect(restored.category, model.category);
    expect(restored.amount, model.amount);
    expect(restored.date, model.date);
    expect(restored.note, model.note);
  });

  test('ExpenseModel copyWith overrides selected fields', () {
    final model = ExpenseModel(
      id: '1',
      name: 'Coffee',
      category: 'Food',
      amount: 4.5,
      date: DateTime(2026, 2, 17),
    );

    final updated = model.copyWith(amount: 10, note: 'Updated');
    expect(updated.amount, 10);
    expect(updated.note, 'Updated');
    expect(updated.name, model.name);
  });
}
