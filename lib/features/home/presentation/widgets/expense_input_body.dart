import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../domain/entities/expense.dart';
import '../../../../core/widgets/primary_button.dart';
import 'pending_expense_card.dart';

class ExpenseInputOnlineBody extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isSubmitting;
  final String? progressMessage;
  final Expense? pendingPreview;
  final int pendingCount;
  final VoidCallback onSubmit;

  const ExpenseInputOnlineBody({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isSubmitting,
    this.progressMessage,
    this.pendingPreview,
    this.pendingCount = 0,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Enter expenses', style: AppTextStyles.h3),
        const SizedBox(height: AppConstants.spacingMd),
        TextField(
          controller: controller,
          focusNode: focusNode,
          maxLines: 3,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Type naturally (e.g. coffee 8, lunch 25, taxi 12)',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
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
          style: AppTextStyles.bodySmall.copyWith(
            color: const Color(0xFF505050),
          ),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        PrimaryButton(
          text: 'Add expense',
          isEnabled: !isSubmitting,
          onPressed: onSubmit,
        ),
        if (isSubmitting && progressMessage != null) ...[
          const SizedBox(height: AppConstants.spacingMd),
          Row(
            children: [
              const SizedBox(
                height: 14,
                width: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              const SizedBox(width: AppConstants.spacingSm),
              Expanded(
                child: Text(
                  progressMessage!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ],
        if (isSubmitting && pendingPreview != null) ...[
          const SizedBox(height: AppConstants.spacingMd),
          PendingExpenseCard(
            expense: pendingPreview!,
            hasMore: pendingCount > 1,
            remainingCount: pendingCount - 1,
          ),
        ],
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
