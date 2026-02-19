import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/bottom_navigation.dart';
import '../../../../core/router/route_names.dart';
import 'package:go_router/go_router.dart';
import '../widgets/period_toggle.dart';
import '../widgets/category_spending_card.dart';
import '../widgets/stat_card.dart';

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
                    children: const [
                      Expanded(
                        child: StatCard(
                          label: 'Total Spent',
                          value: '\$156.50',
                        ),
                      ),
                      SizedBox(width: AppConstants.spacingMd),
                      Expanded(
                        child: StatCard(
                          label: 'Avg. Per Day',
                          value: '\$22.36',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spacingLg),

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
                          children: const [
                            Icon(
                              Icons.auto_awesome,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            SizedBox(width: AppConstants.spacingSm),
                            Text('Insights', style: AppTextStyles.h4),
                          ],
                        ),
                        const SizedBox(height: AppConstants.spacingMd),
                        Text(
                          _selectedPeriod == 'This Week'
                              ? 'Your spending is 15% higher than last week. Try reducing expenses in Food & Drink category to stay on track.'
                              : 'You have spent 40% of your monthly budget so far. At this pace, you may exceed your limit by month-end.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textTertiary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingLg),

                  // Spending by Category
                  const Text('Spending by category', style: AppTextStyles.h3),
                  const SizedBox(height: AppConstants.spacingMd),

                  const CategorySpendingCard(
                    category: 'FOOD & DRINK',
                    amount: 61.80,
                    percentage: 39,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),

                  const CategorySpendingCard(
                    category: 'TRANSPORT',
                    amount: 65.00,
                    percentage: 42,
                  ),
                  const SizedBox(height: AppConstants.spacingMd),

                  const CategorySpendingCard(
                    category: 'SHOPPING',
                    amount: 29.70,
                    percentage: 19,
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
