import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

class MessageCard extends StatelessWidget {
  final String message;
  final IconData icon;
  final bool isWarning;
  final VoidCallback? onClose;

  const MessageCard({
    super.key,
    required this.message,
    this.icon = Icons.lightbulb_outline,
    this.isWarning = false,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isWarning ? AppColors.warning : AppColors.borderDark;
    final messageColor = isWarning ? AppColors.warning : AppColors.textTertiary;
    final iconColor = isWarning ? AppColors.warning : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: AppConstants.iconLg,
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: messageColor,
                height: 1.5,
              ),
            ),
          ),
          if (onClose != null) ...[
            const SizedBox(width: AppConstants.spacingSm),
            GestureDetector(
              onTap: onClose,
              child: Icon(
                Icons.close,
                size: 18,
                color: messageColor.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
