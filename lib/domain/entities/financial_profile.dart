class FinancialProfile {
  final double income;
  final double monthlyBudget;

  const FinancialProfile({
    required this.income,
    required this.monthlyBudget,
  });

  FinancialProfile copyWith({double? income, double? monthlyBudget}) {
    return FinancialProfile(
      income: income ?? this.income,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
    );
  }
}
