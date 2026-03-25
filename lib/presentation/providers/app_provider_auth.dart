part of 'app_provider.dart';

Future<void> _signInWithEmailAndPasswordImpl(
  AppProvider self, {
  required String email,
  required String password,
}) async {
  self._isAuthLoading = true;
  self._error = null;
  self._notify();
    try {
      final user = await self._authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final newUid = user?.uid;
      if (newUid != null) {
        await self._switchUserDataContext(newUid);
      }
      await AppLaunchService.refreshForCurrentUser();
      self._notify();
    } catch (e) {
      self._error = e.toString();
      self._notify();
      rethrow;
    } finally {
      self._isAuthLoading = false;
      self._notify();
    }
}

Future<void> _createOrLinkWithEmailAndPasswordImpl(
  AppProvider self, {
  required String email,
  required String password,
  String? displayName,
}) async {
  self._isAuthLoading = true;
  self._error = null;
  self._notify();
    try {
      final user = self.isAnonymous
          ? await self._authService.linkAnonymousWithEmailAndPassword(
              email: email,
              password: password,
              displayName: displayName,
            )
          : await self._authService.createUserWithEmailAndPassword(
              email: email,
              password: password,
              displayName: displayName,
            );
      final newUid = user?.uid;
      if (newUid != null) {
        await self._switchUserDataContext(newUid);
      }
      await AppLaunchService.refreshForCurrentUser();
      self._notify();
    } catch (e) {
      self._error = e.toString();
      self._notify();
      rethrow;
    } finally {
      self._isAuthLoading = false;
      self._notify();
    }
}

Future<void> _sendPasswordResetEmailImpl(
  AppProvider self, {
  required String email,
}) async {
  self._isAuthLoading = true;
  self._error = null;
  self._notify();
    try {
      await self._authService.sendPasswordResetEmail(email: email);
    } catch (e) {
      self._error = e.toString();
      self._notify();
      rethrow;
    } finally {
      self._isAuthLoading = false;
      self._notify();
    }
}

Future<void> _switchUserDataContextImpl(AppProvider self, String uid) async {
  if (self._uid == uid && self._expenseRepo != null) return;

  await self._expenseSub?.cancel();
  await self._profileSub?.cancel();
  await self._settingsSub?.cancel();

  self._uid = uid;
  self._expenses = [];
  self._profile = const FinancialProfile(
      income: 0,
      monthlyBudget: 0,
      incomeUpdatedAt: null,
    );
  self._settings = const UserSettings();
  self._dismissedNotification = null;

  self._setupRepositories();
  self._setupStreams();
}

Future<void> _signOutImpl(AppProvider self) async {
  await self._authService.signOut();
  self._uid = null;
  self._expenses = [];
  self._profile = const FinancialProfile(
      income: 0,
      monthlyBudget: 0,
      incomeUpdatedAt: null,
    );
  self._settings = const UserSettings();
  self._dismissedNotification = null;
  self._expenseSub?.cancel();
  self._profileSub?.cancel();
  self._settingsSub?.cancel();
  self._notify();
  // Re-initialize with anonymous sign-in
  await self.initialize();
}

Future<void> _deleteAccountImpl(AppProvider self) async {
  self._isAuthLoading = true;
  self._error = null;
  self._notify();
    try {
      await self.clearAllData();
      await self._authService.deleteCurrentUser();

      self._uid = null;
      self._expenses = [];
      self._profile = const FinancialProfile(
        income: 0,
        monthlyBudget: 0,
        incomeUpdatedAt: null,
      );
      self._settings = const UserSettings();
      self._dismissedNotification = null;
      await self._expenseSub?.cancel();
      await self._profileSub?.cancel();
      await self._settingsSub?.cancel();
      self._notify();

      // Re-initialize with anonymous sign-in after account deletion.
      await self.initialize();
    } catch (e) {
      self._error = e.toString();
      self._notify();
      rethrow;
    } finally {
      self._isAuthLoading = false;
      self._notify();
    }
}
