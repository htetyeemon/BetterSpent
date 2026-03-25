import '../../../../presentation/providers/app_provider.dart';
import '../screens/account_auth_validators.dart';
import '../widgets/account_auth_form.dart';

class AccountAuthResult {
  final bool ok;
  final String? message;
  final String? error;

  const AccountAuthResult._(this.ok, {this.message, this.error});

  const AccountAuthResult.success(String message)
      : this._(true, message: message);

  const AccountAuthResult.failure(String error)
      : this._(false, error: error);
}

class AccountAuthLogic {
  static String? validateForSubmit({
    required AccountAuthMode mode,
    required String email,
    required String password,
    required String username,
    required String confirmPassword,
  }) {
    final emailError = validateEmail(email);
    if (emailError != null) return emailError;

    final passwordError = validatePassword(password);
    if (passwordError != null) return passwordError;

    if (mode == AccountAuthMode.create) {
      final usernameError = validateUsername(username);
      if (usernameError != null) return usernameError;
      if (confirmPassword != password) {
        return 'Passwords do not match';
      }
    }

    return null;
  }

  static Future<AccountAuthResult> submit({
    required AppProvider provider,
    required AccountAuthMode mode,
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      if (mode == AccountAuthMode.create) {
        await provider.createOrLinkWithEmailAndPassword(
          email: email.trim(),
          password: password,
          displayName: username.trim(),
        );
        return const AccountAuthResult.success(
          'Account created and signed in successfully',
        );
      }

      await provider.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return const AccountAuthResult.success('Signed in successfully');
    } catch (e) {
      return AccountAuthResult.failure(friendlyAuthError(e.toString()));
    }
  }

  static Future<AccountAuthResult> sendPasswordReset({
    required AppProvider provider,
    required String email,
  }) async {
    final emailError = validateEmail(email);
    if (emailError != null) {
      return AccountAuthResult.failure(emailError);
    }

    try {
      await provider.sendPasswordResetEmail(email: email.trim());
      return const AccountAuthResult.success('ok');
    } catch (e) {
      return AccountAuthResult.failure(friendlyAuthError(e.toString()));
    }
  }

  static Future<AccountAuthResult> deleteAccount({
    required AppProvider provider,
  }) async {
    try {
      await provider.deleteAccount();
      return const AccountAuthResult.success('Account deleted successfully');
    } catch (e) {
      return AccountAuthResult.failure(friendlyDeleteError(e.toString()));
    }
  }
}
