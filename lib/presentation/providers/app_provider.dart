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

class AppProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  static const String _derivedCacheBoxName = 'derived_cache_box';
  static const String _settingsCacheBoxName = 'settings_cache_box';
  static const String _profileCacheBoxName = 'profile_cache_box';
  static const bool _enableDerivedCache =
      bool.fromEnvironment('DERIVED_CACHE_ENABLED', defaultValue: true);

  // State
  bool _isInitialized = false;
  bool _isOnline = true;
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

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isOnline => _isOnline;
  String? get uid => _uid;
  String? get error => _error;
  bool get isAuthLoading => _isAuthLoading;
  bool get isAnonymous => _authService.isAnonymous;
  bool get isEmailUser => _authService.isEmailUser;
  String? get accountEmail => _authService.currentUser?.email;
  String get accountName {
    final displayName = _authService.currentUser?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;

    final email = _authService.currentUser?.email;
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }

    return 'Account';
  }

  List<Expense> get expenses => _expenses;
  FinancialProfile get profile => _profile;
  UserSettings get settings => _settings;
  String? get dismissedNotification => _dismissedNotification;

  double get balance => _balance;
  double get maxSpendPerDay => _maxSpendPerDay;
  int get dailyStreak => _dailyStreak;
  String get notification {
    final todayKey = _currentDayKey(DateTime.now());
    if (_notificationDayKey != todayKey) {
      _recomputeNotification();
    }
    return _notification;
  }

  String get currencySymbol {
    switch (_settings.currency) {
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
      case 'CNY':
        return '¥';
      case 'CHF':
        return 'Fr';
      case 'INR':
        return '₹';
      case 'THB':
        return '฿';
      case 'KRW':
        return '₩';
      case 'SEK':
      case 'NOK':
        return 'kr';
      case 'BRL':
        return 'R\$';
      case 'ZAR':
        return 'R';
      case 'RUB':
        return '₽';
      default:
        return '\$';
    }
  }

  void _notify() => notifyListeners();
  void _recomputeDerived() {
    _balance = _getBalance.execute(_profile.income, _expenses);
    _maxSpendPerDay = _getMaxSpendPerDay.execute(
      _profile.monthlyBudget,
      _expenses,
    );
    _dailyStreak = _getDailyStreak.execute(_expenses);
    unawaited(_persistDerivedCache());
  }

  int _currentDayKey(DateTime now) =>
      (now.year * 10000) + (now.month * 100) + now.day;

  void _recomputeNotification() {
    final now = DateTime.now();
    _notification = _computeNotification(
      now: now,
      budgetWarningEnabled: _settings.budgetWarningEnabled,
      motivationalMessageEnabled: _settings.motivationalMessageEnabled,
      income: _profile.income,
      monthlyBudget: _profile.monthlyBudget,
      maxSpendPerDay: _maxSpendPerDay,
      expenses: _expenses,
    );
    _notificationDayKey = _currentDayKey(now);
  }

  String _computeNotification({
    required DateTime now,
    required bool budgetWarningEnabled,
    required bool motivationalMessageEnabled,
    required double income,
    required double monthlyBudget,
    required double maxSpendPerDay,
    required List<Expense> expenses,
  }) {
    if (income == 0 && monthlyBudget == 0) {
      return '';
    }

    double todaySpending = 0.0;
    double totalMonthSpending = 0.0;
    double totalSpending = 0.0;
    for (final expense in expenses) {
      totalSpending += expense.amount;
      if (expense.date.year == now.year && expense.date.month == now.month) {
        totalMonthSpending += expense.amount;
        if (expense.date.day == now.day) {
          todaySpending += expense.amount;
        }
      }
    }

    final hasWarning = (maxSpendPerDay > 0 && todaySpending > maxSpendPerDay) ||
        totalMonthSpending > monthlyBudget ||
        totalSpending > income;

    if (hasWarning && budgetWarningEnabled) {
      if (totalSpending > income) {
        return '⚠️ Your total spending has exceeded your income!';
      } else if (totalMonthSpending > monthlyBudget) {
        return '⚠️ You\'ve exceeded your monthly budget!';
      } else {
        return '⚠️ You\'ve exceeded your daily spending limit!';
      }
    }

    if (!hasWarning && motivationalMessageEnabled) {
      const messages = [
        'You\'re doing great! Keep tracking your expenses daily.',
        'Nice work! You\'re building a healthy financial habit.',
        'Keep it up! Small savings add up to big results.',
      ];
      final daySeed = (now.year * 10000) + (now.month * 100) + now.day;
      return messages[daySeed % messages.length];
    }

    return '';
  }

  String _derivedCacheKey(String uid) => 'derived:$uid';
  String _settingsCacheKey(String uid) => 'settings:$uid';
  String _profileCacheKey(String uid) => 'profile:$uid';

  Future<Box<dynamic>> _openDerivedCacheBox() async {
    _derivedCacheBox ??= await Hive.openBox<dynamic>(_derivedCacheBoxName);
    return _derivedCacheBox!;
  }

  Future<Box<dynamic>> _openSettingsCacheBox() async {
    _settingsCacheBox ??= await Hive.openBox<dynamic>(_settingsCacheBoxName);
    return _settingsCacheBox!;
  }

  Future<Box<dynamic>> _openProfileCacheBox() async {
    _profileCacheBox ??= await Hive.openBox<dynamic>(_profileCacheBoxName);
    return _profileCacheBox!;
  }

  _ExpenseSignature _computeExpenseSignature(List<Expense> expenses) {
    int latestMillis = 0;
    for (final expense in expenses) {
      final millis = expense.date.millisecondsSinceEpoch;
      if (millis > latestMillis) {
        latestMillis = millis;
      }
    }
    return _ExpenseSignature(
      count: expenses.length,
      latestMillis: latestMillis,
    );
  }

  Future<void> _loadDerivedCache() async {
    if (!_enableDerivedCache) return;
    final uid = _uid;
    if (uid == null) return;

    final box = await _openDerivedCacheBox();
    final cached = box.get(_derivedCacheKey(uid));
    if (cached is Map) {
      final balance = cached['balance'];
      final maxSpendPerDay = cached['maxSpendPerDay'];
      final dailyStreak = cached['dailyStreak'];
      final expenseCount = cached['expenseCount'];
      final expenseLatestMillis = cached['expenseLatestMillis'];
      if (balance is num && maxSpendPerDay is num && dailyStreak is int) {
        _balance = balance.toDouble();
        _maxSpendPerDay = maxSpendPerDay.toDouble();
        _dailyStreak = dailyStreak;
        _hasCachedDerived = true;
        if (expenseCount is int) {
          _expenseSignatureCount = expenseCount;
        }
        if (expenseLatestMillis is int) {
          _expenseSignatureLatestMillis = expenseLatestMillis;
        }
      }
    }
  }

  Future<void> _loadSettingsCache() async {
    final uid = _uid;
    if (uid == null) return;

    final box = await _openSettingsCacheBox();
    final cached = box.get(_settingsCacheKey(uid));
    if (cached is Map) {
      final currency = cached['currency'];
      final aiInputEnabled = cached['aiInputEnabled'];
      final budgetWarningEnabled = cached['budgetWarningEnabled'];
      final motivationalMessageEnabled = cached['motivationalMessageEnabled'];
      if (currency is String &&
          aiInputEnabled is bool &&
          budgetWarningEnabled is bool &&
          motivationalMessageEnabled is bool) {
        _settings = UserSettings(
          currency: currency,
          aiInputEnabled: aiInputEnabled,
          budgetWarningEnabled: budgetWarningEnabled,
          motivationalMessageEnabled: motivationalMessageEnabled,
        );
      }
    }
  }

  Future<void> _loadProfileCache() async {
    final uid = _uid;
    if (uid == null) return;

    final box = await _openProfileCacheBox();
    final cached = box.get(_profileCacheKey(uid));
    if (cached is Map) {
      final income = cached['income'];
      final monthlyBudget = cached['monthlyBudget'];
      final incomeUpdatedAt = cached['incomeUpdatedAt'];
      if (income is num && monthlyBudget is num) {
        _profile = FinancialProfile(
          income: income.toDouble(),
          monthlyBudget: monthlyBudget.toDouble(),
          incomeUpdatedAt: incomeUpdatedAt is int
              ? DateTime.fromMillisecondsSinceEpoch(incomeUpdatedAt)
              : null,
        );
      }
    }
  }

  Future<void> _persistDerivedCache() async {
    if (!_enableDerivedCache) return;
    final uid = _uid;
    if (uid == null) return;
    if (_derivedCacheBox == null && !_hasCachedDerived) {
      await _openDerivedCacheBox();
    }
    final box = _derivedCacheBox;
    if (box == null) return;
    await box.put(_derivedCacheKey(uid), {
      'balance': _balance,
      'maxSpendPerDay': _maxSpendPerDay,
      'dailyStreak': _dailyStreak,
      'expenseCount': _expenseSignatureCount,
      'expenseLatestMillis': _expenseSignatureLatestMillis,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> _persistSettingsCache() async {
    final uid = _uid;
    if (uid == null) return;
    if (_settingsCacheBox == null) {
      await _openSettingsCacheBox();
    }
    final box = _settingsCacheBox;
    if (box == null) return;
    await box.put(_settingsCacheKey(uid), {
      'currency': _settings.currency,
      'aiInputEnabled': _settings.aiInputEnabled,
      'budgetWarningEnabled': _settings.budgetWarningEnabled,
      'motivationalMessageEnabled': _settings.motivationalMessageEnabled,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> _persistProfileCache() async {
    final uid = _uid;
    if (uid == null) return;
    if (_profileCacheBox == null) {
      await _openProfileCacheBox();
    }
    final box = _profileCacheBox;
    if (box == null) return;
    await box.put(_profileCacheKey(uid), {
      'income': _profile.income,
      'monthlyBudget': _profile.monthlyBudget,
      'incomeUpdatedAt': _profile.incomeUpdatedAt?.millisecondsSinceEpoch,
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> _clearDerivedCache() async {
    if (!_enableDerivedCache) return;
    final uid = _uid;
    if (uid == null) return;
    final box = _derivedCacheBox ?? await _openDerivedCacheBox();
    await box.delete(_derivedCacheKey(uid));
  }

  Future<void> _clearSettingsCache() async {
    final uid = _uid;
    if (uid == null) return;
    final box = _settingsCacheBox ?? await _openSettingsCacheBox();
    await box.delete(_settingsCacheKey(uid));
  }

  Future<void> _clearProfileCache() async {
    final uid = _uid;
    if (uid == null) return;
    final box = _profileCacheBox ?? await _openProfileCacheBox();
    await box.delete(_profileCacheKey(uid));
  }

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
