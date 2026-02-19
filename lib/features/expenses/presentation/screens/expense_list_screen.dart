import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/bottom_navigation.dart';
import '../../../../core/router/route_names.dart';
import 'package:go_router/go_router.dart';
import '../widgets/filter_chip_row.dart';
import '../widgets/expense_list_content.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});
  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  String _selectedFilter = 'All Time';
  int _currentNavIndex = 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go(RouteNames.home),
                    color: AppColors.textPrimary,
                  ),
                  const Expanded(
                    child: Center(
                      child: Text('Expenses', style: AppTextStyles.h2),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            FilterChipRow(
              selectedFilter: _selectedFilter,
              onFilterChanged: (filter) {
                setState(() => _selectedFilter = filter);
              },
            ),
            const SizedBox(height: AppConstants.spacingMd),
            const Expanded(child: ExpenseListContent()),
            BottomNavigation(
              currentIndex: _currentNavIndex,
              onTap: (index) {
                setState(() => _currentNavIndex = index);
                switch (index) {
                  case 0:
                    context.go(RouteNames.home);
                    break;
                  case 2:
                    context.go(RouteNames.summary);
                    break;
                  case 3:
                    context.go(RouteNames.settings);
                    break;
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
