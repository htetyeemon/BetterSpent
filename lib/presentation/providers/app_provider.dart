import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

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
