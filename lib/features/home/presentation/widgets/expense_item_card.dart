import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';

class ExpenseItemCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String category;
  final String amount;

  const ExpenseItemCard({
    Key? key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.category,
    required this.amount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(
        AppConstants.spacingLg,
      ), // 20 → system spacing
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          Container(
            width: AppConstants.iconXl, // 48
            height: AppConstants.iconXl, // 48
            decoration: BoxDecoration(
              color: AppColors.surfaceDark, // replaced hardcoded color
              borderRadius: BorderRadius.circular(AppConstants.radiusMd), // 16
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: AppConstants.iconMd, // 24
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd), // 16
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppConstants.spacingXs), // 4
                Text(
                  category,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
