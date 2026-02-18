import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/primary_button.dart';

class EditExpenseActions extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const EditExpenseActions({
    Key? key,
    required this.onCancel,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                backgroundColor: AppColors.surface,
                side: const BorderSide(color: AppColors.borderDark),
                padding: const EdgeInsets.symmetric(
                  vertical: AppConstants.spacingMd,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.radiusLg,
                  ),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppConstants.spacingSm),
          Expanded(
            child: PrimaryButton(
              text: 'Save Changes',
              onPressed: onSave,
            ),
          ),
        ],
      ),
    );
  }
}
