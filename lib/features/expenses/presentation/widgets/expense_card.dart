import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../../../core/utils/amount_formatter.dart';

class ExpenseCard extends StatelessWidget {
  final String name;
  final String category;
  final double amount;
  final String time;
  final String currencySymbol;
  final VoidCallback onTap;

  const ExpenseCard({
    super.key,
    required this.name,
    required this.category,
    required this.amount,
    required this.time,
    required this.currencySymbol,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppConstants.radiusXl),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border.all(color: AppColors.borderDark),
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F0F),
                borderRadius: BorderRadius.circular(16),
              ),
              child: CategoryIcon(category: category, size: 24),
            ),

            const SizedBox(width: AppConstants.spacingMd),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppConstants.spacingMd),

            Flexible(
              child: Text(
                '-$currencySymbol${formatAmount(amount)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
