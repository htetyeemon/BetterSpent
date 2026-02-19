import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../widgets/income_column.dart';
import '../widgets/budget_column.dart';
import '../../../../models/mock_data.dart';

class HomeStatsCard extends StatelessWidget {
  final String currencySymbol;
  final double income;
  final String incomeDate;
  final Function(double amount, String date) onIncomeSaved;
  final double monthlyBudget;
  final Function(double amount) onBudgetSaved;

  const HomeStatsCard({
    super.key,
    required this.currencySymbol,
    required this.income,
    required this.incomeDate,
    required this.onIncomeSaved,
    required this.monthlyBudget,
    required this.onBudgetSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildStatColumn(
                'BALANCE',
                '\$${MockData.mockBalance.toStringAsFixed(2)}',
                AppColors.textPrimary,
              ),
              IncomeColumn(
                currencySymbol: currencySymbol,
                income: income,
                incomeDate: incomeDate,
                onIncomeSaved: onIncomeSaved,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(height: 1, color: AppColors.borderDark),
          const SizedBox(height: 24),
          Row(
            children: [
              BudgetColumn(
                currencySymbol: currencySymbol,
                monthlyBudget: monthlyBudget,
                onBudgetSaved: onBudgetSaved,
              ),
              _buildStatColumn(
                'MAX SPEND/DAY',
                '\$${MockData.mockDailyLimit.toStringAsFixed(2)}',
                AppColors.accent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
