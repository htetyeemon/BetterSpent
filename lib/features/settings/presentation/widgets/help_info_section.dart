import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'help_info_dialog.dart';

class HelpInfoSection extends StatelessWidget {
  const HelpInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HELP & INFO',
          style: AppTextStyles.labelSmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Column(
            children: [
              _buildHelpItem(
                context,
                'How to use BetterSpent',
                null,
                Icons.arrow_forward_ios,
                const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.borderDark,
              ),
              _buildHelpItem(
                context,
                'Offline vs online mode',
                null,
                Icons.arrow_forward_ios,
                null,
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.borderDark,
              ),
              _buildHelpItem(
                context,
                'Privacy policy',
                null,
                Icons.arrow_forward_ios,
                null,
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.borderDark,
              ),
              _buildHelpItem(
                context,
                'About this app',
                'VERSION 1.0.0',
                Icons.info_outline,
                const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHelpItem(
    BuildContext context,
    String title,
    String? subtitle,
    IconData icon,
    BorderRadius? borderRadius,
  ) {
    return InkWell(
      onTap: () => showHelpDialog(context, title),
      borderRadius: borderRadius,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: subtitle != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            Icon(icon, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }
}
