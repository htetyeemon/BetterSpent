part of 'app_provider.dart';

Future<void> _initializeImpl(AppProvider self) async {
    try {
      await self._authService.ensurePersistence();

      // Setup connectivity listener
      self._connectivitySub = Connectivity().onConnectivityChanged.listen((
        List<ConnectivityResult> results,
      ) {
        final online = results.any((r) => r != ConnectivityResult.none);
        if (self._isOnline != online) {
          self._isOnline = online;
          self._notify();
        }
      });

      // Check initial connectivity
      final connectivity = await Connectivity().checkConnectivity();
      self._isOnline = connectivity.any((r) => r != ConnectivityResult.none);

      // Sign in anonymously if not already authenticated
      User? user = self._authService.currentUser;
      user ??= await self._authService.signInAnonymously();
      self._uid = user?.uid;
      await AppLaunchService.refreshForCurrentUser();

      if (self._uid != null) {
        await self._loadSettingsCache();
        await self._loadProfileCache();
        await self._loadDerivedCache();
        self._setupRepositories();
        self._setupStreams();
      }

      self._isInitialized = true;
      self._notify();
    } catch (e, st) {
      debugPrint('App initialization failed: $e');
      debugPrintStack(stackTrace: st);
      self._error = e.toString();
      self._isInitialized = true;
      self._notify();
    }
}

void _setupRepositoriesImpl(AppProvider self) {
  final firestore = FirebaseFirestore.instance;
  self._expenseRepo = ExpenseRepositoryImpl(firestore, self._uid!);
  self._profileRepo = FinancialProfileRepositoryImpl(firestore, self._uid!);
  self._settingsRepo = UserSettingsRepositoryImpl(firestore, self._uid!);
}

void _setupStreamsImpl(AppProvider self) {
  self._expenseSub = self._expenseRepo!.getExpenses().listen(
      (expenses) {
        self._expenses = expenses;
        final signature = self._computeExpenseSignature(expenses);
        final matchesCache = self._hasCachedDerived &&
            signature.count == self._expenseSignatureCount &&
            signature.latestMillis == self._expenseSignatureLatestMillis;
        if (!matchesCache) {
          self._expenseSignatureCount = signature.count;
          self._expenseSignatureLatestMillis = signature.latestMillis;
          self._recomputeDerived();
        }
        self._recomputeNotification();
        self._notify();
      },
      onError: (e, st) {
        debugPrint('Expense stream error: $e');
        if (st != null) {
          debugPrintStack(stackTrace: st);
        }
        self._error = e.toString();
        self._notify();
      },
    );

  self._profileSub = self._profileRepo!.getProfile().listen((profile) {
      if (profile != null) {
        self._profile = profile;
        self._recomputeDerived();
        self._recomputeNotification();
        self._notify();
        unawaited(self._persistProfileCache());
      }
    });

  self._settingsSub = self._settingsRepo!.getSettings().listen((settings) {
      if (settings != null) {
        self._settings = settings;
        self._recomputeNotification();
        self._notify();
        unawaited(self._persistSettingsCache());
      }
    });
}

Future<void> _addExpenseImpl(AppProvider self, Expense expense) async {
  await self._expenseRepo?.addExpense(expense);
}

Future<void> _updateExpenseImpl(AppProvider self, Expense expense) async {
  await self._expenseRepo?.updateExpense(expense);
}

Future<void> _deleteExpenseImpl(AppProvider self, String id) async {
  await self._expenseRepo?.deleteExpense(id);
}

Future<void> _updateProfileImpl(
  AppProvider self,
  FinancialProfile profile,
) async {
  await self._profileRepo?.updateProfile(profile);
  unawaited(self._persistProfileCache());
}

Future<void> _updateSettingsImpl(
  AppProvider self,
  UserSettings settings,
) async {
  self._settings = settings;
  self._recomputeNotification();
  self._notify();
  unawaited(self._persistSettingsCache());
  await self._settingsRepo?.updateSettings(settings);
}

void _dismissNotificationImpl(AppProvider self, String notification) {
  if (self._dismissedNotification == notification) return;
  self._dismissedNotification = notification;
  self._notify();
}

Future<void> _clearAllDataImpl(AppProvider self) async {
  await self._expenseRepo?.deleteAllExpenses();
  await self._profileRepo?.deleteProfile();
  await self._settingsRepo?.deleteSettings();
  self._expenses = [];
  self._profile = const FinancialProfile(
      income: 0,
      monthlyBudget: 0,
      incomeUpdatedAt: null,
    );
  self._settings = const UserSettings();
  self._dismissedNotification = null;
  self._notification = '';
  self._notificationDayKey = 0;
  self._expenseSignatureCount = 0;
  self._expenseSignatureLatestMillis = 0;
  await self._clearDerivedCache();
  await self._clearSettingsCache();
  await self._clearProfileCache();
  self._recomputeDerived();
  self._notify();
}
