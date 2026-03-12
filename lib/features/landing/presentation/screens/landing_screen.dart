import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../widgets/landing_feature_grid.dart';
import '../widgets/landing_hero_section.dart';
import '../widgets/landing_cta_footer.dart';
import '../widgets/landing_steps_section.dart';
import '../widgets/landing_story_blocks.dart';
import '../widgets/landing_top_bar.dart';

class LandingScreen extends StatelessWidget {
  LandingScreen({super.key});

  final GlobalKey _problemKey = GlobalKey();
  final GlobalKey _solutionKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();

  void _scrollTo(GlobalKey key) {
    final contextToScroll = key.currentContext;
    if (contextToScroll == null) {
      return;
    }
    Scrollable.ensureVisible(
      contextToScroll,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final horizontalPadding = isWide ? 48.0 : AppConstants.spacingLg;
            final maxContentWidth = isWide ? 1024.0 : double.infinity;
            final sectionSpacing = isWide ? 40.0 : 56.0;

            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF000000),
                    Color(0xFF0B1A14),
                    Color(0xFF001318),
                  ],
                ),
              ),
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 32,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LandingTopBar(
                            onLaunch: () => context.go(RouteNames.home),
                          ),
                          const SizedBox(height: AppConstants.spacingLg),
                          LandingHeroSection(
                            isWide: isWide,
                            onViewFeatures: () => _scrollTo(_featuresKey),
                          ),
                          SizedBox(height: sectionSpacing + 8),
                          LandingStoryBlockGrid(
                            problemKey: _problemKey,
                            solutionKey: _solutionKey,
                          ),
                          SizedBox(height: sectionSpacing),
                          LandingSectionHeader(
                            key: _featuresKey,
                            title: 'Features',
                            subtitle:
                                'Each feature directly fixes the pain points above.',
                          ),
                          const SizedBox(height: AppConstants.spacingLg),
                          LandingFeatureGrid(isWide: isWide),
                          SizedBox(height: sectionSpacing),
                          const LandingSectionHeader(
                            title: 'How It Works',
                            subtitle: 'Start in minutes and stay on track.',
                          ),
                          const SizedBox(height: AppConstants.spacingLg),
                          LandingStepsSection(isWide: isWide),
                          SizedBox(height: sectionSpacing),
                          LandingCallToAction(
                            onLaunch: () => context.go(RouteNames.home),
                          ),
                          const SizedBox(height: 32),
                          const LandingFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
