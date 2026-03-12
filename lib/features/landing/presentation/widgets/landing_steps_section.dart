import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';

class LandingStepsSection extends StatelessWidget {
  const LandingStepsSection({super.key, required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final steps = <Widget>[
      const LandingStepCard(
        index: '01',
        title: 'Open the app',
        description:
            'View current budget status and expense summary right away.',
      ),
      const LandingStepCard(
        index: '02',
        title: 'Add an expense',
        description:
            'Use AI free‑text input or manual entry to record spending.',
      ),
      const LandingStepCard(
        index: '03',
        title: 'Review updates',
        description:
            'Weekly budget, category totals, and alerts update instantly.',
      ),
    ];

    if (isWide) {
      return Row(
        children: List.generate(
          steps.length,
          (index) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: index == steps.length - 1 ? 0 : AppConstants.spacingMd,
              ),
              child: steps[index],
            ),
          ),
        ),
      );
    }

    return Column(
      children: List.generate(
        steps.length,
        (index) => Padding(
          padding: EdgeInsets.only(
            bottom: index == steps.length - 1 ? 0 : AppConstants.spacingMd,
          ),
          child: steps[index],
        ),
      ),
    );
  }
}

class LandingStepCard extends StatelessWidget {
  const LandingStepCard({
    super.key,
    required this.index,
    required this.title,
    required this.description,
  });

  final String index;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            index,
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.primary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Text(title, style: AppTextStyles.h4),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
