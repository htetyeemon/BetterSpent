import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';

class HomeHeader extends StatelessWidget {
  final bool isOnline;
  final VoidCallback onToggle;

  const HomeHeader({super.key, required this.isOnline, required this.onToggle});

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
          /// Logo + Toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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

              /// Toggle
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 56,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isOnline
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: AnimatedAlign(
                    duration: AppConstants.animationShort,
                    alignment: isOnline
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      width: 20,
                      height: 20,
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingXs, // 4
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
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
