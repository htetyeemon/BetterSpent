import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const SettingsSection({Key? key, required this.title, required this.items})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1.5),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.borderDark),
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          child: Column(children: _buildItemsWithDividers()),
        ),
      ],
    );
  }

  List<Widget> _buildItemsWithDividers() {
    final List<Widget> widgets = [];
    for (int i = 0; i < items.length; i++) {
      widgets.add(items[i]);
      if (i < items.length - 1) {
        widgets.add(const Divider(height: 1, color: AppColors.borderDark));
      }
    }
    return widgets;
  }
}
