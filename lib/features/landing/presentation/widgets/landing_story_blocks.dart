import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'landing_story_fact_card.dart';
import 'landing_story_models.dart';

class LandingStoryBlockGrid extends StatelessWidget {
  const LandingStoryBlockGrid({
    super.key,
    required this.problemKey,
    required this.solutionKey,
  });

  final GlobalKey problemKey;
  final GlobalKey solutionKey;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LandingStorySectionTitle(
          key: problemKey,
          title: 'Problem',
          eyebrow: 'Spending gets messy fast',
        ),
        const SizedBox(height: AppConstants.spacingMd),
        const LandingStoryFactGrid(
          facts: [
            LandingStoryFact(
              title: 'No daily clarity',
              description:
                  'People forget to log expenses and lose track of their budget.',
              accent: AppColors.primary,
            ),
            LandingStoryFact(
              title: 'Too many steps',
              description:
                  'Typing multiple fields makes tracking feel slow and tiring.',
              accent: AppColors.primary,
            ),
            LandingStoryFact(
              title: 'Low motivation',
              description:
                  'Without feedback or reminders, users stop tracking.',
              accent: AppColors.primary,
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingLg),
        LandingStorySectionTitle(
          key: solutionKey,
          title: 'Solution',
          eyebrow: 'BetterSpent brings focus',
        ),
        const SizedBox(height: AppConstants.spacingMd),
        const LandingStoryFactGrid(
          facts: [
            LandingStoryFact(
              title: 'Fast input',
              description:
                  'AI free‑text and manual entry keep logging under 10 seconds.',
              accent: AppColors.primary,
            ),
            LandingStoryFact(
              title: 'Clear feedback',
              description:
                  'Budget status, category totals, and summaries update instantly.',
              accent: AppColors.primary,
            ),
            LandingStoryFact(
              title: 'Motivation built in',
              description:
                  'Alerts and encouragement keep users consistent.',
              accent: AppColors.primary,
            ),
          ],
        ),
      ],
    );
  }
}

class LandingStorySectionTitle extends StatelessWidget {
  const LandingStorySectionTitle({
    super.key,
    required this.title,
    required this.eyebrow,
  });

  final String title;
  final String eyebrow;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTextStyles.labelMedium.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        Text(eyebrow, style: AppTextStyles.h3),
      ],
    );
  }
}

class LandingStoryFactGrid extends StatelessWidget {
  const LandingStoryFactGrid({super.key, required this.facts});

  final List<LandingStoryFact> facts;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        int columns;
        if (maxWidth >= 980) {
          columns = 3;
        } else if (maxWidth >= 640) {
          columns = 2;
        } else {
          columns = 1;
        }

        final spacing = AppConstants.spacingMd;
        final totalSpacing = spacing * (columns - 1);
        final itemWidth = (maxWidth - totalSpacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: facts
              .map(
                (fact) => SizedBox(
                  width: itemWidth,
                  child: LandingStoryFactCard(fact: fact),
                ),
              )
              .toList(),
        );
      },
    );
  }
}
