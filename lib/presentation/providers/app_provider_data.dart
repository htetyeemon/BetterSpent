part of 'app_provider.dart';

Future<void> _initializeImpl(AppProvider self) async {
  try {
    await self._authService.ensurePersistence();

    self._connectivitySub = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (self._isOnline == online) return;

      self._isOnline = online;
      if (online) {
        self._suppressRemoteWhileOffline = false;
        unawaited(self._ensureRemoteSession());
      }
      self._notify();
    });

    final connectivity = await Connectivity().checkConnectivity();
    self._isOnline = connectivity.any((r) => r != ConnectivityResult.none);

    final cachedUid = await self._loadLastKnownUid();
    if (cachedUid != null) {
      await self._hydrateCachedStateForUid(cachedUid);
      self._notify();
    }

    User? user = self._authService.currentUser;
    if (user == null && self._isOnline) {
      try {
        user = await self._authService.signInAnonymously();
      } catch (e, st) {
        debugPrint('Anonymous sign-in skipped during initialization: $e');
        debugPrintStack(stackTrace: st);
      }
    }

    final liveUid = user?.uid;
    if (liveUid != null) {
      await self._persistLastKnownUid(liveUid);
      await self._hydrateCachedStateForUid(liveUid);
      self._notify();
      self._setupRepositories();
      if (self._isOnline) {
        self._setupStreams();
      }
    }

    await AppLaunchService.refreshForCurrentUser();
    self._error = null;
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

Future<void> _ensureRemoteSessionImpl(AppProvider self) async {
  if (!self._isOnline) return;

  try {
    User? user = self._authService.currentUser;
    user ??= await self._authService.signInAnonymously();
    final uid = user?.uid;
    if (uid == null) return;

    await self._persistLastKnownUid(uid);

    final needsContextSwitch = self._uid != uid;
    if (needsContextSwitch) {
      await self._switchUserDataContext(uid);
    } else {
      self._setupRepositories();
      if (self._expenseSub == null &&
          self._profileSub == null &&
          self._settingsSub == null) {
        self._setupStreams();
      }
    }

    await AppLaunchService.refreshForCurrentUser();
    self._error = null;
    self._notify();
  } catch (e, st) {
    debugPrint('Remote session restore failed: $e');
    debugPrintStack(stackTrace: st);
  }
}

void _setupRepositoriesImpl(AppProvider self) {
  if (self._uid == null) return;
  final firestore = FirebaseFirestore.instance;
  self._expenseRepo = ExpenseRepositoryImpl(firestore, self._uid!);
  self._profileRepo = FinancialProfileRepositoryImpl(firestore, self._uid!);
  self._settingsRepo = UserSettingsRepositoryImpl(firestore, self._uid!);
}

void _setupStreamsImpl(AppProvider self) {
  if (!self._isOnline ||
      self._expenseRepo == null ||
      self._profileRepo == null ||
      self._settingsRepo == null) {
    return;
  }
  self._expenseSub = self._expenseRepo!.getExpenses().listen(
    (expenses) {
      if (!self._isOnline && self._suppressRemoteWhileOffline) {
        return;
      }
      if (!self._isOnline && expenses.isEmpty && self._expenses.isNotEmpty) {
        // Keep cached expenses visible when offline and Firestore returns empty.
        return;
      }
      var nextExpenses = expenses;
      if (!self._isOnline) {
        nextExpenses = _mergeOfflineExpenses(self._expenses, expenses);
      }
      self._expenses = nextExpenses;
      final signature = self._computeExpenseSignature(nextExpenses);
      final matchesCache =
          self._hasCachedDerived &&
          signature.count == self._expenseSignatureCount &&
          signature.latestMillis == self._expenseSignatureLatestMillis;
      if (!matchesCache) {
        self._expenseSignatureCount = signature.count;
        self._expenseSignatureLatestMillis = signature.latestMillis;
        self._recomputeDerived();
      }
      self._recomputeNotification();
      self._notify();
      unawaited(self._persistExpensesCache());
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
    if (!self._isOnline && self._suppressRemoteWhileOffline) {
      return;
    }
    if (profile != null) {
      self._profile = profile;
      self._recomputeDerived();
      self._recomputeNotification();
      self._notify();
      unawaited(self._persistProfileCache());
    }
  });

  self._settingsSub = self._settingsRepo!.getSettings().listen((settings) {
    if (!self._isOnline && self._suppressRemoteWhileOffline) {
      return;
    }
    if (settings != null) {
      self._settings = settings;
      self._recomputeNotification();
      self._notify();
      unawaited(self._persistSettingsCache());
    }
  });
}

