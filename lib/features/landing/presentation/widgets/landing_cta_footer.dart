import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'landing_top_bar.dart';

class LandingCallToAction extends StatelessWidget {
  const LandingCallToAction({super.key, required this.onLaunch});

  final VoidCallback onLaunch;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;

        return Container(
          padding: const EdgeInsets.all(AppConstants.spacingXl),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            color: AppColors.surface,
            border: Border.all(color: AppColors.borderLight),
          ),
          child: isWide
              ? Row(
                  children: [
                    const Expanded(child: LandingCallToActionText()),
                    const SizedBox(width: AppConstants.spacingMd),
                    ElevatedButton(
                      onPressed: onLaunch,
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
                      child: const Text('Launch App'),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const LandingCallToActionText(),
                    const SizedBox(height: AppConstants.spacingMd),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onLaunch,
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
                        child: const Text('Launch App'),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class LandingCallToActionText extends StatelessWidget {
  const LandingCallToActionText({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Ready to take control?', style: AppTextStyles.h3),
        SizedBox(height: AppConstants.spacingSm),
        Text(
          'Launch BetterSpent now and start tracking your money today.',
          style: TextStyle(color: AppColors.textTertiary, height: 1.5),
        ),
      ],
    );
  }
}

class LandingFooter extends StatelessWidget {
  const LandingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 360;
        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              LandingLogo(),
              SizedBox(height: AppConstants.spacingSm),
              Text(
                'Built for focused spending.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          );
        }

        return Row(
          children: const [
            LandingLogo(),
            Spacer(),
            Text(
              'Built for focused spending.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        );
      },
    );
  }
}
