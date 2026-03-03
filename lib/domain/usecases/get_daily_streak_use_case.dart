import '../entities/expense.dart';

class GetDailyStreakUseCase {
  int execute(List<Expense> expenses) {
    if (expenses.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Get unique days with expenses
    final daysWithExpenses = expenses
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // descending

    if (daysWithExpenses.isEmpty) return 0;

    // Streak is active only if user has at least one expense today.
    if (!daysWithExpenses.contains(today)) {
      return 0;
    }

    int streak = 0;
    for (int i = 0; i < 365; i++) {
      final day = today.subtract(Duration(days: i));
      if (daysWithExpenses.contains(day)) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
}
