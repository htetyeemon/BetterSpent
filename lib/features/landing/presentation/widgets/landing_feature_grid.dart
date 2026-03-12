import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';

class LandingSectionHeader extends StatelessWidget {
  const LandingSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h2),
        const SizedBox(height: AppConstants.spacingSm),
        Text(
          subtitle,
          style: AppTextStyles.bodyLarge.copyWith(
            color: AppColors.textTertiary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class LandingFeatureGrid extends StatelessWidget {
  const LandingFeatureGrid({super.key, required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      const LandingFeatureCard(
        title: 'AI expense input',
        description:
            'Type a short sentence and let AI parse the amount and category.',
        icon: Icons.notifications_active_rounded,
      ),
      const LandingFeatureCard(
        title: 'Manual expense entry',
        description: 'Add amount, category, date, and a note in a simple form.',
        icon: Icons.flash_on_rounded,
      ),
      const LandingFeatureCard(
        title: 'Weekly budget tracking',
        description: 'See remaining budget and avoid overspending each week.',
        icon: Icons.pie_chart_rounded,
      ),
      const LandingFeatureCard(
        title: 'Category summary',
        description:
            'Instant totals by category update when you add or edit expenses.',
        icon: Icons.local_fire_department_rounded,
      ),
      const LandingFeatureCard(
        title: 'Alerts & motivation',
        description: 'Warnings and encouragement help you stay consistent.',
        icon: Icons.auto_awesome_rounded,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final spacing = AppConstants.spacingMd;
        int columns;
        if (maxWidth >= 980) {
          columns = 3;
        } else if (maxWidth >= 640) {
          columns = 2;
        } else {
          columns = 1;
        }

        final totalSpacing = spacing * (columns - 1);
        final itemWidth = (maxWidth - totalSpacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: cards
              .map(
                (card) => SizedBox(
                  width: itemWidth,
                  child: card,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class LandingFeatureCard extends StatelessWidget {
  const LandingFeatureCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.secondary, size: 28),
          const SizedBox(height: AppConstants.spacingMd),
          Text(title, style: AppTextStyles.h4),
          const SizedBox(height: AppConstants.spacingSm),
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textTertiary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
