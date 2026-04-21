import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/route_names.dart';

class LandingHeroSection extends StatelessWidget {
  const LandingHeroSection({
    super.key,
    required this.isWide,
    required this.onViewFeatures,
  });

  final bool isWide;
  final VoidCallback onViewFeatures;

  @override
  Widget build(BuildContext context) {
    final titleStyle = AppTextStyles.displayMedium.copyWith(height: 1.1);
    final subtitleStyle = AppTextStyles.bodyLarge.copyWith(
      color: AppColors.textTertiary,
      height: 1.6,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: titleStyle,
            children: [
              const TextSpan(text: 'Better '),
              TextSpan(
                text: 'spending',
                style: titleStyle.copyWith(color: AppColors.primary),
              ),
              const TextSpan(text: ', smarter habits.'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'BetterSpent is an AI‑integrated expense tracking app that lets you '
          'record spending fast using natural language or manual entry. See your '
          'budget status, category totals, and weekly summaries instantly.',
          style: subtitleStyle,
        ),
        const SizedBox(height: AppConstants.spacingLg),
        Wrap(
          spacing: 16,
          runSpacing: 12,
          children: [
            ElevatedButton(
              onPressed: () => context.go(RouteNames.home),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingLg,
                  vertical: AppConstants.spacingMd,
                ),
                textStyle: AppTextStyles.button.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text('Launch the App'),
            ),
            OutlinedButton(
              onPressed: onViewFeatures,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: AppColors.borderLight),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingLg,
                  vertical: AppConstants.spacingMd,
                ),
              ),
              child: Text('View Features'),
            ),
          ],
        ),
        if (isWide) const SizedBox(height: AppConstants.spacingMd),
      ],
    );
  }
}
