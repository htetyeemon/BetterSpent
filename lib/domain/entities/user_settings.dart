class UserSettings {
  final String currency;
  final bool aiInputEnabled;
  final bool budgetWarningEnabled;
  final bool motivationalMessageEnabled;

  const UserSettings({
    this.currency = 'USD',
    this.aiInputEnabled = true,
    this.budgetWarningEnabled = true,
    this.motivationalMessageEnabled = false,
  });

  UserSettings copyWith({
    String? currency,
    bool? aiInputEnabled,
    bool? budgetWarningEnabled,
    bool? motivationalMessageEnabled,
  }) {
    return UserSettings(
      currency: currency ?? this.currency,
      aiInputEnabled: aiInputEnabled ?? this.aiInputEnabled,
      budgetWarningEnabled: budgetWarningEnabled ?? this.budgetWarningEnabled,
      motivationalMessageEnabled:
          motivationalMessageEnabled ?? this.motivationalMessageEnabled,
    );
  }
}
