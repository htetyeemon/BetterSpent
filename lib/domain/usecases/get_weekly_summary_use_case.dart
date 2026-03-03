import '../entities/expense.dart';

class WeeklySummary {
  final double totalWeeklySpending;
  final double averagePerDay;

  const WeeklySummary({
    required this.totalWeeklySpending,
    required this.averagePerDay,
  });
}

class GetWeeklySummaryUseCase {
  WeeklySummary execute(List<Expense> expenses) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final weeklyExpenses = expenses.where((e) => !e.date.isBefore(start)).toList();
    final total = weeklyExpenses.fold<double>(0.0, (sum, e) => sum + e.amount);
    return WeeklySummary(
      totalWeeklySpending: total,
      averagePerDay: total / 7,
    );
  }
}
