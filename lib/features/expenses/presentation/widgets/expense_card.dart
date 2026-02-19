import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/category_icon.dart';

class ExpenseCard extends StatelessWidget {
  final String name;
  final String category;
  final double amount;
  final String? time;
  final VoidCallback onTap;

  const ExpenseCard({
    super.key,
    required this.name,
    required this.category,
    required this.amount,
    this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.borderDark),
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
              child: Center(child: CategoryIcon(category: category)),
            ),
            const SizedBox(width: AppConstants.spacingMd),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(category, style: AppTextStyles.bodySmall),
                      if (time != null) ...[
                        const SizedBox(width: 8),
                        Text('• $time', style: AppTextStyles.bodySmall),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Amount
            Text('-\$${amount.toStringAsFixed(2)}', style: AppTextStyles.h4),
          ],
        ),
      ),
    );
  }
}
