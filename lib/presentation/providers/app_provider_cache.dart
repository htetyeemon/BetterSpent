part of 'app_provider.dart';

String _derivedCacheKeyImpl(String uid) => 'derived:$uid';
String _settingsCacheKeyImpl(String uid) => 'settings:$uid';
String _profileCacheKeyImpl(String uid) => 'profile:$uid';
String _expensesCacheKeyImpl(String uid) => 'expenses:$uid';

Future<Box<dynamic>> _openDerivedCacheBoxImpl(AppProvider self) async {
  self._derivedCacheBox ??=
      await Hive.openBox<dynamic>(AppProvider._derivedCacheBoxName);
  return self._derivedCacheBox!;
}

Future<Box<dynamic>> _openSettingsCacheBoxImpl(AppProvider self) async {
  self._settingsCacheBox ??=
      await Hive.openBox<dynamic>(AppProvider._settingsCacheBoxName);
  return self._settingsCacheBox!;
}

Future<Box<dynamic>> _openProfileCacheBoxImpl(AppProvider self) async {
  self._profileCacheBox ??=
      await Hive.openBox<dynamic>(AppProvider._profileCacheBoxName);
  return self._profileCacheBox!;
}

Future<Box<dynamic>> _openExpensesCacheBoxImpl(AppProvider self) async {
  self._expensesCacheBox ??=
      await Hive.openBox<dynamic>(AppProvider._expensesCacheBoxName);
  return self._expensesCacheBox!;
}

