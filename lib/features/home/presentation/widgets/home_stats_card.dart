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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// TOP ROW
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildStatColumn(
                  'BALANCE',
                  '\$${MockData.mockBalance.toStringAsFixed(2)}',
                  AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: IncomeColumn(
                  currencySymbol: currencySymbol,
                  income: income,
                  incomeDate: incomeDate,
                  onIncomeSaved: onIncomeSaved,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Container(height: 1, color: AppColors.borderDark),
          const SizedBox(height: 20),

          /// BOTTOM ROW
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: BudgetColumn(
                  currencySymbol: currencySymbol,
                  monthlyBudget: monthlyBudget,
                  onBudgetSaved: onBudgetSaved,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatColumn(
                  'MAX SPEND/DAY',
                  '\$${MockData.mockDailyLimit.toStringAsFixed(2)}',
                  AppColors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        /// LABEL
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: 8),

        /// VALUE
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }
}
