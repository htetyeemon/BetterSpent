class InsightPrediction {
  final bool willExceedBudget;
  final String message;

  const InsightPrediction({
    required this.willExceedBudget,
    required this.message,
  });
}

class GetInsightsPredictionUseCase {
  InsightPrediction execute(
    double averagePerDay,
    double maxSpendPerDay, {
    required bool isMonthlyPeriod,
  }) {
    if (maxSpendPerDay <= 0) {
      return InsightPrediction(
        willExceedBudget: true,
        message: isMonthlyPeriod
            ? 'You have no remaining daily budget. At this pace, this month is over budget.'
            : 'You have no remaining daily budget. At this pace, this week is over budget.',
      );
    }

    final projectedSpend = averagePerDay * (isMonthlyPeriod ? 30 : 7);
    final periodBudgetLimit = maxSpendPerDay * (isMonthlyPeriod ? 30 : 7);
    if (projectedSpend > periodBudgetLimit) {
      return InsightPrediction(
        willExceedBudget: true,
        message: isMonthlyPeriod
            ? 'Your average daily spending is above your daily limit. You are unlikely to maintain your budget this month.'
            : 'Your average daily spending is above your daily limit. You are unlikely to maintain your budget this week.',
      );
    }

    return InsightPrediction(
      willExceedBudget: false,
      message: isMonthlyPeriod
          ? 'Your average daily spending is within your daily limit. You are on track for this month.'
          : 'Your average daily spending is within your daily limit. You are on track for this week.',
    );
  }
}
