part of 'app_provider.dart';

void _recomputeDerivedImpl(AppProvider self) {
  self._balance = self._getBalance.execute(self._profile.income, self._expenses);
  self._maxSpendPerDay = self._getMaxSpendPerDay.execute(
    self._profile.monthlyBudget,
    self._expenses,
  );
  self._dailyStreak = self._getDailyStreak.execute(self._expenses);
  unawaited(self._persistDerivedCache());
}

int _currentDayKeyImpl(DateTime now) =>
    (now.year * 10000) + (now.month * 100) + now.day;

void _recomputeNotificationImpl(AppProvider self) {
  final now = DateTime.now();
  self._notification = self._computeNotification(
    now: now,
    budgetWarningEnabled: self._settings.budgetWarningEnabled,
    motivationalMessageEnabled: self._settings.motivationalMessageEnabled,
    income: self._profile.income,
    monthlyBudget: self._profile.monthlyBudget,
    maxSpendPerDay: self._maxSpendPerDay,
    expenses: self._expenses,
  );
  self._notificationDayKey = self._currentDayKey(now);
}

String _computeNotificationImpl({
  required DateTime now,
  required bool budgetWarningEnabled,
  required bool motivationalMessageEnabled,
  required double income,
  required double monthlyBudget,
  required double maxSpendPerDay,
  required List<Expense> expenses,
}) {
  if (income == 0 && monthlyBudget == 0) {
    return '';
  }

  double todaySpending = 0.0;
  double totalMonthSpending = 0.0;
  double totalSpending = 0.0;
  for (final expense in expenses) {
    totalSpending += expense.amount;
    if (expense.date.year == now.year && expense.date.month == now.month) {
      totalMonthSpending += expense.amount;
      if (expense.date.day == now.day) {
        todaySpending += expense.amount;
      }
    }
  }

  final hasWarning = (maxSpendPerDay > 0 && todaySpending > maxSpendPerDay) ||
      totalMonthSpending > monthlyBudget ||
      totalSpending > income;

  if (hasWarning && budgetWarningEnabled) {
    if (totalSpending > income) {
      return '⚠️ Your total spending has exceeded your income!';
    } else if (totalMonthSpending > monthlyBudget) {
      return '⚠️ You\'ve exceeded your monthly budget!';
    } else {
      return '⚠️ You\'ve exceeded your daily spending limit!';
    }
  }

  if (!hasWarning && motivationalMessageEnabled) {
    const messages = [
      'You\'re doing great! Keep tracking your expenses daily.',
      'Nice work! You\'re building a healthy financial habit.',
      'Keep it up! Small savings add up to big results.',
    ];
    final daySeed = (now.year * 10000) + (now.month * 100) + now.day;
    return messages[daySeed % messages.length];
  }

  return '';
}
