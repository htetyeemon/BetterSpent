import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';

class ExpenseInputOnlineBody extends StatelessWidget {
  final TextEditingController controller;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const ExpenseInputOnlineBody({
    super.key,
    required this.controller,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Expense Input', style: AppTextStyles.h3),
        const SizedBox(height: AppConstants.spacingMd),
        TextField(
          controller: controller,
          maxLines: 3,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Type naturally (e.g. coffee 8, lunch 25, taxi 12)',
            hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
            filled: true,
            fillColor: const Color(0xFF0F0F0F),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              borderSide: const BorderSide(color: AppColors.borderDark),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              borderSide: const BorderSide(color: AppColors.borderDark),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Text(
          '"Coffee 5.50" or "Dinner 42"',
          style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF505050)),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        PrimaryButton(
          text: 'Add expense',
          isLoading: isSubmitting,
          onPressed: onSubmit,
        ),
      ],
    );
  }
}

class ExpenseInputManualBody extends StatelessWidget {
  final String message;
  final VoidCallback onAddExpenseManually;

  const ExpenseInputManualBody({
    super.key,
    required this.message,
    required this.onAddExpenseManually,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 20,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppConstants.spacingSm),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingLg),
        PrimaryButton(
          text: 'ADD EXPENSE MANUALLY',
          onPressed: onAddExpenseManually,
        ),
      ],
    );
  }
}
