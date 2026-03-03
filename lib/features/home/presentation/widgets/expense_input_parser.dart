import '../../../../domain/entities/expense.dart';

class ExpenseInputParser {
  const ExpenseInputParser._();

  static String _inferCategory(String text) {
    final lower = text.toLowerCase();
    if (RegExp(
      r'\b(coffee|lunch|dinner|breakfast|food|restaurant|pizza|burger|drink|tea|snack)\b',
    ).hasMatch(lower)) return 'Food & Drink';
    if (RegExp(
      r'\b(grocery|groceries|supermarket|walmart)\b',
    ).hasMatch(lower)) return 'Grocery';
    if (RegExp(
      r'\b(uber|taxi|bus|gas|fuel|train|parking|metro)\b',
    ).hasMatch(lower)) return 'Transport';
    if (RegExp(
      r'\b(movie|netflix|game|concert|spotify)\b',
    ).hasMatch(lower)) return 'Entertainment';
    if (RegExp(
      r'\b(clothes|shoes|amazon|tv|phone|laptop|electronics)\b',
    ).hasMatch(lower)) return 'Shopping';
    if (RegExp(
      r'\b(rent|electric|water|internet|phone bill|insurance)\b',
    ).hasMatch(lower)) return 'Bills';
    if (RegExp(
      r'\b(medicine|doctor|hospital|pharmacy|gym)\b',
    ).hasMatch(lower)) return 'Health';
    return 'Other';
  }

  static Expense? parseSingle(String input) {
    final match = RegExp(r'^(.*?)(\d+(?:\.\d{1,2})?)$').firstMatch(input);
    if (match == null) return null;

    final note = match.group(1)?.trim() ?? '';
    final amountString = match.group(2);
    if (amountString == null) return null;

    final amount = double.tryParse(amountString);
    if (amount == null || amount <= 0) return null;

    return Expense(
      id: '',
      amount: amount,
      category: _inferCategory(note.isEmpty ? input : note),
      date: inferDateFromText(note),
      note: note.isEmpty ? 'Quick add' : note,
    );
  }

  static List<Expense> parseMultiple(String input) {
    final matches =
        RegExp(r'([^.,;!?]*?)\b(\d+(?:\.\d{1,2})?)\b', caseSensitive: false)
            .allMatches(input);

    final expenses = <Expense>[];
    for (final match in matches) {
      final noteRaw = (match.group(1) ?? '').trim();
      final amountRaw = match.group(2);
      if (amountRaw == null) continue;

      final amount = double.tryParse(amountRaw);
      if (amount == null || amount <= 0) continue;

      final note = noteRaw
          .replaceAll(
            RegExp(r'\b(i|had|it|cost|was|and)\b', caseSensitive: false),
            '',
          )
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();

      expenses.add(
        Expense(
          id: '',
          amount: amount,
          // Use noteRaw (before cleanup) for better keyword matching
          category: _inferCategory(noteRaw.isEmpty ? note : noteRaw),
          date: inferDateFromText(noteRaw),
          note: note.isEmpty ? 'Quick add' : note,
        ),
      );
    }

    if (expenses.isNotEmpty) return expenses;
    final single = parseSingle(input);
    if (single == null) return const [];
    return [single];
  }

  static DateTime inferDateFromText(String text) {
    final now = DateTime.now();
    final lowered = text.toLowerCase();
    if (lowered.contains('yesterday')) {
      final d = now.subtract(const Duration(days: 1));
      return DateTime(d.year, d.month, d.day);
    }
    return DateTime(now.year, now.month, now.day);
  }
}
