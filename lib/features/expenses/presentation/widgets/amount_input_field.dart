import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';

class AmountInputField extends StatelessWidget {
  final TextEditingController controller;

  const AmountInputField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AMOUNT',
          style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1.2),
        ),
        const SizedBox(height: AppConstants.spacingSm),

        AppTextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          hintText: '0.00',
          style: AppTextStyles.displayMedium,
          prefix: Padding(
            padding: const EdgeInsets.only(
              left: AppConstants.spacingMd,
              right: AppConstants.spacingSm,
            ),
            child: Text(
              '\$',
              style: AppTextStyles.displayMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
