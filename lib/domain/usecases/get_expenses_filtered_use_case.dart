import '../entities/expense.dart';

enum ExpenseFilter { all, today, thisWeek, thisMonth }

class GetExpensesFilteredUseCase {
  List<Expense> execute(List<Expense> expenses, ExpenseFilter filter) {
    final now = DateTime.now();
    switch (filter) {
      case ExpenseFilter.all:
        return expenses;
      case ExpenseFilter.today:
        return expenses.where((e) {
          return e.date.year == now.year &&
              e.date.month == now.month &&
              e.date.day == now.day;
        }).toList();
      case ExpenseFilter.thisWeek:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        return expenses.where((e) => !e.date.isBefore(start)).toList();
      case ExpenseFilter.thisMonth:
        return expenses.where((e) {
          return e.date.year == now.year && e.date.month == now.month;
        }).toList();
    }
  }
}
