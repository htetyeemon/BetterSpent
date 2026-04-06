import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';

class LandingTopBar extends StatelessWidget {
  const LandingTopBar({super.key, required this.onLaunch});

  final VoidCallback onLaunch;

  @override
  Widget build(BuildContext context) {
    final launchButton = ElevatedButton(
      onPressed: onLaunch,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMd,
          vertical: AppConstants.spacingSm,
        ),
        textStyle: AppTextStyles.button.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.w700,
        ),
      ),
      child: Text('Launch App'),
    );

    return Row(
      children: [
        const LandingLogo(),
        const Spacer(),
        launchButton,
      ],
    );
  }
}

class LandingLogo extends StatelessWidget {
  const LandingLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: AppConstants.iconLg,
          height: AppConstants.iconLg,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          ),
          child: const Icon(
            Icons.check,
            color: Colors.black,
            size: 20,
          ),
        ),
        const SizedBox(width: AppConstants.spacingSm),
        Text(
          'BetterSpent',
          style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

