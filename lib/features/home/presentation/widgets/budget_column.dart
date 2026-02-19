import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'set_budget_dialog.dart';

class BudgetColumn extends StatelessWidget {
  final String currencySymbol;
  final double monthlyBudget;
  final Function(double amount) onBudgetSaved;

  const BudgetColumn({
    super.key,
    required this.currencySymbol,
    required this.monthlyBudget,
    required this.onBudgetSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'MONTHLY BUDGET',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _showBudgetDialog(context),
              child: const Icon(
                Icons.edit_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        /// Prevent large amount overflow
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            '$currencySymbol${monthlyBudget.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
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
      onSave: onBudgetSaved,
    );
  }
}
