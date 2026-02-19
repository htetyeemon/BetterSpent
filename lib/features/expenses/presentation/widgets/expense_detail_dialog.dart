import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

class ExpenseDetailDialog extends StatelessWidget {
  final String name;
  final String category;
  final double amount;
  final String time;
  final String note;
  final IconData categoryIcon;
  final Color iconColor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ExpenseDetailDialog({
    super.key,
    required this.name,
    required this.category,
    required this.amount,
    required this.time,
    required this.note,
    required this.categoryIcon,
    required this.iconColor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingXl),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogHeader(context),
            const SizedBox(height: AppConstants.spacingXl),
            Text(
              '\$${amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              time,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              note,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingXl),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingSm,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F0F),
            borderRadius: BorderRadius.circular(AppConstants.radiusXl),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(categoryIcon, size: 16, color: iconColor),
              const SizedBox(width: 6),
              Text(
                category.toUpperCase(),
                style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1.2),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          color: AppColors.textSecondary,
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              onEdit();
            },
            icon: const Icon(Icons.edit_outlined, size: 20),
            label: const Text(
              'Edit',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textPrimary,
              backgroundColor: const Color(0xFF0F0F0F),
              side: const BorderSide(color: AppColors.borderDark),
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacingMd,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.spacingSm),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            icon: const Icon(Icons.delete_outline, size: 20),
            label: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              backgroundColor: const Color(0xFF0F0F0F),
              side: const BorderSide(color: AppColors.borderDark),
              padding: const EdgeInsets.symmetric(
                vertical: AppConstants.spacingMd,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static void show(
    BuildContext context, {
    required String name,
    required String category,
    required double amount,
    required String time,
    required String note,
    required IconData categoryIcon,
    required Color iconColor,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) => ExpenseDetailDialog(
        name: name,
        category: category,
        amount: amount,
        time: time,
        note: note,
        categoryIcon: categoryIcon,
        iconColor: iconColor,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }
}
