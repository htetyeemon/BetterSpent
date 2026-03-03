import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_constants.dart';
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
  static const List<String> _apiVersions = ['v1', 'v1beta'];
  static const List<String> _fallbackModelCandidates = [
    'gemini-2.5-flash',
    'gemini-2.0-flash',
    'gemini-2.0-flash-lite',
    'gemini-2.0-pro',
    'gemini-1.5-flash-latest',
    'gemini-1.5-flash',
    'gemini-pro',
  ];

  static const List<String> _allowedCategories = AppConstants.expenseCategories;

  String get _apiKey {
    final key = dotenv.env['GEMINI_API_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in .env');
    }
    return key;
  }

  String get apiKey => _apiKey;

  Future<List<ParsedExpenseInput>> parseExpenseInputs(String input) async {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return const [];
    final now = DateTime.now();
    final todayIso = _toIsoDate(now);

    final prompt = '''
Extract all expenses from this user input: "$trimmed"
Today is $todayIso.

Return JSON only with this exact shape:
{"expenses":[{"amount": number, "category": string, "note": string, "date": "YYYY-MM-DD"}]}

Rules:
- amount must be a positive number.
- category must be one of: ${_allowedCategories.join(', ')}.
- note should be a short clean note, without currency symbols.
- Correct minor spelling mistakes in note text when obvious (example: "javket" -> "jacket").
- date must be inferred from the user's text and returned as YYYY-MM-DD.
- if user says "today", use $todayIso.
- if user says "yesterday", use one day before $todayIso.
- if no date clue is present, default to $todayIso.
- If uncertain, use category "Other".
- Include every expense mentioned by the user.
- Do not invent expenses that are not explicitly in the input.
- If the input is unclear, random text, or missing a real expense, return {"expenses":[]}.
- If no expense exists, return {"expenses":[]}.
''';
    Map<String, dynamic>? decoded;
    int? lastStatusCode;
    String? lastErrorMessage;

    for (final version in _apiVersions) {
      final modelCandidates = await _resolveModelCandidates(version);
      for (final model in modelCandidates) {
        final uri = Uri.parse(
          'https://generativelanguage.googleapis.com/$version/models/$model:generateContent?key=$_apiKey',
        );

        final response = await http
            .post(
              uri,
              headers: const {'Content-Type': 'application/json'},
              body: jsonEncode({
                'contents': [
                  {
                    'parts': [
                      {'text': prompt},
                    ],
                  },
                ],
                'generationConfig': {
                  'temperature': 0.1,
                  'responseMimeType': 'application/json',
                },
              }),
            )
            .timeout(const Duration(seconds: 15));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          decoded = jsonDecode(response.body) as Map<String, dynamic>;
          break;
        }

        lastStatusCode = response.statusCode;
        try {
          final err = jsonDecode(response.body) as Map<String, dynamic>;
          final errorMap = err['error'] as Map<String, dynamic>?;
          lastErrorMessage = errorMap?['message']?.toString();
        } catch (_) {
          lastErrorMessage = response.body;
        }
      }
      if (decoded != null) break;
    }

    if (decoded == null) {
      throw Exception(
        'Gemini request failed (${lastStatusCode ?? 'unknown'}): ${lastErrorMessage ?? 'No response body'}',
      );
    }

    final candidates = decoded['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) return const [];

    final candidate = candidates.first as Map<String, dynamic>;
    final content = candidate['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) return const [];

    final text = (parts.first as Map<String, dynamic>)['text'] as String?;
    if (text == null || text.trim().isEmpty) return const [];

    final normalized = _stripCodeFences(text.trim());
    final dynamic parsedDynamic = jsonDecode(normalized);

    final List<dynamic> rawExpenses;
    if (parsedDynamic is Map<String, dynamic> &&
        parsedDynamic['expenses'] is List<dynamic>) {
      rawExpenses = parsedDynamic['expenses'] as List<dynamic>;
    } else if (parsedDynamic is Map<String, dynamic>) {
      // Backward compatibility if model returns a single object.
      rawExpenses = [parsedDynamic];
    } else {
      return const [];
    }

    final parsedExpenses = <ParsedExpenseInput>[];
    for (final raw in rawExpenses) {
      if (raw is! Map<String, dynamic>) continue;

      final amountNum = raw['amount'] as num?;
      if (amountNum == null || amountNum <= 0) continue;

      final categoryRaw = (raw['category'] as String?)?.trim();
      final noteRaw = (raw['note'] as String?)?.trim();
      final dateRaw = (raw['date'] as String?)?.trim();
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

  String _stripCodeFences(String text) {
    if (!text.startsWith('```')) return text;
    final noStart = text.replaceFirst(RegExp(r'^```[a-zA-Z]*\n?'), '');
    return noStart.replaceFirst(RegExp(r'\n?```$'), '').trim();
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

  Future<List<String>> _resolveModelCandidates(String version) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/$version/models?key=$_apiKey',
    );

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return _fallbackModelCandidates;
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final models = decoded['models'] as List<dynamic>?;
      if (models == null || models.isEmpty) {
        return _fallbackModelCandidates;
      }

      final discovered = <String>[];
      for (final item in models) {
        if (item is! Map<String, dynamic>) continue;
        final name = item['name'] as String?;
        final methods = item['supportedGenerationMethods'] as List<dynamic>?;
        final supportsGenerateContent =
            methods != null && methods.contains('generateContent');
        if (!supportsGenerateContent || name == null) continue;

        final modelName = name.startsWith('models/')
            ? name.substring('models/'.length)
            : name;
        if (modelName.contains('embedding')) continue;
        if (!modelName.contains('gemini')) continue;

        discovered.add(modelName);
      }

      if (discovered.isEmpty) return _fallbackModelCandidates;
      discovered.sort((a, b) => _modelRank(a).compareTo(_modelRank(b)));
      return discovered;
    } catch (_) {
      return _fallbackModelCandidates;
    }
  }

  int _modelRank(String model) {
    final m = model.toLowerCase();
    if (m.contains('2.5') && m.contains('flash')) return 0;
    if (m.contains('2.0') && m.contains('flash')) return 1;
    if (m.contains('flash') && m.contains('lite')) return 2;
    if (m.contains('1.5') && m.contains('flash')) return 3;
    if (m.contains('pro')) return 4;
    if (m.contains('flash')) return 5;
    return 10;
  }
}
