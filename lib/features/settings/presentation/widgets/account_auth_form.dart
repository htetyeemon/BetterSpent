import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';

enum AccountAuthMode { signIn, create }

class AccountAuthForm extends StatelessWidget {
  final bool isLoading;
  final AccountAuthMode mode;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onSubmit;
  final VoidCallback onForgotPassword;
  final ValueChanged<AccountAuthMode> onModeChanged;

  const AccountAuthForm({
    super.key,
    required this.isLoading,
    required this.mode,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onSubmit,
    required this.onForgotPassword,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isCreate = mode == AccountAuthMode.create;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<AccountAuthMode>(
          segments: const [
            ButtonSegment<AccountAuthMode>(
              value: AccountAuthMode.signIn,
              label: Text('Sign in'),
            ),
            ButtonSegment<AccountAuthMode>(
              value: AccountAuthMode.create,
              label: Text('Create account'),
            ),
          ],
          selected: {mode},
          onSelectionChanged: isLoading
              ? null
              : (set) => onModeChanged(set.first),
          style: ButtonStyle(
            foregroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.background;
              }
              return AppColors.textSecondary;
            }),
            backgroundColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primary;
              }
              return const Color(0xFF0F0F0F);
            }),
            side: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const BorderSide(color: AppColors.primary);
              }
              return const BorderSide(color: AppColors.borderDark);
            }),
          ),
        ),
        const SizedBox(height: AppConstants.spacingLg),
        if (isCreate) ...[
          TextField(
            controller: usernameController,
            enabled: !isLoading,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: _inputDecoration('Username'),
          ),
          const SizedBox(height: 8),
          Text(
            'Username should be 3-24 characters and contain only letters, numbers, or underscore.',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppConstants.spacingMd),
        ],
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          enabled: !isLoading,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: _inputDecoration('Email'),
        ),
        const SizedBox(height: AppConstants.spacingMd),
        TextField(
          controller: passwordController,
          obscureText: true,
          enabled: !isLoading,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: _inputDecoration('Password'),
        ),
        const SizedBox(height: 8),
        Text(
          'Password must be at least 8 characters and include letters and numbers.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
        if (isCreate) ...[
          const SizedBox(height: AppConstants.spacingMd),
          TextField(
            controller: confirmPasswordController,
            obscureText: true,
            enabled: !isLoading,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: _inputDecoration('Confirm password'),
          ),
        ],
        if (!isCreate) ...[
          const SizedBox(height: AppConstants.spacingSm),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: isLoading ? null : onForgotPassword,
              child: const Text('Forgot password?'),
            ),
          ),
        ],
        const SizedBox(height: AppConstants.spacingMd),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLoading ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: Text(isCreate ? 'Create account' : 'Sign in'),
          ),
        ),
        if (isLoading) ...[
          const SizedBox(height: AppConstants.spacingMd),
          const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ],
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      filled: true,
      fillColor: const Color(0xFF0F0F0F),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        borderSide: const BorderSide(color: AppColors.borderDark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        borderSide: const BorderSide(color: AppColors.surfaceLighter),
      ),
    );
  }
}
