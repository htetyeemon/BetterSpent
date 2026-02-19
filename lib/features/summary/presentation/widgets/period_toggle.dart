import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

class PeriodToggle extends StatelessWidget {
  final String selectedPeriod;
  final Function(String) onPeriodChanged;

  const PeriodToggle({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.borderDark),
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              text: 'This Week',
              isSelected: selectedPeriod == 'This Week',
              onTap: () => onPeriodChanged('This Week'),
            ),
          ),
          Expanded(
            child: _ToggleButton(
              text: 'This Month',
              isSelected: selectedPeriod == 'This Month',
              onTap: () => onPeriodChanged('This Month'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSm),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        ),
        child: Center(
          child: Text(
            text,
            style: AppTextStyles.labelMedium.copyWith(
              color: isSelected
                  ? AppColors.background
                  : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
