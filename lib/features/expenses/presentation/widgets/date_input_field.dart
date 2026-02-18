import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/app_text_field.dart';

class DateInputField extends StatelessWidget {
  final TextEditingController controller;

  const DateInputField({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm),

        AppTextField(
          controller: controller,
          keyboardType: TextInputType.datetime,
          hintText: '',
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }
}
