import '../../../../domain/entities/expense.dart';

class ExpenseInputParser {
  const ExpenseInputParser._();

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
      category: 'Other',
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
          category: 'Other',
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
