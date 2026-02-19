import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/todays_spending_dialog.dart';
import '../../../../models/mock_data.dart';
import '../../../../models/expense_model.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../../../core/constants/app_constants.dart';

class TodaysSpendingSection extends StatelessWidget {
  final bool isOnline;

  const TodaysSpendingSection({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    final todayExpenses = MockData.getTodayExpenses();
    final displayExpenses = todayExpenses.take(3).toList();

    return Column(
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, size: 20, color: AppColors.textPrimary),
                const SizedBox(width: 8),
                const Text(
                  'Today\'s Spending',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                TodaysSpendingDialog.show(context, isOnline: isOnline);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'View all',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Expense Items
        ...displayExpenses.asMap().entries.map((entry) {
          final expense = entry.value;
          return Padding(
            padding: EdgeInsets.only(
              bottom: entry.key < displayExpenses.length - 1 ? 12 : 0,
            ),
            child: _buildExpenseItem(expense),
          );
        }),
      ],
    );
  }

  Widget _buildExpenseItem(ExpenseModel expense) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F0F),
              borderRadius: BorderRadius.circular(16),
            ),
            child: CategoryIcon(category: expense.category, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOnline && expense.name.length > 15
                      ? expense.name.split(' ').first
                      : expense.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  expense.category,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '-\$${expense.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
