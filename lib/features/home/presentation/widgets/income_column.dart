import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'add_income_dialog.dart';
import 'edit_income_dialog.dart';

class IncomeColumn extends StatelessWidget {
  final String currencySymbol;
  final double income;
  final String incomeDate;
  final Function(double amount, String date) onIncomeSaved;

  const IncomeColumn({
    super.key,
    required this.currencySymbol,
    required this.income,
    required this.incomeDate,
    required this.onIncomeSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'INCOME',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                  color: AppColors.textSecondary,
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showIncomeDialog(context),
                    child: const Icon(
                      Icons.add,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _showEditIncomeDialog(context),
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '+$currencySymbol${income.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Last updated $incomeDate',
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
          ),
        ],
      ),
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
