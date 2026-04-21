import '../entities/expense.dart';

class GetDailyStreakUseCase {
  int execute(List<Expense> expenses, {DateTime? now}) {
    if (expenses.isEmpty) return 0;

    final referenceNow = now ?? DateTime.now();

    // Ignore future expenses (clock drift / bad data) when computing streaks.
    final validExpenses = expenses
        .where((e) => !e.date.isAfter(referenceNow))
        .toList();
    if (validExpenses.isEmpty) return 0;

    final lastExpenseAt = validExpenses
        .map((e) => e.date)
        .reduce((a, b) => a.isAfter(b) ? a : b);

    // Streak expires only after 24 hours since the last expense was added.
    if (referenceNow.difference(lastExpenseAt) > const Duration(hours: 24)) {
      return 0;
    }

    // Get unique days with expenses
    final daysWithExpenses =
        validExpenses
            .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a)); // descending

    if (daysWithExpenses.isEmpty) return 0;

    final anchorDay = DateTime(
      lastExpenseAt.year,
      lastExpenseAt.month,
      lastExpenseAt.day,
    );

    int streak = 0;
    for (int i = 0; i < 365; i++) {
      final day = anchorDay.subtract(Duration(days: i));
      if (daysWithExpenses.contains(day)) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
}
