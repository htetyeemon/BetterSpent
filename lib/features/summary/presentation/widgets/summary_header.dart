import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/route_names.dart';
import 'period_toggle.dart';

class SummaryHeader extends StatelessWidget {
  final String selectedPeriod;
  final ValueChanged<String> onPeriodChanged;

  const SummaryHeader({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go(RouteNames.home),
                color: AppColors.textPrimary,
              ),
              const Expanded(
                child: Center(
                  child: Text('Summary', style: AppTextStyles.h2),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: AppConstants.spacingMd),
          PeriodToggle(
            selectedPeriod: selectedPeriod,
            onPeriodChanged: onPeriodChanged,
          ),
        ],
      ),
    );
  }
}
