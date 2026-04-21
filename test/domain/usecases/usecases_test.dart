import 'package:flutter_test/flutter_test.dart';
import 'package:better_spent/domain/entities/expense.dart';
import 'package:better_spent/domain/usecases/get_balance_use_case.dart';
import 'package:better_spent/domain/usecases/get_daily_streak_use_case.dart';
import 'package:better_spent/domain/usecases/get_insights_prediction_use_case.dart';
import 'package:better_spent/domain/usecases/get_max_spend_per_day_use_case.dart';
import 'package:better_spent/domain/usecases/get_monthly_summary_use_case.dart';
import 'package:better_spent/domain/usecases/get_spending_by_category_use_case.dart';
import 'package:better_spent/domain/usecases/get_weekly_summary_use_case.dart';
import 'package:better_spent/features/summary/presentation/view_models/summary_view_model.dart';

Expense _expense({
  required String id,
  required double amount,
  required String category,
  required DateTime date,
}) {
  return Expense(
    id: id,
    amount: amount,
    category: category,
    date: date,
    note: '',
  );
}

void main() {
  test('GetBalanceUseCase subtracts total expenses from income', () {
    final useCase = GetBalanceUseCase();
    final expenses = [
      _expense(id: '1', amount: 30, category: 'Food', date: DateTime.now()),
      _expense(id: '2', amount: 20, category: 'Bills', date: DateTime.now()),
    ];

    expect(useCase.execute(100, expenses), 50);
  });

  test('GetWeeklySummaryUseCase includes expenses from start of week', () {
    final useCase = GetWeeklySummaryUseCase();
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(
      startOfWeek.year,
      startOfWeek.month,
      startOfWeek.day,
    );

    final expenses = [
      _expense(id: '1', amount: 10, category: 'Food', date: start),
      _expense(
        id: '2',
        amount: 5,
        category: 'Food',
        date: start.subtract(const Duration(days: 1)),
      ),
    ];

    final result = useCase.execute(expenses);
    expect(result.totalWeeklySpending, 10);
    expect(result.averagePerDay, closeTo(10 / 7, 0.0001));
  });

  test('GetMonthlySummaryUseCase includes only current month expenses', () {
    final useCase = GetMonthlySummaryUseCase();
    final now = DateTime.now();
    final expenses = [
      _expense(id: '1', amount: 40, category: 'Food', date: now),
      _expense(
        id: '2',
        amount: 15,
        category: 'Food',
        date: DateTime(now.year, now.month - 1, 10),
      ),
    ];

    final result = useCase.execute(expenses);
    final totalDaysInMonth = DateTime(now.year, now.month + 1, 0).day;
    expect(result.totalMonthlySpending, 40);
    expect(result.averagePerDay, closeTo(40 / totalDaysInMonth, 0.0001));
  });

  test('GetDailyStreakUseCase counts consecutive days up to last expense', () {
    final useCase = GetDailyStreakUseCase();
    final referenceNow = DateTime(2026, 1, 4, 22, 0);
    final day1 = DateTime(2026, 1, 1, 9, 0);
    final day2 = DateTime(2026, 1, 2, 9, 0);
    final day3 = DateTime(2026, 1, 3, 23, 0);

    final expenses = [
      _expense(id: '1', amount: 5, category: 'Food', date: day1),
      _expense(id: '2', amount: 5, category: 'Food', date: day2),
      _expense(id: '3', amount: 5, category: 'Food', date: day3),
    ];

    // On the next day, streak stays visible until 24 hours after the last entry.
    expect(useCase.execute(expenses, now: referenceNow), 3);
  });

  test('GetDailyStreakUseCase returns 0 when last expense is over 24h ago', () {
    final useCase = GetDailyStreakUseCase();
    final referenceNow = DateTime(2026, 1, 4, 10, 0);

    final expenses = [
      _expense(
        id: '1',
        amount: 5,
        category: 'Food',
        date: DateTime(2026, 1, 3, 9, 0), // 25 hours ago
      ),
    ];

    expect(useCase.execute(expenses, now: referenceNow), 0);
  });

  test('GetDailyStreakUseCase counts including today when expense exists', () {
    final useCase = GetDailyStreakUseCase();
    final referenceNow = DateTime(2026, 1, 4, 10, 0);

    final expenses = [
      _expense(
        id: '1',
        amount: 5,
        category: 'Food',
        date: DateTime(2026, 1, 1, 9, 0),
      ),
      _expense(
        id: '2',
        amount: 5,
        category: 'Food',
        date: DateTime(2026, 1, 2, 9, 0),
      ),
      _expense(
        id: '3',
        amount: 5,
        category: 'Food',
        date: DateTime(2026, 1, 3, 9, 0),
      ),
      _expense(
        id: '4',
        amount: 5,
        category: 'Food',
        date: DateTime(2026, 1, 4, 8, 0),
      ),
    ];

    expect(useCase.execute(expenses, now: referenceNow), 4);
  });

  test('GetMaxSpendPerDayUseCase uses days in current month', () {
    final useCase = GetMaxSpendPerDayUseCase();
    final now = DateTime.now();
    final totalDays = DateTime(now.year, now.month + 1, 0).day;
    final result = useCase.execute(310, []);
    expect(result, closeTo(310 / totalDays, 0.0001));
  });

  test('GetSpendingByCategoryUseCase groups and sorts by amount', () {
    final useCase = GetSpendingByCategoryUseCase();
    final now = DateTime.now();
    final expenses = [
      _expense(id: '1', amount: 30, category: 'Food', date: now),
      _expense(id: '2', amount: 10, category: 'Food', date: now),
      _expense(id: '3', amount: 25, category: 'Bills', date: now),
    ];

    final result = useCase.execute(expenses, budget: 100);
    expect(result.length, 2);
    expect(result.first.category, 'Food');
    expect(result.first.amount, 40);
    expect(result.first.percentage, 40);
  });

  test('SummaryViewModel uses weekly budget for category percentages', () {
    final now = DateTime.now();
    final expenses = [
      _expense(id: '1', amount: 35, category: 'Food', date: now),
    ];

    final vm = SummaryViewModel.fromData(
      expenses: expenses,
      currencySymbol: '\$',
      monthlyBudget: 300,
      income: 1000,
      maxSpendPerDay: 10, // weekly budget = 70
      selectedPeriod: 'This Week',
    );

    expect(vm.categorySpending.length, 1);
    expect(vm.categorySpending.first.category, 'Food');
    expect(vm.categorySpending.first.percentage, closeTo(50, 0.0001));
  });

  test('GetInsightsPredictionUseCase flags zero remaining budget', () {
    final useCase = GetInsightsPredictionUseCase();
    final result = useCase.execute(10, 0, isMonthlyPeriod: true);
    expect(result.willExceedBudget, isTrue);
  });

  test('GetInsightsPredictionUseCase flags projected overspend', () {
    final useCase = GetInsightsPredictionUseCase();
    final result = useCase.execute(20, 10, isMonthlyPeriod: false);
    expect(result.willExceedBudget, isTrue);
  });

  test('GetInsightsPredictionUseCase returns on track when within budget', () {
    final useCase = GetInsightsPredictionUseCase();
    final result = useCase.execute(5, 10, isMonthlyPeriod: true);
    expect(result.willExceedBudget, isFalse);
  });
}
