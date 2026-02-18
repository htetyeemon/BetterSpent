import '../models/expense_model.dart';

class MockData {
  // Mock Expenses
  static final List<ExpenseModel> mockExpenses = [
    ExpenseModel(
      id: '1',
      name: 'Morning Coffee',
      category: 'FOOD & DRINK',
      amount: 4.50,
      date: DateTime.now(),
      note: 'Coffee at Starbucks',
    ),
    ExpenseModel(
      id: '2',
      name: 'Lunch at Subway',
      category: 'FOOD & DRINK',
      amount: 12.30,
      date: DateTime.now(),
      note: 'Subway sandwich combo',
    ),
    ExpenseModel(
      id: '3',
      name: 'Dinner at Olive Garden',
      category: 'FOOD & DRINK',
      amount: 45.00,
      date: DateTime.now().subtract(const Duration(days: 1)),
      note: 'Dinner with friends',
    ),
    ExpenseModel(
      id: '4',
      name: 'Gas Station',
      category: 'TRANSPORT',
      amount: 50.00,
      date: DateTime.now().subtract(const Duration(days: 1)),
      note: 'Full tank',
    ),
    ExpenseModel(
      id: '5',
      name: 'Grocery Shopping',
      category: 'GROCERY',
      amount: 85.20,
      date: DateTime.now().subtract(const Duration(days: 3)),
      note: 'Weekly groceries',
    ),
    ExpenseModel(
      id: '6',
      name: 'Movie Tickets',
      category: 'ENTERTAINMENT',
      amount: 24.00,
      date: DateTime.now().subtract(const Duration(days: 4)),
      note: '2 tickets for Avatar',
    ),
    ExpenseModel(
      id: '7',
      name: 'Uber to Work',
      category: 'TRANSPORT',
      amount: 15.00,
      date: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  // Mock Statistics
  static const double mockBalance = 2543.50;
  static const double mockIncome = 3200.00;
  static const double mockDailyLimit = 100.00;
  static const double mockSpentToday = 16.80;
  static const int mockStreakDays = 7;

  // Mock Category Spending (for Summary)
  static final List<Map<String, dynamic>> mockCategorySpending = [
    {'category': 'FOOD & DRINK', 'amount': 61.80, 'percentage': 39.0},
    {'category': 'TRANSPORT', 'amount': 65.00, 'percentage': 42.0},
    {'category': 'SHOPPING', 'amount': 29.70, 'percentage': 19.0},
  ];

  // Mock Summary Stats
  static const double mockTotalSpent = 156.50;
  static const double mockAvgPerDay = 22.36;

  // Motivational Messages
  static const List<String> motivationalMessages = [
    'You\'re doing great! Keep tracking your expenses daily.',
    'Nice work! You\'re 15% under budget this week.',
    'Keep it up! Small savings add up to big results.',
    'Excellent! You\'re building a healthy financial habit.',
    'Way to go! You\'re on track with your spending goals.',
  ];

  // Helper to get random motivational message
  static String getRandomMotivationalMessage() {
    return motivationalMessages[DateTime.now().millisecond %
        motivationalMessages.length];
  }

  // Get expenses for today
  static List<ExpenseModel> getTodayExpenses() {
    final now = DateTime.now();
    return mockExpenses.where((expense) {
      return expense.date.year == now.year &&
          expense.date.month == now.month &&
          expense.date.day == now.day;
    }).toList();
  }

  // Get expenses for this week
  static List<ExpenseModel> getWeekExpenses() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return mockExpenses.where((expense) {
      return expense.date.isAfter(weekAgo);
    }).toList();
  }

  // Get expenses for this month
  static List<ExpenseModel> getMonthExpenses() {
    final now = DateTime.now();
    return mockExpenses.where((expense) {
      return expense.date.year == now.year && expense.date.month == now.month;
    }).toList();
  }

  // Calculate total from expense list
  static double calculateTotal(List<ExpenseModel> expenses) {
    return expenses.fold(0.0, (sum, expense) => sum + expense.amount);
  }
}
