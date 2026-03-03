import '../../../../domain/entities/expense.dart';

class ExpenseInputValidator {
  static const double _maxReasonableAmount = 1000000;

  const ExpenseInputValidator._();

  static List<Expense> filterValidExpenses(
    List<Expense> expenses,
    String rawInput, {
    bool requireInputOverlap = true,
  }
  ) {
    return expenses.where((expense) {
      if (!_isValidAmount(expense.amount)) return false;
      if (!_isMeaningfulNote(expense.note)) return false;
      if (requireInputOverlap &&
          !_hasNoteOverlapWithInput(expense.note, rawInput)) {
        return false;
      }
      return true;
    }).toList();
  }

  static String? firstValidationError(
    List<Expense> expenses,
    String rawInput, {
    bool requireInputOverlap = true,
  }) {
    if (expenses.isEmpty) {
      return 'No expense was detected from your text.';
    }

    for (final expense in expenses) {
      if (!_isValidAmount(expense.amount)) {
        return 'Amount looks invalid or too large.';
      }
      if (!_isMeaningfulNote(expense.note)) {
        return 'Description looks unclear. Try a clearer item name.';
      }
      if (requireInputOverlap &&
          !_hasNoteOverlapWithInput(expense.note, rawInput)) {
        return 'Parsed description does not match your input closely enough.';
      }
    }

    return null;
  }

  static bool _isValidAmount(double amount) {
    return amount > 0 && amount <= _maxReasonableAmount;
  }

  static bool _isMeaningfulNote(String note) {
    final cleaned = note.toLowerCase().replaceAll(RegExp(r'[^a-z\s]'), ' ').trim();
    if (cleaned.isEmpty) return false;

    final words = cleaned.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return false;

    final lettersOnly = cleaned.replaceAll(' ', '');
    if (lettersOnly.length > 20 && words.length == 1) return false;
    if (!RegExp(r'[aeiou]').hasMatch(lettersOnly) && lettersOnly.length >= 6) {
      return false;
    }
    if (lettersOnly == 'quickadd') return false;

    return true;
  }

  static bool _hasNoteOverlapWithInput(String note, String rawInput) {
    final inputWords = rawInput
        .toLowerCase()
        .split(RegExp(r'[^a-z]+'))
        .where((w) => w.length >= 3)
        .toList();
    if (inputWords.isEmpty) return false;

    const ignored = {
      'today',
      'yesterday',
      'dollar',
      'dollars',
      'baht',
      'spent',
      'cost',
      'price',
      'bought',
      'have',
      'had',
      'was',
      'and',
      'for',
      'the',
    };

    final noteWords = note
        .toLowerCase()
        .split(RegExp(r'[^a-z]+'))
        .where((w) => w.length >= 3 && !ignored.contains(w));

    for (final word in noteWords) {
      for (final inputWord in inputWords) {
        if (inputWord == word) return true;
        if (_isLikelyMinorTypo(word, inputWord)) return true;
      }
    }
    return false;
  }

  static bool _isLikelyMinorTypo(String a, String b) {
    final lenDiff = (a.length - b.length).abs();
    if (lenDiff > 1) return false;
    if (a.length < 4 || b.length < 4) return false;

    final dist = _levenshteinDistance(a, b);
    return dist <= 1;
  }

  static int _levenshteinDistance(String s, String t) {
    final rows = s.length + 1;
    final cols = t.length + 1;
    final matrix = List.generate(rows, (_) => List<int>.filled(cols, 0));

    for (var i = 0; i < rows; i++) {
      matrix[i][0] = i;
    }
    for (var j = 0; j < cols; j++) {
      matrix[0][j] = j;
    }

    for (var i = 1; i < rows; i++) {
      for (var j = 1; j < cols; j++) {
        final cost = s[i - 1] == t[j - 1] ? 0 : 1;
        final deletion = matrix[i - 1][j] + 1;
        final insertion = matrix[i][j - 1] + 1;
        final substitution = matrix[i - 1][j - 1] + cost;
        matrix[i][j] = [deletion, insertion, substitution].reduce(
          (a, b) => a < b ? a : b,
        );
      }
    }

    return matrix[rows - 1][cols - 1];
  }
}
