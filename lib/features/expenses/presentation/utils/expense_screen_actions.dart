import 'dart:async';

import '../../../../domain/entities/expense.dart';
import '../../../../presentation/providers/app_provider.dart';

class ExpenseSaveResult {
  final bool ok;
  final String? error;
  final bool queuedOffline;

  const ExpenseSaveResult._(this.ok, {this.error, this.queuedOffline = false});

  const ExpenseSaveResult.success({bool queuedOffline = false})
      : this._(true, queuedOffline: queuedOffline);

  const ExpenseSaveResult.failure(String error)
      : this._(false, error: error);
}

class ExpenseScreenActions {
  static Expense? buildExpense({
    required String amountText,
    required String note,
    required String category,
    required DateTime date,
  }) {
    if (amountText.trim().isEmpty) return null;
    final amount = double.tryParse(amountText.trim());
    if (amount == null) return null;
    return Expense(
      id: '',
      amount: amount,
      category: category,
      date: date,
      note: note.trim(),
    );
  }

  static Future<ExpenseSaveResult> addExpense({
    required AppProvider provider,
    required Expense expense,
  }) async {
    try {
      if (!provider.isOnline) {
        unawaited(provider.addExpense(expense).catchError((_) {}));
        return const ExpenseSaveResult.success(queuedOffline: true);
      }

      await provider.addExpense(expense);
      return const ExpenseSaveResult.success();
    } catch (e) {
      return ExpenseSaveResult.failure(e.toString());
    }
  }

  static Future<void> updateExpense({
    required AppProvider provider,
    required Expense expense,
  }) async {
    await provider.updateExpense(expense);
  }
}
