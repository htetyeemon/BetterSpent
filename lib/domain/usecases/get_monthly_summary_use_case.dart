import '../entities/expense.dart';

class MonthlySummary {
  final double totalMonthlySpending;
  final double averagePerDay;

  const MonthlySummary({
    required this.totalMonthlySpending,
    required this.averagePerDay,
  });
}

class GetMonthlySummaryUseCase {
  MonthlySummary execute(List<Expense> expenses) {
    final now = DateTime.now();
    final monthlyExpenses = expenses.where((e) {
      return e.date.year == now.year && e.date.month == now.month;
    }).toList();
    final total = monthlyExpenses.fold<double>(0.0, (sum, e) => sum + e.amount);
    final currentDay = now.day;
    return MonthlySummary(
      totalMonthlySpending: total,
      averagePerDay: currentDay > 0 ? total / currentDay : 0,
    );
  }
}