Future<void> _addExpenseImpl(AppProvider self, Expense expense) async {
  var nextExpense = expense;
  if (nextExpense.id.isEmpty && self._uid != null) {
    final id = FirebaseFirestore.instance
        .collection('users')
        .doc(self._uid)
        .collection('expenses')
        .doc()
        .id;
    nextExpense = nextExpense.copyWith(id: id);
  }
  if (!self._isOnline) {
    self._expenses = _mergeOfflineExpenses(self._expenses, [nextExpense]);
    final signature = self._computeExpenseSignature(self._expenses);
    self._expenseSignatureCount = signature.count;
    self._expenseSignatureLatestMillis = signature.latestMillis;
    self._recomputeDerived();
    self._recomputeNotification();
    self._notify();
    unawaited(self._persistExpensesCache());
  }
  await self._expenseRepo?.addExpense(nextExpense);
}

Future<void> _updateExpenseImpl(AppProvider self, Expense expense) async {
  if (!self._isOnline) {
    self._expenses = _mergeOfflineExpenses(self._expenses, [expense]);
    final signature = self._computeExpenseSignature(self._expenses);
    self._expenseSignatureCount = signature.count;
    self._expenseSignatureLatestMillis = signature.latestMillis;
    self._recomputeDerived();
    self._recomputeNotification();
    self._notify();
    unawaited(self._persistExpensesCache());
  }
  await self._expenseRepo?.updateExpense(expense);
}

Future<void> _deleteExpenseImpl(AppProvider self, String id) async {
  if (!self._isOnline) {
    self._expenses = self._expenses.where((e) => e.id != id).toList();
    final signature = self._computeExpenseSignature(self._expenses);
    self._expenseSignatureCount = signature.count;
    self._expenseSignatureLatestMillis = signature.latestMillis;
    self._recomputeDerived();
    self._recomputeNotification();
    self._notify();
    unawaited(self._persistExpensesCache());
  }
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
  final wasOnline = self._isOnline;
  if (!wasOnline) {
    self._suppressRemoteWhileOffline = true;
  }
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
  await self._clearExpensesCache();
  self._recomputeDerived();
  self._notify();
  if (wasOnline) {
    await self._expenseRepo?.deleteAllExpenses();
    await self._profileRepo?.deleteProfile();
    await self._settingsRepo?.deleteSettings();
  } else {
    unawaited(self._expenseRepo?.deleteAllExpenses());
    unawaited(self._profileRepo?.deleteProfile());
    unawaited(self._settingsRepo?.deleteSettings());
  }
}

String _offlineExpenseKey(Expense expense) {
  if (expense.id.isNotEmpty) {
    return 'id:${expense.id}';
  }
  return 'sig:${expense.date.millisecondsSinceEpoch}'
      '|${expense.amount}'
      '|${expense.category}'
      '|${expense.note}';
}

List<Expense> _mergeOfflineExpenses(
  List<Expense> current,
  List<Expense> incoming,
) {
  if (current.isEmpty) {
    final merged = List<Expense>.from(incoming);
    merged.sort((a, b) => b.date.compareTo(a.date));
    return merged;
  }
  final Map<String, Expense> merged = {};
  for (final expense in current) {
    merged[_offlineExpenseKey(expense)] = expense;
  }
  for (final expense in incoming) {
    merged[_offlineExpenseKey(expense)] = expense;
  }
  final list = merged.values.toList();
  list.sort((a, b) => b.date.compareTo(a.date));
  return list;
}
