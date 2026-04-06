import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/base_dialog.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class IncomeDialogContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final String title;
  final IconData icon;
  final String currencySymbol;
  final String primaryButtonText;
  final VoidCallback onSubmit;

  const IncomeDialogContent({
    super.key,
    required this.formKey,
    required this.controller,
    required this.title,
    required this.icon,
    required this.currencySymbol,
    required this.primaryButtonText,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingSm),
                Expanded(
                  child: Text(title, style: AppTextStyles.h2),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close,
                    size: 20,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.spacingXl),

            /// LABEL
            Text('AMOUNT', style: AppTextStyles.labelSmall),
            const SizedBox(height: AppConstants.spacingSm),

            /// FIELD
            AppTextField(
              controller: controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              hintText: '',
              style: AppTextStyles.h3,
              prefix: Padding(
                padding: const EdgeInsets.only(
                  left: AppConstants.spacingMd,
                  right: AppConstants.spacingSm,
                ),
                child: Text(
                  currencySymbol,
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Please enter an amount';
                }
                final value = double.tryParse(v);
                if (value == null) {
                  return 'Please enter a valid number';
                }
                if (value <= 0) {
                  return 'Amount must be greater than 0';
                }
                return null;
              },
            ),

            const SizedBox(height: AppConstants.spacingXl),

            /// BUTTONS
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingSm),
                Expanded(
                  child: PrimaryButton(
                    text: primaryButtonText,
                    onPressed: onSubmit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

