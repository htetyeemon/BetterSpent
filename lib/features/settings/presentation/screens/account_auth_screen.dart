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
import '../utils/account_auth_logic.dart';

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
    final validationError = AccountAuthLogic.validateForSubmit(
      mode: _mode,
      email: _emailController.text,
      password: _passwordController.text,
      username: _usernameController.text,
      confirmPassword: _confirmPasswordController.text,
    );
    if (validationError != null) return _showError(validationError);

    final result = await AccountAuthLogic.submit(
      provider: provider,
      mode: _mode,
      email: _emailController.text,
      password: _passwordController.text,
      username: _usernameController.text,
    );
    if (!mounted) return;
    if (!result.ok) return _showError(result.error ?? 'Authentication failed');
    context.go(RouteNames.settings, extra: result.message);
  }

  Future<void> _handleForgotPassword(AppProvider provider) async {
    final result = await AccountAuthLogic.sendPasswordReset(
      provider: provider,
      email: _emailController.text,
    );
    if (!mounted) return;
    if (!result.ok) return _showError(result.error ?? 'Request failed');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'If an account exists for this email, reset instructions were sent. Check Inbox and Spam folders.',
        ),
      ),
    );
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
    final result = await AccountAuthLogic.deleteAccount(provider: provider);
    if (!mounted) return;
    if (!result.ok) return _showError(result.error ?? 'Delete failed');
    context.go(RouteNames.settings, extra: result.message);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }
}
