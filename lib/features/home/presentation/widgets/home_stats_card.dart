import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../widgets/income_column.dart';
import '../widgets/budget_column.dart';
import '../../../../presentation/providers/app_provider.dart';
import '../../../../core/utils/amount_formatter.dart';

class HomeStatsCard extends StatelessWidget {
  final String currencySymbol;
  final double income;
  final void Function(double amount) onIncomeSaved;
  final double monthlyBudget;
  final void Function(double amount) onBudgetSaved;

  const HomeStatsCard({
    super.key,
    required this.currencySymbol,
    required this.income,
    required this.onIncomeSaved,
    required this.monthlyBudget,
    required this.onBudgetSaved,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final balance = provider.balance;
    final maxSpendPerDay = provider.maxSpendPerDay;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLg,
        vertical: AppConstants.spacingMd,
      ),
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
                  '$currencySymbol${formatAmount(balance)}',
                  AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: IncomeColumn(
                  currencySymbol: currencySymbol,
                  income: income,
                  onIncomeSaved: onIncomeSaved,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppConstants.spacingLg),
          Container(height: 1, color: AppColors.borderDark),
          const SizedBox(height: AppConstants.spacingLg),

          /// BOTTOM ROW
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: BudgetColumn(
                  currencySymbol: currencySymbol,
                  monthlyBudget: monthlyBudget,
                  currentBalance: balance,
                  valueColor: AppColors.textPrimary,
                  onBudgetSaved: onBudgetSaved,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: _buildStatColumn(
                  'MAX SPEND/DAY',
                  '$currencySymbol${formatAmount(maxSpendPerDay)}',
                  AppColors.textPrimary,
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
