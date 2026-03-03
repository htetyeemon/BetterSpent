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

    // Check if today or yesterday has an expense (streak must be current)
    final yesterday = today.subtract(const Duration(days: 1));
    if (daysWithExpenses.first != today && daysWithExpenses.first != yesterday) {
      return 0;
    }

    int streak = 0;
    DateTime checkDay = daysWithExpenses.contains(today) ? today : yesterday;

    for (int i = 0; i < 365; i++) {
      final day = checkDay.subtract(Duration(days: i));
      if (daysWithExpenses.contains(day)) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
}
