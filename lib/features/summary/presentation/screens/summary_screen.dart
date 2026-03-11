import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/bottom_navigation.dart';
import '../../../../core/router/route_names.dart';
import 'package:go_router/go_router.dart';
import '../widgets/period_toggle.dart';
import '../widgets/category_spending_card.dart';
import '../widgets/stat_card.dart';
import '../../../../presentation/providers/app_provider.dart';
import '../../../../domain/usecases/get_weekly_summary_use_case.dart';
import '../../../../domain/usecases/get_monthly_summary_use_case.dart';
import '../../../../domain/usecases/get_spending_by_category_use_case.dart';
import '../../../../domain/usecases/get_insights_prediction_use_case.dart';
import '../../../../core/utils/amount_formatter.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  String _selectedPeriod = 'This Week';
  int _currentNavIndex = 2;

  final _weeklySummaryUseCase = GetWeeklySummaryUseCase();
  final _monthlySummaryUseCase = GetMonthlySummaryUseCase();
  final _spendingByCategoryUseCase = GetSpendingByCategoryUseCase();
  final _insightsPredictionUseCase = GetInsightsPredictionUseCase();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final expenses = provider.expenses;
    final monthlyBudget = provider.profile.monthlyBudget;
    final income = provider.profile.income;
    final now = DateTime.now();

    final weeklySummary = _weeklySummaryUseCase.execute(expenses);
    final monthlySummary = _monthlySummaryUseCase.execute(expenses);

    final totalSpent = _selectedPeriod == 'This Week'
        ? weeklySummary.totalWeeklySpending
        : monthlySummary.totalMonthlySpending;
    final avgPerDay = _selectedPeriod == 'This Week'
        ? weeklySummary.averagePerDay
        : monthlySummary.averagePerDay;

    final periodExpenses = _selectedPeriod == 'This Week'
        ? expenses.where((e) {
            final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
            final start =
                DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
            return !e.date.isBefore(start);
          }).toList()
        : expenses.where((e) {
            return e.date.year == now.year && e.date.month == now.month;
          }).toList();

    final categorySpending = _spendingByCategoryUseCase.execute(
      periodExpenses,
      monthlyBudget: monthlyBudget,
    );
    final insight = _insightsPredictionUseCase.execute(
      avgPerDay,
      provider.maxSpendPerDay,
      isMonthlyPeriod: _selectedPeriod == 'This Month',
    );
    final currencySymbol = provider.currencySymbol;
    final hasSpendingData = periodExpenses.isNotEmpty;
    final needsSetup = monthlyBudget <= 0 || income <= 0;
    final insightMessage = needsSetup
        ? 'Set both Income and Monthly Budget in Home to see accurate insights and summary predictions.'
        : insight.message;
    final insightIsWarning = needsSetup || insight.willExceedBudget;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.go(RouteNames.home),
                        color: AppColors.textPrimary,
                      ),
                      const Expanded(
                        child: Center(
                          child: Text('Summary', style: AppTextStyles.h2),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingMd),

                  // Period Toggle
                  PeriodToggle(
                    selectedPeriod: _selectedPeriod,
                    onPeriodChanged: (period) {
                      setState(() => _selectedPeriod = period);
                    },
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingMd,
                ),
                children: [
                  // Stat Cards
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          label: 'Total Spent',
                          value:
                              '$currencySymbol${formatAmount(totalSpent)}',
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingMd),
                      Expanded(
                        child: StatCard(
                          label: 'Avg. Per Day',
                          value:
                              '$currencySymbol${formatAmount(avgPerDay)}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingLg),

                  if (hasSpendingData) ...[
                    // Insights Card
                    Container(
                      padding: const EdgeInsets.all(AppConstants.spacingLg),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(color: AppColors.borderDark),
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusLg,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                color: insightIsWarning
                                    ? AppColors.warning
                                    : AppColors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: AppConstants.spacingSm),
                              const Text('Insights', style: AppTextStyles.h4),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spacingMd),
                          Text(
                            insightMessage,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: insightIsWarning
                                  ? AppColors.warning
                                  : AppColors.textTertiary,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingLg),
                  ],

                  // Spending by Category
                  const Text('Spending by category', style: AppTextStyles.h3),
                  const SizedBox(height: AppConstants.spacingMd),

                  if (categorySpending.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'No spending data yet',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  else
                    ...categorySpending.map(
                      (cs) => Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppConstants.spacingMd,
                        ),
                        child: CategorySpendingCard(
                          category: cs.category.toUpperCase(),
                          amount: cs.amount,
                          percentage: cs.percentage,
                          currencySymbol: currencySymbol,
                        ),
                      ),
                    ),

                  const SizedBox(height: AppConstants.spacingXl),
                ],
              ),
            ),

            // Bottom Navigation
            BottomNavigation(
              currentIndex: _currentNavIndex,
              onTap: (index) {
                setState(() => _currentNavIndex = index);
                _navigateToScreen(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToScreen(int index) {
    switch (index) {
      case 0:
        context.go(RouteNames.home);
        break;
      case 1:
        context.go(RouteNames.expenses);
        break;
      case 2:
        // Already on summary
        break;
      case 3:
        context.go(RouteNames.settings);
        break;
    }
  }
}
