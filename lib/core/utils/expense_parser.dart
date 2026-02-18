class ExpenseParser {
  // Parse natural language expense input
  // Examples:
  // "Coffee $5" -> {name: "Coffee", amount: 5.0}
  // "Lunch at Subway 12.50" -> {name: "Lunch at Subway", amount: 12.50}
  // "Uber to work $15" -> {name: "Uber to work", amount: 15.0}

  static Map<String, dynamic>? parseExpense(String input) {
    if (input.trim().isEmpty) return null;

    // Try to find amount with currency symbol
    final currencyPattern = RegExp(r'\$\s*(\d+\.?\d*)');
    final currencyMatch = currencyPattern.firstMatch(input);

    // Try to find amount without currency symbol
    final numberPattern = RegExp(r'\b(\d+\.?\d*)\b');

    double? amount;
    String? amountStr;

    if (currencyMatch != null) {
      amount = double.tryParse(currencyMatch.group(1)!);
      amountStr = currencyMatch.group(0);
    } else {
      // Find the last number in the string (likely the amount)
      final matches = numberPattern.allMatches(input).toList();
      if (matches.isNotEmpty) {
        final lastMatch = matches.last;
        amount = double.tryParse(lastMatch.group(1)!);
        amountStr = lastMatch.group(0);
      }
    }

    if (amount == null || amountStr == null) return null;

    // Extract name by removing the amount
    String name = input.replaceFirst(amountStr, '').trim();

    // Clean up the name
    name = name
        .replaceAll(RegExp(r'\s+'), ' ') // Multiple spaces to single
        .replaceAll(RegExp(r'^\W+|\W+$'), '') // Leading/trailing special chars
        .trim();

    if (name.isEmpty) {
      name = 'Expense';
    }

    // Try to guess category based on keywords
    final category = _guessCategory(name.toLowerCase());

    return {'name': name, 'amount': amount, 'category': category};
  }

  // Guess category from expense name
  static String _guessCategory(String name) {
    // Food & Drink keywords
    if (RegExp(
      r'\b(coffee|lunch|dinner|breakfast|food|restaurant|cafe|pizza|burger|subway|starbucks|mcdonald)\b',
    ).hasMatch(name)) {
      return 'FOOD & DRINK';
    }

    // Transport keywords
    if (RegExp(
      r'\b(uber|lyft|taxi|bus|train|gas|fuel|parking|metro|transport)\b',
    ).hasMatch(name)) {
      return 'TRANSPORT';
    }

    // Shopping keywords
    if (RegExp(
      r'\b(shop|shopping|store|amazon|clothing|clothes|shoes|mall)\b',
    ).hasMatch(name)) {
      return 'SHOPPING';
    }

    // Entertainment keywords
    if (RegExp(
      r'\b(movie|cinema|theater|game|gaming|netflix|spotify|concert|show)\b',
    ).hasMatch(name)) {
      return 'ENTERTAINMENT';
    }

    // Bills keywords
    if (RegExp(
      r'\b(bill|electricity|water|internet|phone|rent|utility)\b',
    ).hasMatch(name)) {
      return 'BILLS';
    }

    // Grocery keywords
    if (RegExp(
      r'\b(grocery|groceries|supermarket|walmart|target|market)\b',
    ).hasMatch(name)) {
      return 'GROCERY';
    }

    // Health keywords
    if (RegExp(
      r'\b(doctor|hospital|pharmacy|medicine|health|gym|fitness)\b',
    ).hasMatch(name)) {
      return 'HEALTH';
    }

    // Default to OTHER
    return 'OTHER';
  }

  // Validate if input is parseable
  static bool isValidInput(String input) {
    return parseExpense(input) != null;
  }
}
