import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';

class ExpenseDateSection extends StatelessWidget {
  final String dateLabel;
  final VoidCallback onTap;

  const ExpenseDateSection({
    super.key,
    required this.dateLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DATE',
          style: AppTextStyles.labelSmall.copyWith(
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(
                AppConstants.radiusLg,
              ),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Text(
              dateLabel,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }
}
