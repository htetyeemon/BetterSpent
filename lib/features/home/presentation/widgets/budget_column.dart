import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'set_budget_dialog.dart';
import '../../../../core/utils/amount_formatter.dart';
import '../../../../core/widgets/expanded_tap_target.dart';

class BudgetColumn extends StatelessWidget {
  final String currencySymbol;
  final double monthlyBudget;
  final double currentBalance;
  final Color valueColor;
  final Function(double amount) onBudgetSaved;

  const BudgetColumn({
    super.key,
    required this.currencySymbol,
    required this.monthlyBudget,
    required this.currentBalance,
    this.valueColor = AppColors.secondary,
    required this.onBudgetSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'MONTHLY BUDGET',
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  style: AppTextStyles.labelMedium.copyWith(
                    letterSpacing: 1.2,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ),
            ExpandedTapTarget(
              onTap: () => _showBudgetDialog(context),
              child: const Icon(
                Icons.edit_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            '$currencySymbol${formatAmount(monthlyBudget)}',
            style: AppTextStyles.h2.copyWith(
              fontSize: 28,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  void _showBudgetDialog(BuildContext context) {
    SetBudgetDialog.show(
      context,
      currencySymbol: currencySymbol,
      currentBudget: monthlyBudget,
      currentBalance: currentBalance,
      onSave: onBudgetSaved,
    );
  }
}
