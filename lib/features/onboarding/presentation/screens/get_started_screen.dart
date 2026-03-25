import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../../../core/router/route_names.dart';
import '../../../../../core/services/app_launch_service.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  bool _agreedToTerms = false;

  void _handleGetStarted() {
    unawaited(_handleGetStartedAsync());
  }

  Future<void> _handleGetStartedAsync() async {
    await AppLaunchService.markGetStartedSeen();
    if (!mounted) return;
    context.go(RouteNames.home);
  }

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
              Text(
                'BetterSpent',
                style: AppTextStyles.h1.copyWith(color: AppColors.primary),
              ),

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
                  GestureDetector(
                    onTap: () => setState(() {
                      _agreedToTerms = !_agreedToTerms;
                    }),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Transform.scale(
                          scale: 1.1,
                          child: Checkbox(
                            value: _agreedToTerms,
                            onChanged: (value) => setState(() {
                              _agreedToTerms = value ?? false;
                            }),
                            activeColor: AppColors.primary,
                            checkColor: AppColors.background,
                            side: const BorderSide(
                              color: AppColors.textSecondary,
                              width: 1.5,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            'I agree to the Terms and Privacy Policy.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingSm),
                  PrimaryButton(
                    text: 'GET STARTED',
                    onPressed: _handleGetStarted,
                    isEnabled: _agreedToTerms,
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
