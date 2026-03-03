class InsightPrediction {
  final bool willExceedBudget;
  final String message;

  const InsightPrediction({
    required this.willExceedBudget,
    required this.message,
  });
}

class GetInsightsPredictionUseCase {
  InsightPrediction execute(double averagePerDay, double maxSpendPerDay) {
    if (maxSpendPerDay <= 0) {
      return const InsightPrediction(
        willExceedBudget: true,
        message: 'You have already exceeded your monthly budget.',
      );
    }

    if (averagePerDay > maxSpendPerDay) {
      return const InsightPrediction(
        willExceedBudget: true,
        message:
            'At your current pace, you are likely to exceed your monthly budget.',
      );
    }

    return const InsightPrediction(
      willExceedBudget: false,
      message: 'You are on track with your spending goals. Keep it up!',
    );
  }
}
