import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/bottom_navigation.dart';
import '../../../../core/router/route_names.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../widgets/filter_chip_row.dart';
import '../widgets/expense_list_content.dart';
import '../../../../core/utils/bottom_nav_helper.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});
  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  String _selectedFilter = 'All Time';
  int _currentNavIndex = 1;
  DateTimeRange? _allTimeDateRange;

  static final DateFormat _rangeFormatter = DateFormat('MMM d, yyyy');

  String _allTimeRangeLabel() {
    final range = _allTimeDateRange;
    if (range == null) return 'Filter expenses by date';
    return '${_rangeFormatter.format(range.start)} – ${_rangeFormatter.format(range.end)}';
  }

  Future<void> _pickAllTimeRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year, now.month, now.day),
      initialDateRange: _allTimeDateRange,
    );
    if (picked == null) return;
    setState(() => _allTimeDateRange = picked);
  }

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
            if (_selectedFilter == 'All Time')
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingLg,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickAllTimeRange,
                        icon: const Icon(Icons.date_range),
                        label: Text(_allTimeRangeLabel()),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.borderDark),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingMd,
                            vertical: AppConstants.spacingSm,
                          ),
                        ),
                      ),
                    ),
                    if (_allTimeDateRange != null) ...[
                      const SizedBox(width: AppConstants.spacingSm),
                      IconButton(
                        tooltip: 'Clear date filter',
                        onPressed: () => setState(() => _allTimeDateRange = null),
                        icon: const Icon(Icons.clear),
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ],
                ),
              ),
            if (_selectedFilter == 'All Time')
              const SizedBox(height: AppConstants.spacingMd),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spacingLg,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: AppConstants.spacingSm),
                  Text(
                    'Tap an item to see more details',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),

            Expanded(
              child: ExpenseListContent(
                selectedFilter: _selectedFilter,
                allTimeDateRange: _selectedFilter == 'All Time'
                    ? _allTimeDateRange
                    : null,
              ),
            ),

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