_ExpenseSignature _computeExpenseSignatureImpl(List<Expense> expenses) {
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

Future<void> _loadDerivedCacheImpl(AppProvider self) async {
  if (!AppProvider._enableDerivedCache) return;
  final uid = self._uid;
  if (uid == null) return;

  final box = await self._openDerivedCacheBox();
  final cached = box.get(self._derivedCacheKey(uid));
  if (cached is Map) {
    final balance = cached['balance'];
    final maxSpendPerDay = cached['maxSpendPerDay'];
    final dailyStreak = cached['dailyStreak'];
    final expenseCount = cached['expenseCount'];
    final expenseLatestMillis = cached['expenseLatestMillis'];
    if (balance is num && maxSpendPerDay is num && dailyStreak is int) {
      self._balance = balance.toDouble();
      self._maxSpendPerDay = maxSpendPerDay.toDouble();
      self._dailyStreak = dailyStreak;
      self._hasCachedDerived = true;
      if (expenseCount is int) {
        self._expenseSignatureCount = expenseCount;
      }
      if (expenseLatestMillis is int) {
        self._expenseSignatureLatestMillis = expenseLatestMillis;
      }
    }
  }
}

Future<void> _loadSettingsCacheImpl(AppProvider self) async {
  final uid = self._uid;
  if (uid == null) return;

  final box = await self._openSettingsCacheBox();
  final cached = box.get(self._settingsCacheKey(uid));
  if (cached is Map) {
    final currency = cached['currency'];
    final aiInputEnabled = cached['aiInputEnabled'];
    final budgetWarningEnabled = cached['budgetWarningEnabled'];
    final motivationalMessageEnabled = cached['motivationalMessageEnabled'];
    if (currency is String &&
        aiInputEnabled is bool &&
        budgetWarningEnabled is bool &&
        motivationalMessageEnabled is bool) {
      self._settings = UserSettings(
        currency: currency,
        aiInputEnabled: aiInputEnabled,
        budgetWarningEnabled: budgetWarningEnabled,
        motivationalMessageEnabled: motivationalMessageEnabled,
      );
    }
  }
}

Future<void> _loadProfileCacheImpl(AppProvider self) async {
  final uid = self._uid;
  if (uid == null) return;

  final box = await self._openProfileCacheBox();
  final cached = box.get(self._profileCacheKey(uid));
  if (cached is Map) {
    final income = cached['income'];
    final monthlyBudget = cached['monthlyBudget'];
    final incomeUpdatedAt = cached['incomeUpdatedAt'];
    if (income is num && monthlyBudget is num) {
      self._profile = FinancialProfile(
        income: income.toDouble(),
        monthlyBudget: monthlyBudget.toDouble(),
        incomeUpdatedAt: incomeUpdatedAt is int
            ? DateTime.fromMillisecondsSinceEpoch(incomeUpdatedAt)
            : null,
      );
    }
  }
}

Future<void> _loadExpensesCacheImpl(AppProvider self) async {
  final uid = self._uid;
  if (uid == null) return;

  final box = await self._openExpensesCacheBox();
  final cached = box.get(self._expensesCacheKey(uid));
  if (cached is List) {
    final expenses = <Expense>[];
    for (final item in cached) {
      if (item is Map) {
        final id = item['id'];
        final amount = item['amount'];
        final category = item['category'];
        final dateMillis = item['dateMillis'];
        final note = item['note'];
        if (id is String &&
            amount is num &&
            category is String &&
            dateMillis is int &&
            note is String) {
          expenses.add(
            Expense(
              id: id,
              amount: amount.toDouble(),
              category: category,
              date: DateTime.fromMillisecondsSinceEpoch(dateMillis),
              note: note,
            ),
          );
        }
      }
    }
    if (expenses.isNotEmpty) {
      self._expenses = expenses;
      final signature = self._computeExpenseSignature(expenses);
      self._expenseSignatureCount = signature.count;
      self._expenseSignatureLatestMillis = signature.latestMillis;
    }
  }
}

Future<void> _persistDerivedCacheImpl(AppProvider self) async {
  if (!AppProvider._enableDerivedCache) return;
  final uid = self._uid;
  if (uid == null) return;
  if (self._derivedCacheBox == null && !self._hasCachedDerived) {
    await self._openDerivedCacheBox();
  }
  final box = self._derivedCacheBox;
  if (box == null) return;
  await box.put(self._derivedCacheKey(uid), {
    'balance': self._balance,
    'maxSpendPerDay': self._maxSpendPerDay,
    'dailyStreak': self._dailyStreak,
    'expenseCount': self._expenseSignatureCount,
    'expenseLatestMillis': self._expenseSignatureLatestMillis,
    'updatedAt': DateTime.now().millisecondsSinceEpoch,
  });
}

Future<void> _persistSettingsCacheImpl(AppProvider self) async {
  final uid = self._uid;
  if (uid == null) return;
  if (self._settingsCacheBox == null) {
    await self._openSettingsCacheBox();
  }
  final box = self._settingsCacheBox;
  if (box == null) return;
  await box.put(self._settingsCacheKey(uid), {
    'currency': self._settings.currency,
    'aiInputEnabled': self._settings.aiInputEnabled,
    'budgetWarningEnabled': self._settings.budgetWarningEnabled,
    'motivationalMessageEnabled': self._settings.motivationalMessageEnabled,
    'updatedAt': DateTime.now().millisecondsSinceEpoch,
  });
}

Future<void> _persistProfileCacheImpl(AppProvider self) async {
  final uid = self._uid;
  if (uid == null) return;
  if (self._profileCacheBox == null) {
    await self._openProfileCacheBox();
  }
  final box = self._profileCacheBox;
  if (box == null) return;
  await box.put(self._profileCacheKey(uid), {
    'income': self._profile.income,
    'monthlyBudget': self._profile.monthlyBudget,
    'incomeUpdatedAt': self._profile.incomeUpdatedAt?.millisecondsSinceEpoch,
    'updatedAt': DateTime.now().millisecondsSinceEpoch,
  });
}

Future<void> _persistExpensesCacheImpl(AppProvider self) async {
  final uid = self._uid;
  if (uid == null) return;
  if (self._expensesCacheBox == null) {
    await self._openExpensesCacheBox();
  }
  final box = self._expensesCacheBox;
  if (box == null) return;
  final encoded = self._expenses
      .map((e) => {
            'id': e.id,
            'amount': e.amount,
            'category': e.category,
            'dateMillis': e.date.millisecondsSinceEpoch,
            'note': e.note,
          })
      .toList(growable: false);
  await box.put(self._expensesCacheKey(uid), encoded);
}

Future<void> _clearDerivedCacheImpl(AppProvider self) async {
  if (!AppProvider._enableDerivedCache) return;
  final uid = self._uid;
  if (uid == null) return;
  final box = self._derivedCacheBox ?? await self._openDerivedCacheBox();
  await box.delete(self._derivedCacheKey(uid));
}

Future<void> _clearSettingsCacheImpl(AppProvider self) async {
  final uid = self._uid;
  if (uid == null) return;
  final box = self._settingsCacheBox ?? await self._openSettingsCacheBox();
  await box.delete(self._settingsCacheKey(uid));
}

Future<void> _clearProfileCacheImpl(AppProvider self) async {
  final uid = self._uid;
  if (uid == null) return;
  final box = self._profileCacheBox ?? await self._openProfileCacheBox();
  await box.delete(self._profileCacheKey(uid));
}

Future<void> _clearExpensesCacheImpl(AppProvider self) async {
  final uid = self._uid;
  if (uid == null) return;
  final box = self._expensesCacheBox ?? await self._openExpensesCacheBox();
  await box.delete(self._expensesCacheKey(uid));
}
