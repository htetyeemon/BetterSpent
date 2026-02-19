import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../../../core/router/route_names.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),

              /// Emoji / Visual
              Center(child: Text('💰', style: const TextStyle(fontSize: 80))),

              const SizedBox(height: AppConstants.spacingLg),

              /// Welcome Text
              Text(
                'Welcome to',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 4),

              /// App Title
              Text('BetterSpent', style: AppTextStyles.h1),

              const SizedBox(height: AppConstants.spacingMd),

              /// Description
              Text(
                'Take control of your finances.\n'
                'Track expenses, understand spending,\n'
                'and build better money habits.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

              const Spacer(),

              /// CTA Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PrimaryButton(
                    text: 'GET STARTED',
                    onPressed: () {
                      context.go(RouteNames.home);
                    },
                  ),

                  const SizedBox(height: AppConstants.spacingMd),

                  Center(
                    child: Text(
                      'It only takes a few seconds 🚀',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.spacingLg),
            ],
          ),
        ),
      ),
    );
  }
}
