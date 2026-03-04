import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../domain/entities/expense.dart';
import '../../../../core/widgets/primary_button.dart';

class ExpenseInputOnlineBody extends StatelessWidget {
  final TextEditingController controller;
  final bool isSubmitting;
  final String? progressMessage;
  final Expense? pendingPreview;
  final int pendingCount;
  final VoidCallback onSubmit;

  const ExpenseInputOnlineBody({
    super.key,
    required this.controller,
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
        const Text('Expense Input', style: AppTextStyles.h3),
        const SizedBox(height: AppConstants.spacingMd),
        TextField(
          controller: controller,
          maxLines: 3,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Type naturally (e.g. coffee 8, lunch 25, taxi 12)',
            hintStyle: TextStyle(
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
          style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF505050)),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        PrimaryButton(
          text: 'Add expense',
          isLoading: isSubmitting,
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
          _PendingExpenseCard(
            expense: pendingPreview!,
            hasMore: pendingCount > 1,
            remainingCount: pendingCount - 1,
          ),
        ],
      ],
    );
  }
}

class _PendingExpenseCard extends StatelessWidget {
  final Expense expense;
  final bool hasMore;
  final int remainingCount;

  const _PendingExpenseCard({
    required this.expense,
    required this.hasMore,
    required this.remainingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.borderDark,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  expense.note.isNotEmpty ? expense.note : expense.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasMore
                      ? 'Saving now... +$remainingCount more'
                      : 'Saving now...',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '-\$${expense.amount.toStringAsFixed(2)}',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
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
