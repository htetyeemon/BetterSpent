import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';

class ExpenseScreenHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const ExpenseScreenHeader({
    super.key,
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack,
            color: AppColors.textPrimary,
          ),
          Expanded(
            child: Center(
              child: Text(title, style: AppTextStyles.h2),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
