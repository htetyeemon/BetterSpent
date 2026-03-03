import '../entities/expense.dart';

class GetMaxSpendPerDayUseCase {
  double execute(double monthlyBudget, List<Expense> expenses) {
    final now = DateTime.now();
    final totalDaysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final currentDay = now.day;
    final remainingDays = totalDaysInMonth - currentDay + 1;

    final totalSpentThisMonth = expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold<double>(0.0, (sum, e) => sum + e.amount);

    final remainingBudget = monthlyBudget - totalSpentThisMonth;
    if (remainingDays <= 0) return 0;
    return remainingBudget / remainingDays;
  }
}
