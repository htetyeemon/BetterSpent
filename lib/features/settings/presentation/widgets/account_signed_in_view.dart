import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';

class AccountSignedInView extends StatelessWidget {
  final String accountName;
  final String accountEmail;
  final VoidCallback onSignOut;
  final VoidCallback onDeleteAccount;

  const AccountSignedInView({
    super.key,
    required this.accountName,
    required this.accountEmail,
    required this.onSignOut,
    required this.onDeleteAccount,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Signed in with Email', style: AppTextStyles.h3),
        const SizedBox(height: AppConstants.spacingMd),
        Text(accountName, style: AppTextStyles.bodyMedium),
        const SizedBox(height: 4),
        Text(
          accountEmail,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppConstants.spacingLg),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onSignOut,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Sign Out',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                ),
              ),
            ),
            const SizedBox(width: AppConstants.spacingSm),
            Expanded(
              child: OutlinedButton(
                onPressed: onDeleteAccount,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  backgroundColor: const Color(0x22FF4444),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  'Delete Account',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.error),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}


