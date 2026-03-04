import 'package:cloud_functions/cloud_functions.dart';
import '../../core/utils/category_helper.dart';

class ParsedExpenseInput {
  final double amount;
  final String category;
  final String note;
  final DateTime date;

  const ParsedExpenseInput({
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
  });
}

class GeminiService {
  GeminiService({FirebaseFunctions? functions})
      : _functions =
            functions ?? FirebaseFunctions.instanceFor(region: 'us-central1');

  final FirebaseFunctions _functions;

  Future<List<ParsedExpenseInput>> parseExpenseInputs(String input) async {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return const [];

    final now = DateTime.now();
    final callable = _functions.httpsCallable('parseExpense');
    final localDate = _toIsoDate(now);

    Map<String, dynamic> payload;
    try {
      final result = await callable.call({
        'input': trimmed,
        'clientLocalDate': localDate,
      });
      final data = result.data;
      if (data is Map) {
        payload = Map<String, dynamic>.from(data);
      } else {
        return const [];
      }
    } on FirebaseFunctionsException catch (e) {
      throw Exception('AI parser function failed (${e.code}): ${e.message}');
    }

    final rawExpenses = payload['expenses'];
    if (rawExpenses is! List<dynamic>) return const [];

    final parsedExpenses = <ParsedExpenseInput>[];
    for (final raw in rawExpenses) {
      if (raw is! Map) continue;

      final map = Map<String, dynamic>.from(raw);
      final amountNum = map['amount'] as num?;
      if (amountNum == null || amountNum <= 0) continue;

      final categoryRaw = (map['category'] as String?)?.trim();
      final noteRaw = (map['note'] as String?)?.trim();
      final dateRaw = (map['date'] as String?)?.trim();
      final category = CategoryHelper.normalizeLabel(categoryRaw ?? '');
      final date = _parseIsoDateOrNow(dateRaw) ?? now;

      parsedExpenses.add(
        ParsedExpenseInput(
          amount: amountNum.toDouble(),
          category: category,
          note: (noteRaw == null || noteRaw.isEmpty) ? trimmed : noteRaw,
          date: date,
        ),
      );
    }

    return parsedExpenses;
  }

  Future<ParsedExpenseInput?> parseExpenseInput(String input) async {
    final all = await parseExpenseInputs(input);
    if (all.isEmpty) return null;
    return all.first;
  }

  DateTime? _parseIsoDateOrNow(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      final parsed = DateTime.parse(value);
      return DateTime(parsed.year, parsed.month, parsed.day);
    } catch (_) {
      return null;
    }
  }

  String _toIsoDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
