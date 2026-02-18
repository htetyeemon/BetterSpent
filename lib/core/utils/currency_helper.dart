class CurrencyHelper {
  // Currency symbols map
  static const Map<String, String> currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'CAD': 'C\$',
    'AUD': 'A\$',
    'CHF': 'Fr',
    'CNY': '¥',
    'INR': '₹',
    'MXN': 'Mex\$',
    'THB': 'Baht\$',
  };

  // Currency names map
  static const Map<String, String> currencyNames = {
    'USD': 'US Dollar',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'JPY': 'Japanese Yen',
    'CAD': 'Canadian Dollar',
    'AUD': 'Australian Dollar',
    'CHF': 'Swiss Franc',
    'CNY': 'Chinese Yuan',
    'INR': 'Indian Rupee',
    'MXN': 'Mexican Peso',
    'THB': 'Thai Bath',
  };

  // Get currency symbol
  static String getSymbol(String currencyCode) {
    return currencySymbols[currencyCode.toUpperCase()] ?? '\$';
  }

  // Get currency name
  static String getName(String currencyCode) {
    return currencyNames[currencyCode.toUpperCase()] ?? 'Unknown';
  }

  // Format amount with currency
  static String formatAmount(double amount, String currencyCode) {
    final symbol = getSymbol(currencyCode);
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  // Format amount without currency (just number)
  static String formatNumber(double amount) {
    return amount.toStringAsFixed(2);
  }

  // Parse amount from string (remove currency symbols)
  static double? parseAmount(String amountStr) {
    // Remove common currency symbols and whitespace
    final cleaned = amountStr.replaceAll(RegExp(r'[^\d.]'), '').trim();
    return double.tryParse(cleaned);
  }

  // Check if amount string is valid
  static bool isValidAmount(String amountStr) {
    return parseAmount(amountStr) != null;
  }
}
