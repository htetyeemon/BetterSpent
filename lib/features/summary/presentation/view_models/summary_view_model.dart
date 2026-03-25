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

  SummaryViewModel({
    required AppProvider provider,
    required String selectedPeriod,
  })  : currencySymbol = provider.currencySymbol,
        hasSpendingData = _computeHasSpendingData(
          provider: provider,
          selectedPeriod: selectedPeriod,
        ),
        needsSetup = _computeNeedsSetup(provider: provider),
        periodExpenses = _computePeriodExpenses(
          provider: provider,
          selectedPeriod: selectedPeriod,
        ),
        categorySpending = _computeCategorySpending(
          provider: provider,
          selectedPeriod: selectedPeriod,
        ),
        totalSpent = _computeTotalSpent(
          provider: provider,
          selectedPeriod: selectedPeriod,
        ),
        avgPerDay = _computeAvgPerDay(
          provider: provider,
          selectedPeriod: selectedPeriod,
        ),
        insightMessage = _computeInsightMessage(
          provider: provider,
          selectedPeriod: selectedPeriod,
        ),
        insightIsWarning = _computeInsightIsWarning(
          provider: provider,
          selectedPeriod: selectedPeriod,
        );

  static bool _computeHasSpendingData({
    required AppProvider provider,
    required String selectedPeriod,
  }) {
    return _computePeriodExpenses(
      provider: provider,
      selectedPeriod: selectedPeriod,
    ).isNotEmpty;
  }

  static bool _computeNeedsSetup({required AppProvider provider}) {
    return provider.profile.monthlyBudget <= 0 || provider.profile.income <= 0;
  }

  static List<Expense> _computePeriodExpenses({
    required AppProvider provider,
    required String selectedPeriod,
  }) {
    final expenses = provider.expenses;
    final now = DateTime.now();

    if (selectedPeriod == 'This Week') {
      return expenses.where((e) {
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final start =
            DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        return !e.date.isBefore(start);
      }).toList();
    }

    return expenses.where((e) {
      return e.date.year == now.year && e.date.month == now.month;
    }).toList();
  }

  static List<CategorySpending> _computeCategorySpending({
    required AppProvider provider,
    required String selectedPeriod,
  }) {
    final expenses = _computePeriodExpenses(
      provider: provider,
      selectedPeriod: selectedPeriod,
    );
    final useCase = GetSpendingByCategoryUseCase();
    return useCase.execute(
      expenses,
      monthlyBudget: provider.profile.monthlyBudget,
    );
  }

  static double _computeTotalSpent({
    required AppProvider provider,
    required String selectedPeriod,
  }) {
    final weeklySummary = GetWeeklySummaryUseCase().execute(provider.expenses);
    final monthlySummary =
        GetMonthlySummaryUseCase().execute(provider.expenses);
    return selectedPeriod == 'This Week'
        ? weeklySummary.totalWeeklySpending
        : monthlySummary.totalMonthlySpending;
  }

  static double _computeAvgPerDay({
    required AppProvider provider,
    required String selectedPeriod,
  }) {
    final weeklySummary = GetWeeklySummaryUseCase().execute(provider.expenses);
    final monthlySummary =
        GetMonthlySummaryUseCase().execute(provider.expenses);
    return selectedPeriod == 'This Week'
        ? weeklySummary.averagePerDay
        : monthlySummary.averagePerDay;
  }

  static String _computeInsightMessage({
    required AppProvider provider,
    required String selectedPeriod,
  }) {
    final avgPerDay = _computeAvgPerDay(
      provider: provider,
      selectedPeriod: selectedPeriod,
    );
    final insight = GetInsightsPredictionUseCase().execute(
      avgPerDay,
      provider.maxSpendPerDay,
      isMonthlyPeriod: selectedPeriod == 'This Month',
    );
    final needsSetup = _computeNeedsSetup(provider: provider);
    return needsSetup
        ? 'Set both Income and Monthly Budget in Home to see accurate insights and summary predictions.'
        : insight.message;
  }

  static bool _computeInsightIsWarning({
    required AppProvider provider,
    required String selectedPeriod,
  }) {
    final avgPerDay = _computeAvgPerDay(
      provider: provider,
      selectedPeriod: selectedPeriod,
    );
    final insight = GetInsightsPredictionUseCase().execute(
      avgPerDay,
      provider.maxSpendPerDay,
      isMonthlyPeriod: selectedPeriod == 'This Month',
    );
    return _computeNeedsSetup(provider: provider) || insight.willExceedBudget;
  }
}
