import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/category_icon.dart';
import 'progress_bar.dart';
import '../../../../core/utils/amount_formatter.dart';

class CategorySpendingCard extends StatelessWidget {
  final String category;
  final double amount;
  final double percentage;
  final String currencySymbol;

  const CategorySpendingCard({
    super.key,
    required this.category,
    required this.amount,
    required this.percentage,
    required this.currencySymbol,
  });

  String _formatPercentage(double value) {
    if (value <= 0) return '0';
    if (value < 0.01) return '< 0.01';
    if (value < 1) return value.toStringAsFixed(2);
    if (value < 10) return value.toStringAsFixed(1);
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.borderDark),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
                child: Center(
                  child: CategoryIcon(category: category, size: 20),
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),

              // Category Name
              Expanded(
                child: Text(
                  category,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // Amount and Percentage
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$currencySymbol${formatAmount(amount)}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${_formatPercentage(percentage)}% of monthly budget',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMd),

          // Progress Bar
          CustomProgressBar(progress: percentage / 100),
        ],
      ),
    );
  }
}
