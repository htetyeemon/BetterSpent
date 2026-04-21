import '../../../../domain/entities/expense.dart';
import '../../../../domain/usecases/get_weekly_summary_use_case.dart';
import '../../../../domain/usecases/get_monthly_summary_use_case.dart';
import '../../../../domain/usecases/get_spending_by_category_use_case.dart';
import '../../../../domain/usecases/get_insights_prediction_use_case.dart';
import '../../../../presentation/providers/app_provider.dart';

class SummaryViewModel {
  final double totalSpent;
  final double avgPerDay;
  final List<Expense> periodExpenses;
  final List<CategorySpending> categorySpending;
  final String currencySymbol;
  final bool hasSpendingData;
  final bool needsSetup;
  final String insightMessage;
  final bool insightIsWarning;

  factory SummaryViewModel({
    required AppProvider provider,
    required String selectedPeriod,
  }) {
    return SummaryViewModel.fromData(
      expenses: provider.expenses,
      currencySymbol: provider.currencySymbol,
      monthlyBudget: provider.profile.monthlyBudget,
      income: provider.profile.income,
      maxSpendPerDay: provider.maxSpendPerDay,
      selectedPeriod: selectedPeriod,
    );
  }

  factory SummaryViewModel.fromData({
    required List<Expense> expenses,
    required String currencySymbol,
    required double monthlyBudget,
    required double income,
    required double maxSpendPerDay,
    required String selectedPeriod,
  }) {
    final needsSetup = _computeNeedsSetup(
      monthlyBudget: monthlyBudget,
      income: income,
    );
    final periodExpenses = _computePeriodExpenses(
      expenses: expenses,
      selectedPeriod: selectedPeriod,
    );
    final hasSpendingData = periodExpenses.isNotEmpty;

    late final double totalSpent;
    late final double avgPerDay;
    if (selectedPeriod == 'This Week') {
      final weeklySummary = GetWeeklySummaryUseCase().execute(expenses);
      totalSpent = weeklySummary.totalWeeklySpending;
      avgPerDay = weeklySummary.averagePerDay;
    } else {
      final monthlySummary = GetMonthlySummaryUseCase().execute(expenses);
      totalSpent = monthlySummary.totalMonthlySpending;
      avgPerDay = monthlySummary.averagePerDay;
    }

    final categoryBudget = selectedPeriod == 'This Week'
        ? (maxSpendPerDay * 7)
        : monthlyBudget;

    final categorySpending = GetSpendingByCategoryUseCase().execute(
      periodExpenses,
      budget: categoryBudget,
    );

    final insight = GetInsightsPredictionUseCase().execute(
      avgPerDay,
      maxSpendPerDay,
      isMonthlyPeriod: selectedPeriod == 'This Month',
    );

    final insightMessage = needsSetup
        ? 'Set both Income and Monthly Budget in Home to see accurate insights and summary predictions.'
        : insight.message;
    final insightIsWarning = needsSetup || insight.willExceedBudget;

    return SummaryViewModel._(
      totalSpent: totalSpent,
      avgPerDay: avgPerDay,
      periodExpenses: periodExpenses,
      categorySpending: categorySpending,
      currencySymbol: currencySymbol,
      hasSpendingData: hasSpendingData,
      needsSetup: needsSetup,
      insightMessage: insightMessage,
      insightIsWarning: insightIsWarning,
    );
  }

  const SummaryViewModel._({
    required this.totalSpent,
    required this.avgPerDay,
    required this.periodExpenses,
    required this.categorySpending,
    required this.currencySymbol,
    required this.hasSpendingData,
    required this.needsSetup,
    required this.insightMessage,
    required this.insightIsWarning,
  });

  static bool _computeNeedsSetup({
    required double monthlyBudget,
    required double income,
  }) {
    return monthlyBudget <= 0 || income <= 0;
  }

  static List<Expense> _computePeriodExpenses({
    required List<Expense> expenses,
    required String selectedPeriod,
  }) {
    final now = DateTime.now();

    if (selectedPeriod == 'This Week') {
      return expenses.where((e) {
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final start = DateTime(
          startOfWeek.year,
          startOfWeek.month,
          startOfWeek.day,
        );
        return !e.date.isBefore(start);
      }).toList();
    }

    return expenses.where((e) {
      return e.date.year == now.year && e.date.month == now.month;
    }).toList();
  }
}
