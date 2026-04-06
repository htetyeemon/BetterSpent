import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import 'set_budget_dialog_actions.dart';
import 'set_budget_dialog_sections.dart';

class SetBudgetDialogContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final String currencySymbol;
  final String? balanceError;
  final VoidCallback onClose;
  final VoidCallback onSubmit;
  final ValueChanged<String> onChanged;

  const SetBudgetDialogContent({
    super.key,
    required this.formKey,
    required this.controller,
    required this.currencySymbol,
    required this.balanceError,
    required this.onClose,
    required this.onSubmit,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingXl),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SetBudgetDialogHeader(onClose: onClose),
            const SizedBox(height: AppConstants.spacingXl),
            SetBudgetAmountField(
              controller: controller,
              currencySymbol: currencySymbol,
              onChanged: onChanged,
            ),
            if (balanceError != null) ...[
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                balanceError!,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.error,
                ),
              ),
            ],
            const SizedBox(height: AppConstants.spacingXl),
            SetBudgetDialogActions(
              onClose: onClose,
              onSubmit: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}
