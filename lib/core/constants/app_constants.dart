class AppConstants {
  // App Info
  static const String appName = 'BetterSpent';
  static const String appVersion = '1.0.0';

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;

  // Border Radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 16.0;
  static const double radiusLg = 24.0;
  static const double radiusXl = 32.0;

  // Icon Sizes
  static const double iconSm = 16.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // Animation Durations
  static const Duration animationShort = Duration(milliseconds: 150);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationLong = Duration(milliseconds: 500);

  // Expense Categories
  static const List<String> expenseCategories = [
    'FOOD & DRINK',
    'TRANSPORT',
    'SHOPPING',
    'ENTERTAINMENT',
    'BILLS',
    'GROCERY',
    'HEALTH',
    'OTHER',
  ];

  // Default Values
  static const String defaultCurrency = 'USD';
  static const double defaultSpendingLimit = 100.0;
}
