import '../entities/expense.dart';

class GetBalanceUseCase {
  double execute(double income, List<Expense> expenses) {
    final total = expenses.fold<double>(0.0, (sum, e) => sum + e.amount);
    return income - total;
  }
}
