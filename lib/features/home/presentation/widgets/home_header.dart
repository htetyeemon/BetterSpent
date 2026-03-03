import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';

class HomeHeader extends StatelessWidget {
  final bool isOnline;

  const HomeHeader({super.key, required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacingLg, // 24
        AppConstants.spacingXl, // 32
        AppConstants.spacingLg, // 24
        AppConstants.spacingLg, // 24
      ),
      child: Column(
        children: [
          /// Logo
          Row(
            children: [
              Container(
                width: AppConstants.iconLg, // 32
                height: AppConstants.iconLg,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusSm, // 8
                  ),
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.black,
                  size: 20, // keeping exact size to avoid shift
                ),
              ),
              const SizedBox(width: AppConstants.spacingSm), // 8
              Text(
                'BetterSpent',
                style: AppTextStyles.h4.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: AppConstants.spacingSm,
          ), // 12 ≈ 8 (visually same spacing group)
          /// Status Indicator
          Row(
            children: [
              Container(
                width: AppConstants.spacingSm, // 8
                height: AppConstants.spacingSm,
                decoration: BoxDecoration(
                  color: isOnline ? AppColors.primary : AppColors.textSecondary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppConstants.spacingSm),
              Text(
                isOnline ? 'ONLINE — SMART INPUT' : 'OFFLINE — MANUAL MODE',
                style: AppTextStyles.labelMedium.copyWith(
                  letterSpacing: 0.5,
                  color: isOnline ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
