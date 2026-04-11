import 'package:better_spent/domain/entities/expense.dart';

/// Helper class to create expenses for testing without boilerplate
class ExpenseTestHelper {
  static Expense createExpense({
    String? id,
    double amount = 50.0,
    String category = 'Other',
    String note = 'test',
    DateTime? date,
  }) {
    return Expense(
      id: id ?? '${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      category: category,
      date: date ?? DateTime.now(),
      note: note,
    );
  }

  static Expense createExpenseWithNote(String note, {double amount = 50.0}) {
    return createExpense(note: note, amount: amount);
  }

  static Expense createExpenseWithAmount(
    double amount, {
    String note = 'test',
  }) {
    return createExpense(amount: amount, note: note);
  }

  static List<Expense> createExpenseList(
    int count, {
    double baseAmount = 50.0,
    String baseNote = 'test',
  }) {
    return List.generate(
      count,
      (i) =>
          createExpense(id: '$i', amount: baseAmount + i, note: '$baseNote$i'),
    );
  }
}
