import '../entities/expense.dart';

class CategorySpending {
  final String category;
  final double amount;
  final double percentage;

  const CategorySpending({
    required this.category,
    required this.amount,
    required this.percentage,
  });
}

class GetSpendingByCategoryUseCase {
  List<CategorySpending> execute(
    List<Expense> expenses, {
    required double monthlyBudget,
  }) {
    if (expenses.isEmpty) return [];

    final Map<String, double> categoryTotals = {};
    for (final expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    return categoryTotals.entries.map((entry) {
      final percentage = monthlyBudget > 0
          ? (entry.value / monthlyBudget) * 100
          : 0.0;
      return CategorySpending(
        category: entry.key,
        amount: entry.value,
        percentage: percentage,
      );
    }).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
  }
}
