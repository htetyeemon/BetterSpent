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
  List<CategorySpending> execute(List<Expense> expenses) {
    if (expenses.isEmpty) return [];

    final Map<String, double> categoryTotals = {};
    for (final expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    final total = categoryTotals.values.fold<double>(0, (a, b) => a + b);
    if (total == 0) return [];

    return categoryTotals.entries.map((entry) {
      return CategorySpending(
        category: entry.key,
        amount: entry.value,
        percentage: (entry.value / total) * 100,
      );
    }).toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
  }
}
