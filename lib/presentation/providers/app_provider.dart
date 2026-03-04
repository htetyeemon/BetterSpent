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

  double get balance => _getBalance.execute(_profile.income, _expenses);
  double get maxSpendPerDay =>
      _getMaxSpendPerDay.execute(_profile.monthlyBudget, _expenses);
  int get dailyStreak => _getDailyStreak.execute(_expenses);

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

  Future<void> initialize() async {
    try {
      await _authService.ensurePersistence();

      // Setup connectivity listener
      _connectivitySub = Connectivity().onConnectivityChanged.listen((
        List<ConnectivityResult> results,
      ) {
        final online = results.any((r) => r != ConnectivityResult.none);
        if (_isOnline != online) {
          _isOnline = online;
          notifyListeners();
        }
      });

      // Check initial connectivity
      final connectivity = await Connectivity().checkConnectivity();
      _isOnline = connectivity.any((r) => r != ConnectivityResult.none);

      // Sign in anonymously if not already authenticated
      User? user = _authService.currentUser;
      user ??= await _authService.signInAnonymously();
      _uid = user?.uid;
      await AppLaunchService.refreshForCurrentUser();

      if (_uid != null) {
        _setupRepositories();
        _setupStreams();
      }

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isInitialized = true;
      notifyListeners();
    }
  }

  void _setupRepositories() {
    final firestore = FirebaseFirestore.instance;
    _expenseRepo = ExpenseRepositoryImpl(firestore, _uid!);
    _profileRepo = FinancialProfileRepositoryImpl(firestore, _uid!);
    _settingsRepo = UserSettingsRepositoryImpl(firestore, _uid!);
  }

  void _setupStreams() {
    _expenseSub = _expenseRepo!.getExpenses().listen(
      (expenses) {
        _expenses = expenses;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        notifyListeners();
      },
    );

    _profileSub = _profileRepo!.getProfile().listen((profile) {
      if (profile != null) {
        _profile = profile;
        notifyListeners();
      }
    });

    _settingsSub = _settingsRepo!.getSettings().listen((settings) {
      if (settings != null) {
        _settings = settings;
        notifyListeners();
      }
    });
  }

  Future<void> addExpense(Expense expense) async {
    await _expenseRepo?.addExpense(expense);
  }

  Future<void> updateExpense(Expense expense) async {
    await _expenseRepo?.updateExpense(expense);
  }

  Future<void> deleteExpense(String id) async {
    await _expenseRepo?.deleteExpense(id);
  }

  Future<void> updateProfile(FinancialProfile profile) async {
    await _profileRepo?.updateProfile(profile);
  }

  Future<void> updateSettings(UserSettings settings) async {
    _settings = settings;
    notifyListeners();
    await _settingsRepo?.updateSettings(settings);
  }

  Future<void> clearAllData() async {
    await _expenseRepo?.deleteAllExpenses();
    await _profileRepo?.deleteProfile();
    await _settingsRepo?.deleteSettings();
    _expenses = [];
    _profile = const FinancialProfile(
      income: 0,
      monthlyBudget: 0,
      incomeUpdatedAt: null,
    );
    _settings = const UserSettings();
    notifyListeners();
  }

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    _isAuthLoading = true;
    _error = null;
    notifyListeners();
    try {
      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final newUid = user?.uid;
      if (newUid != null) {
        await _switchUserDataContext(newUid);
      }
      await AppLaunchService.refreshForCurrentUser();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isAuthLoading = false;
      notifyListeners();
    }
  }

  Future<void> createOrLinkWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    _isAuthLoading = true;
    _error = null;
    notifyListeners();
    try {
      final user = isAnonymous
          ? await _authService.linkAnonymousWithEmailAndPassword(
              email: email,
              password: password,
              displayName: displayName,
            )
          : await _authService.createUserWithEmailAndPassword(
              email: email,
              password: password,
              displayName: displayName,
            );
      final newUid = user?.uid;
      if (newUid != null) {
        await _switchUserDataContext(newUid);
      }
      await AppLaunchService.refreshForCurrentUser();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isAuthLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    _isAuthLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.sendPasswordResetEmail(email: email);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isAuthLoading = false;
      notifyListeners();
    }
  }

  Future<void> _switchUserDataContext(String uid) async {
    if (_uid == uid && _expenseRepo != null) return;

    await _expenseSub?.cancel();
    await _profileSub?.cancel();
    await _settingsSub?.cancel();

    _uid = uid;
    _expenses = [];
    _profile = const FinancialProfile(
      income: 0,
      monthlyBudget: 0,
      incomeUpdatedAt: null,
    );
    _settings = const UserSettings();

    _setupRepositories();
    _setupStreams();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _uid = null;
    _expenses = [];
    _profile = const FinancialProfile(
      income: 0,
      monthlyBudget: 0,
      incomeUpdatedAt: null,
    );
    _settings = const UserSettings();
    _expenseSub?.cancel();
    _profileSub?.cancel();
    _settingsSub?.cancel();
    notifyListeners();
    // Re-initialize with anonymous sign-in
    await initialize();
  }

  Future<void> deleteAccount() async {
    _isAuthLoading = true;
    _error = null;
    notifyListeners();
    try {
      await clearAllData();
      await _authService.deleteCurrentUser();

      _uid = null;
      _expenses = [];
      _profile = const FinancialProfile(
        income: 0,
        monthlyBudget: 0,
        incomeUpdatedAt: null,
      );
      _settings = const UserSettings();
      await _expenseSub?.cancel();
      await _profileSub?.cancel();
      await _settingsSub?.cancel();
      notifyListeners();

      // Re-initialize with anonymous sign-in after account deletion.
      await initialize();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isAuthLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _expenseSub?.cancel();
    _profileSub?.cancel();
    _settingsSub?.cancel();
    _connectivitySub?.cancel();
    super.dispose();
  }
}
