import '../entities/expense.dart';

class GetMaxSpendPerDayUseCase {
  double execute(double monthlyBudget, List<Expense> expenses) {
    final now = DateTime.now();
    final totalDaysInMonth = DateTime(now.year, now.month + 1, 0).day;
    if (totalDaysInMonth <= 0) return 0;
    return monthlyBudget / totalDaysInMonth;
  }
}
