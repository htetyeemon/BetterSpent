import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

class SetBudgetDialogHeader extends StatelessWidget {
  final VoidCallback onClose;

  const SetBudgetDialogHeader({
    super.key,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(
              AppConstants.radiusMd,
            ),
          ),
          child: const Icon(
            Icons.account_balance_wallet,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: AppConstants.spacingSm),
        const Expanded(
          child: Text('Set Monthly Budget', style: AppTextStyles.h2),
        ),
        InkWell(
          onTap: onClose,
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.borderDark),
              borderRadius: BorderRadius.circular(
                AppConstants.radiusSm,
              ),
            ),
            child: const Icon(
              Icons.close,
              size: 16,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

class SetBudgetAmountField extends StatelessWidget {
  final TextEditingController controller;
  final String currencySymbol;
  final ValueChanged<String> onChanged;

  const SetBudgetAmountField({
    super.key,
    required this.controller,
    required this.currencySymbol,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MONTHLY BUDGET AMOUNT',
          style: AppTextStyles.labelSmall,
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.borderDark),
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: AppConstants.spacingMd,
                  right: AppConstants.spacingSm,
                ),
                child: Text(
                  currencySymbol,
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  onChanged: onChanged,
                  style: AppTextStyles.h3,
                  decoration: const InputDecoration(
                    hintText: '',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppConstants.spacingMd,
                      vertical: AppConstants.spacingMd,
                    ),
                  ),
                  validator: (v) {
                    final amount = double.tryParse(v ?? '');
                    if (v == null || v.isEmpty) {
                      return 'Please enter a budget amount';
                    }
                    if (amount == null) {
                      return 'Please enter a valid number';
                    }
                    if (amount <= 0) {
                      return 'Budget must be greater than 0';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
