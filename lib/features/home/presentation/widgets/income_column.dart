import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'add_income_dialog.dart';
import 'edit_income_dialog.dart';
import '../../../../core/utils/amount_formatter.dart';
import '../../../../core/widgets/expanded_tap_target.dart';

class IncomeColumn extends StatelessWidget {
  final String currencySymbol;
  final double income;
  final void Function(double amount) onIncomeSaved;

  const IncomeColumn({
    super.key,
    required this.currencySymbol,
    required this.income,
    required this.onIncomeSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// LABEL + ACTIONS
        Row(
          children: [
            Expanded(
              child: Text(
                'INCOME',
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelMedium.copyWith(
                  letterSpacing: 1.2,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            ExpandedTapTarget(
              onTap: () => _showIncomeDialog(context),
              child: const Icon(
                Icons.add,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            ExpandedTapTarget(
              onTap: () => _showEditIncomeDialog(context),
              child: const Icon(
                Icons.edit_outlined,
                size: 18,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        /// VALUE
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            '+$currencySymbol${formatAmount(income)}',
            style: AppTextStyles.h2.copyWith(
              fontSize: 28,
              color: AppColors.primary,
            ),
          ),
        ),

      ],
    );
  }

  void _showIncomeDialog(BuildContext context) {
    AddIncomeDialog.show(
      context,
      currencySymbol: currencySymbol,
      onSave: onIncomeSaved,
    );
  }

  void _showEditIncomeDialog(BuildContext context) {
    EditIncomeDialog.show(
      context,
      currencySymbol: currencySymbol,
      initialAmount: income,
      onSave: onIncomeSaved,
    );
  }
}
