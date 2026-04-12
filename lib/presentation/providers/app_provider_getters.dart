part of 'app_provider.dart';

extension AppProviderGetters on AppProvider {
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
    return CurrencyCatalog.symbolForCode(_settings.currency);
  }
}
