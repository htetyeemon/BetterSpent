import '../../../../presentation/providers/app_provider.dart';

class HomeNotificationHelper {
  final AppProvider provider;

  HomeNotificationHelper(this.provider);

  String getNotification() {
    final settings = provider.settings;
    final profile = provider.profile;
    final expenses = provider.expenses;
    final maxSpendPerDay = provider.maxSpendPerDay;

    if (profile.income == 0 && profile.monthlyBudget == 0) {
      return '';
    }

    final now = DateTime.now();
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
        totalMonthSpending > profile.monthlyBudget ||
        totalSpending > profile.income;

    if (hasWarning && settings.budgetWarningEnabled) {
      if (totalSpending > profile.income) {
        return '⚠️ Your total spending has exceeded your income!';
      } else if (totalMonthSpending > profile.monthlyBudget) {
        return '⚠️ You\'ve exceeded your monthly budget!';
      } else {
        return '⚠️ You\'ve exceeded your daily spending limit!';
      }
    }

    if (!hasWarning && settings.motivationalMessageEnabled) {
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
}
