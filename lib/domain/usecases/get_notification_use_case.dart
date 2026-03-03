import '../entities/expense.dart';
import '../entities/financial_profile.dart';
import '../entities/user_settings.dart';
import 'get_max_spend_per_day_use_case.dart';

enum NotificationType { warning, motivational, none }

class NotificationResult {
  final NotificationType type;
  final String message;

  const NotificationResult({required this.type, required this.message});
}

class GetNotificationUseCase {
  final GetMaxSpendPerDayUseCase _getMaxSpendPerDayUseCase;

  GetNotificationUseCase(this._getMaxSpendPerDayUseCase);

  static const List<String> _motivationalMessages = [
    'You\'re doing great! Keep tracking your expenses daily.',
    'Nice work! You\'re building a healthy financial habit.',
    'Keep it up! Small savings add up to big results.',
    'Excellent! You\'re on track with your spending goals.',
    'Way to go! Every tracked expense counts.',
  ];

  NotificationResult execute(
    List<Expense> expenses,
    FinancialProfile profile,
    UserSettings settings,
  ) {
    final now = DateTime.now();
    final maxSpendPerDay = _getMaxSpendPerDayUseCase.execute(
      profile.monthlyBudget,
      expenses,
    );

    final todaySpending = expenses
        .where((e) =>
            e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day)
        .fold<double>(0.0, (sum, e) => sum + e.amount);

    final totalMonthSpending = expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold<double>(0.0, (sum, e) => sum + e.amount);

    final totalSpending = expenses.fold<double>(0.0, (sum, e) => sum + e.amount);

    final hasWarning = (maxSpendPerDay > 0 && todaySpending > maxSpendPerDay) ||
        totalMonthSpending > profile.monthlyBudget ||
        totalSpending > profile.income;

    if (hasWarning && settings.budgetWarningEnabled) {
      if (totalSpending > profile.income) {
        return const NotificationResult(
          type: NotificationType.warning,
          message: '⚠️ Your total spending has exceeded your income!',
        );
      } else if (totalMonthSpending > profile.monthlyBudget) {
        return const NotificationResult(
          type: NotificationType.warning,
          message: '⚠️ You\'ve exceeded your monthly budget!',
        );
      } else {
        return const NotificationResult(
          type: NotificationType.warning,
          message: '⚠️ You\'ve exceeded your daily spending limit!',
        );
      }
    }

    if (!hasWarning && settings.motivationalMessageEnabled) {
      final msgIndex = now.millisecondsSinceEpoch % _motivationalMessages.length;
      return NotificationResult(
        type: NotificationType.motivational,
        message: _motivationalMessages[msgIndex],
      );
    }

    return const NotificationResult(type: NotificationType.none, message: '');
  }
}
