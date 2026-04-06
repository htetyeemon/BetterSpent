import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/custom_text_field.dart';

class ExpenseNoteSection extends StatelessWidget {
  final TextEditingController controller;

  const ExpenseNoteSection({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NOTE',
          style: AppTextStyles.labelSmall.copyWith(
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        CustomTextField(
          controller: controller,
          hintText: 'Add a note...',
        ),
        const SizedBox(height: 6),
        Text(
          'Avoid sensitive details like account numbers or passwords.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
