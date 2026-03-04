import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/route_names.dart';
import '../../../../presentation/providers/app_provider.dart';
import '../widgets/account_auth_form.dart';
import '../widgets/account_signed_in_view.dart';
import 'account_auth_validators.dart';

class AccountAuthScreen extends StatefulWidget {
  const AccountAuthScreen({super.key});

  @override
  State<AccountAuthScreen> createState() => _AccountAuthScreenState();
}

class _AccountAuthScreenState extends State<AccountAuthScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  AccountAuthMode _mode = AccountAuthMode.signIn;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isSignedIn = provider.isEmailUser && !provider.isAnonymous;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.spacingLg),
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.spacingLg),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: isSignedIn
                      ? AccountSignedInView(
                          accountName: provider.accountName,
                          accountEmail: provider.accountEmail ?? 'No email available',
                          onSignOut: () => _handleSignOut(provider),
                          onDeleteAccount: () => _confirmDeleteAccount(provider),
                        )
                      : AccountAuthForm(
                          isLoading: provider.isAuthLoading,
                          mode: _mode,
                          usernameController: _usernameController,
                          emailController: _emailController,
                          passwordController: _passwordController,
                          confirmPasswordController: _confirmPasswordController,
                          onSubmit: () => _handleSubmit(provider),
                          onForgotPassword: () => _handleForgotPassword(provider),
                          onModeChanged: (mode) => setState(() => _mode = mode),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(RouteNames.settings),
            color: AppColors.textPrimary,
          ),
          const Expanded(
            child: Center(child: Text('Account', style: AppTextStyles.h2)),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Future<void> _handleSignOut(AppProvider provider) async {
    await provider.signOut();
    if (!mounted) return;
    context.go(RouteNames.settings, extra: 'Signed out successfully');
  }

  Future<void> _handleSubmit(AppProvider provider) async {
    final emailError = validateEmail(_emailController.text);
    if (emailError != null) return _showError(emailError);

    final passwordError = validatePassword(_passwordController.text);
    if (passwordError != null) return _showError(passwordError);

    if (_mode == AccountAuthMode.create) {
      final usernameError = validateUsername(_usernameController.text);
      if (usernameError != null) return _showError(usernameError);
      if (_confirmPasswordController.text != _passwordController.text) {
        return _showError('Passwords do not match');
      }
    }

    try {
      if (_mode == AccountAuthMode.create) {
        await provider.createOrLinkWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _usernameController.text.trim(),
        );
        if (!mounted) return;
        context.go(RouteNames.settings, extra: 'Account created and signed in successfully');
      } else {
        await provider.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
        if (!mounted) return;
        context.go(RouteNames.settings, extra: 'Signed in successfully');
      }
    } catch (e) {
      _showError(friendlyAuthError(e.toString()));
    }
  }

  Future<void> _handleForgotPassword(AppProvider provider) async {
    final emailError = validateEmail(_emailController.text);
    if (emailError != null) return _showError(emailError);

    try {
      await provider.sendPasswordResetEmail(email: _emailController.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'If an account exists for this email, reset instructions were sent. Check Inbox and Spam folders.',
          ),
        ),
      );
    } catch (e) {
      _showError(friendlyAuthError(e.toString()));
    }
  }

  Future<void> _confirmDeleteAccount(AppProvider provider) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete account?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'This will permanently delete your account and all data. This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    try {
      await provider.deleteAccount();
      if (!mounted) return;
      context.go(RouteNames.settings, extra: 'Account deleted successfully');
    } catch (e) {
      _showError(friendlyDeleteError(e.toString()));
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }
}
