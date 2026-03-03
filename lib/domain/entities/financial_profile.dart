class FinancialProfile {
  final double income;
  final double monthlyBudget;
  final DateTime? incomeUpdatedAt;

  const FinancialProfile({
    required this.income,
    required this.monthlyBudget,
    this.incomeUpdatedAt,
  });

  FinancialProfile copyWith({
    double? income,
    double? monthlyBudget,
    DateTime? incomeUpdatedAt,
  }) {
    return FinancialProfile(
      income: income ?? this.income,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      incomeUpdatedAt: incomeUpdatedAt ?? this.incomeUpdatedAt,
    );
  }
}
