import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';

class SummaryInsightsCard extends StatelessWidget {
  final String message;
  final bool isWarning;

  const SummaryInsightsCard({
    super.key,
    required this.message,
    required this.isWarning,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.borderDark),
        borderRadius: BorderRadius.circular(
          AppConstants.radiusLg,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: isWarning ? AppColors.warning : AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppConstants.spacingSm),
              const Text('Insights', style: AppTextStyles.h4),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMd),
          Text(
            message,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isWarning ? AppColors.warning : AppColors.textTertiary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
