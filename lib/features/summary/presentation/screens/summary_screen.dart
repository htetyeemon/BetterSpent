import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/bottom_navigation.dart';
import '../widgets/stat_card.dart';
import '../../../../presentation/providers/app_provider.dart';
import '../../../../core/utils/amount_formatter.dart';
import '../../../../core/utils/bottom_nav_helper.dart';
import '../widgets/summary_header.dart';
import '../widgets/summary_insights_card.dart';
import '../widgets/summary_category_list.dart';
import '../view_models/summary_view_model.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  String _selectedPeriod = 'This Week';
  int _currentNavIndex = 2;

  @override
  Widget build(BuildContext context) {
    final expenses = context.select((AppProvider p) => p.expenses);
    final currencySymbol = context.select((AppProvider p) => p.currencySymbol);
    final monthlyBudget =
        context.select((AppProvider p) => p.profile.monthlyBudget);
    final income = context.select((AppProvider p) => p.profile.income);
    final maxSpendPerDay =
        context.select((AppProvider p) => p.maxSpendPerDay);

    final vm = SummaryViewModel.fromData(
      expenses: expenses,
      currencySymbol: currencySymbol,
      monthlyBudget: monthlyBudget,
      income: income,
      maxSpendPerDay: maxSpendPerDay,
      selectedPeriod: _selectedPeriod,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            SummaryHeader(
              selectedPeriod: _selectedPeriod,
              onPeriodChanged: (period) {
                setState(() => _selectedPeriod = period);
              },
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
                              '${vm.currencySymbol}${formatAmount(vm.totalSpent)}',
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingMd),
                      Expanded(
                        child: StatCard(
                          label: 'Avg. Per Day',
                          value:
                              '${vm.currencySymbol}${formatAmount(vm.avgPerDay)}',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingLg),

                  if (vm.hasSpendingData) ...[
                    SummaryInsightsCard(
                      message: vm.insightMessage,
                      isWarning: vm.insightIsWarning,
                    ),
                    const SizedBox(height: AppConstants.spacingLg),
                  ],

                  // Spending by Category
                  Text('Spending by category', style: AppTextStyles.h3),
                  const SizedBox(height: AppConstants.spacingMd),

                  SummaryCategoryList(
                    categorySpending: vm.categorySpending,
                    currencySymbol: vm.currencySymbol,
                  ),

                  const SizedBox(height: AppConstants.spacingXl),
                ],
              ),
            ),

            // Bottom Navigation
            BottomNavigation(
              currentIndex: _currentNavIndex,
              onTap: (index) {
                final currentIndex = _currentNavIndex;
                setState(() => _currentNavIndex = index);
                handleBottomNavTap(context, index, currentIndex);
              },
            ),
          ],
        ),
      ),
    );
  }

}

