import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:hive/hive.dart';

import '../../domain/entities/expense.dart';
import '../../domain/entities/financial_profile.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../domain/repositories/financial_profile_repository.dart';
import '../../domain/repositories/user_settings_repository.dart';
import '../../domain/usecases/get_balance_use_case.dart';
import '../../domain/usecases/get_max_spend_per_day_use_case.dart';
import '../../domain/usecases/get_daily_streak_use_case.dart';
import '../../data/repositories_impl/expense_repository_impl.dart';
import '../../data/repositories_impl/financial_profile_repository_impl.dart';
import '../../data/repositories_impl/user_settings_repository_impl.dart';
import '../../data/datasources/auth_service.dart';
import '../../core/services/app_launch_service.dart';

part 'app_provider_data.dart';
part 'app_provider_auth.dart';
part 'app_provider_lifecycle.dart';
part 'app_provider_getters.dart';
part 'app_provider_notifications.dart';
part 'app_provider_cache.dart';

class AppProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  static const String _derivedCacheBoxName = 'derived_cache_box';
  static const String _settingsCacheBoxName = 'settings_cache_box';
  static const String _profileCacheBoxName = 'profile_cache_box';
  static const String _expensesCacheBoxName = 'expenses_cache_box';
  static const bool _enableDerivedCache =
      bool.fromEnvironment('DERIVED_CACHE_ENABLED', defaultValue: true);

  // State
  bool _isInitialized = false;
  bool _isOnline = true;
  bool _suppressRemoteWhileOffline = false;
  String? _uid;
  String? _error;
  bool _isAuthLoading = false;

  List<Expense> _expenses = [];
  FinancialProfile _profile = const FinancialProfile(
    income: 0,
    monthlyBudget: 0,
    incomeUpdatedAt: null,
  );
  UserSettings _settings = const UserSettings();
  String? _dismissedNotification;

  double _balance = 0;
  double _maxSpendPerDay = 0;
  int _dailyStreak = 0;
  bool _hasCachedDerived = false;
  Box<dynamic>? _derivedCacheBox;
  Box<dynamic>? _settingsCacheBox;
  Box<dynamic>? _profileCacheBox;
  Box<dynamic>? _expensesCacheBox;
  String _notification = '';
  int _notificationDayKey = 0;
  int _expenseSignatureCount = 0;
  int _expenseSignatureLatestMillis = 0;

  // Repositories
  ExpenseRepository? _expenseRepo;
  FinancialProfileRepository? _profileRepo;
  UserSettingsRepository? _settingsRepo;

  // Use cases
  final GetBalanceUseCase _getBalance = GetBalanceUseCase();
  final GetMaxSpendPerDayUseCase _getMaxSpendPerDay =
      GetMaxSpendPerDayUseCase();
  final GetDailyStreakUseCase _getDailyStreak = GetDailyStreakUseCase();

  // Stream subscriptions
  StreamSubscription<List<Expense>>? _expenseSub;
  StreamSubscription<FinancialProfile?>? _profileSub;
  StreamSubscription<UserSettings?>? _settingsSub;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  void _notify() => notifyListeners();
  void _recomputeDerived() => _recomputeDerivedImpl(this);

  int _currentDayKey(DateTime now) => _currentDayKeyImpl(now);

  void _recomputeNotification() => _recomputeNotificationImpl(this);

  String _computeNotification({
    required DateTime now,
    required bool budgetWarningEnabled,
    required bool motivationalMessageEnabled,
    required double income,
    required double monthlyBudget,
    required double maxSpendPerDay,
    required List<Expense> expenses,
  }) =>
      _computeNotificationImpl(
        now: now,
        budgetWarningEnabled: budgetWarningEnabled,
        motivationalMessageEnabled: motivationalMessageEnabled,
        income: income,
        monthlyBudget: monthlyBudget,
        maxSpendPerDay: maxSpendPerDay,
        expenses: expenses,
      );

  String _derivedCacheKey(String uid) => _derivedCacheKeyImpl(uid);
  String _settingsCacheKey(String uid) => _settingsCacheKeyImpl(uid);
  String _profileCacheKey(String uid) => _profileCacheKeyImpl(uid);
  String _expensesCacheKey(String uid) => _expensesCacheKeyImpl(uid);

  Future<Box<dynamic>> _openDerivedCacheBox() =>
      _openDerivedCacheBoxImpl(this);

  Future<Box<dynamic>> _openSettingsCacheBox() =>
      _openSettingsCacheBoxImpl(this);

  Future<Box<dynamic>> _openProfileCacheBox() =>
      _openProfileCacheBoxImpl(this);
  Future<Box<dynamic>> _openExpensesCacheBox() =>
      _openExpensesCacheBoxImpl(this);

  _ExpenseSignature _computeExpenseSignature(List<Expense> expenses) =>
      _computeExpenseSignatureImpl(expenses);

  Future<void> _loadDerivedCache() => _loadDerivedCacheImpl(this);

  Future<void> _loadSettingsCache() => _loadSettingsCacheImpl(this);

  Future<void> _loadProfileCache() => _loadProfileCacheImpl(this);
  Future<void> _loadExpensesCache() => _loadExpensesCacheImpl(this);

  Future<void> _persistDerivedCache() => _persistDerivedCacheImpl(this);

  Future<void> _persistSettingsCache() => _persistSettingsCacheImpl(this);

  Future<void> _persistProfileCache() => _persistProfileCacheImpl(this);
  Future<void> _persistExpensesCache() => _persistExpensesCacheImpl(this);

  Future<void> _clearDerivedCache() => _clearDerivedCacheImpl(this);

  Future<void> _clearSettingsCache() => _clearSettingsCacheImpl(this);

  Future<void> _clearProfileCache() => _clearProfileCacheImpl(this);
  Future<void> _clearExpensesCache() => _clearExpensesCacheImpl(this);

  Future<void> initialize() => _initializeImpl(this);

  void _setupRepositories() => _setupRepositoriesImpl(this);

  void _setupStreams() => _setupStreamsImpl(this);

  Future<void> addExpense(Expense expense) => _addExpenseImpl(this, expense);

  Future<void> updateExpense(Expense expense) =>
      _updateExpenseImpl(this, expense);

  Future<void> deleteExpense(String id) => _deleteExpenseImpl(this, id);

  Future<void> updateProfile(FinancialProfile profile) =>
      _updateProfileImpl(this, profile);

  Future<void> updateSettings(UserSettings settings) =>
      _updateSettingsImpl(this, settings);

  void dismissNotification(String notification) =>
      _dismissNotificationImpl(this, notification);

  Future<void> clearAllData() => _clearAllDataImpl(this);

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) =>
      _signInWithEmailAndPasswordImpl(this, email: email, password: password);

  Future<void> createOrLinkWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) =>
      _createOrLinkWithEmailAndPasswordImpl(
        this,
        email: email,
        password: password,
        displayName: displayName,
      );

  Future<void> sendPasswordResetEmail({required String email}) =>
      _sendPasswordResetEmailImpl(this, email: email);

  Future<void> _switchUserDataContext(String uid) =>
      _switchUserDataContextImpl(this, uid);

  Future<void> signOut() => _signOutImpl(this);

  Future<void> deleteAccount() => _deleteAccountImpl(this);

  @override
  void dispose() {
    _disposeImpl(this);
    super.dispose();
  }
}

class _ExpenseSignature {
  final int count;
  final int latestMillis;

  const _ExpenseSignature({
    required this.count,
    required this.latestMillis,
  });
}
