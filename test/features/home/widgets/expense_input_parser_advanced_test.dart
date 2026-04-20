import 'package:flutter_test/flutter_test.dart';
import 'package:better_spent/features/home/presentation/widgets/expense_input_parser.dart';

void main() {
  group('ExpenseInputParser - Unicode & Date Inference', () {
    group('Unicode and special characters in notes', () {
      test('should parse note with emoji', () {
        final result = ExpenseInputParser.parseSingle('coffee ☕ 5.50');
        expect(result, isNotNull);
        if (result != null) {
          expect(result.note, contains('☕'));
        }
      });

      test('should parse note with Chinese characters', () {
        final result = ExpenseInputParser.parseSingle('餐点 50');
        expect(result, isNotNull);
        if (result != null) {
          expect(result.amount, 50);
          expect(result.note.contains('餐'), true);
        }
      });

      test('should parse note with Arabic text', () {
        final result = ExpenseInputParser.parseSingle('الغذاء 100');
        expect(result, isNotNull);
        if (result != null) {
          expect(result.amount, 100);
        }
      });

      test('should parse note with special punctuation', () {
        final result = ExpenseInputParser.parseSingle('coffee & snacks 25.50');
        expect(result, isNotNull);
        if (result != null) {
          expect(result.note, isNotEmpty);
        }
      });

      test('should parse note with accented characters', () {
        final result = ExpenseInputParser.parseSingle('café 10');
        expect(result, isNotNull);
        if (result != null) {
          expect(result.amount, 10);
        }
      });

      test('should handle note with multiple special symbols', () {
        final result = ExpenseInputParser.parseSingle('!!!coffee!!! 5');
        expect(result, isNotNull);
      });

      test('should handle note with only special characters', () {
        final result = ExpenseInputParser.parseSingle('!@#\$%^&*() 50');
        expect(result, isNotNull);
      });

      test('should parse note with Cyrillic characters', () {
        final result = ExpenseInputParser.parseSingle('кофе 15');
        expect(result, isNotNull);
        if (result != null) {
          expect(result.amount, 15);
        }
      });
    });

    group('Date inference edge cases', () {
      test('should infer "yesterday" correctly', () {
        final result = ExpenseInputParser.parseSingle('lunch yesterday 50');
        expect(result, isNotNull);
        if (result != null) {
          final yesterday = DateTime.now().subtract(const Duration(days: 1));
          expect(result.date.year, yesterday.year);
          expect(result.date.month, yesterday.month);
          expect(result.date.day, yesterday.day);
        }
      });

      test('should default to today for unrecognized date', () {
        final result = ExpenseInputParser.parseSingle('coffee 50');
        expect(result, isNotNull);
        if (result != null) {
          final today = DateTime.now();
          expect(result.date.year, today.year);
          expect(result.date.month, today.month);
          expect(result.date.day, today.day);
        }
      });

      test('should handle "yesterday" case-insensitive (UPPERCASE)', () {
        final result = ExpenseInputParser.parseSingle('lunch YESTERDAY 50');
        expect(result, isNotNull);
      });

      test('should handle "Yesterday" with capital Y', () {
        final result = ExpenseInputParser.parseSingle('lunch Yesterday 50');
        expect(result, isNotNull);
      });

      test('should not confuse "yesteryear" with "yesterday"', () {
        final result = ExpenseInputParser.parseSingle('yesteryear trend 50');
        expect(result, isNotNull);
        if (result != null) {
          final today = DateTime.now();
          // Should be today, not yesterday
          expect(result.date.day, today.day);
        }
      });
    });

    group('Multiple expenses with special handling', () {
      test('should handle zero amounts in multiple parsing', () {
        final result = ExpenseInputParser.parseMultiple('coffee 0, tea 50');
        // Zero should be filtered out
        expect(result.every((e) => e.amount > 0), true);
      });

      test('should handle negative amounts in multiple parsing', () {
        final result = ExpenseInputParser.parseMultiple('coffee -10, tea 50');
        // Negative should be filtered out (minus ignored by regex anyway)
        expect(result, isNotEmpty);
      });
    });

    group('Extremely long inputs', () {
      test('should handle very long note text', () {
        final longText = 'coffee ' * 100 + '50';
        final result = ExpenseInputParser.parseSingle(longText);
        expect(result, isNotNull);
      });

      test('should handle very long description in multiple', () {
        final longText = '${'a' * 500} 50';
        final result = ExpenseInputParser.parseMultiple(longText);
        expect(result, isNotEmpty);
      });
    });

    group('Complex real-world scenarios', () {
      test('should parse note with time-like text', () {
        final result = ExpenseInputParser.parseSingle('coffee at 10:30am 5.50');
        expect(result, isNotNull);
      });

      test('should parse note with location', () {
        final result = ExpenseInputParser.parseSingle(
          'coffee at Starbucks downtown 6.75',
        );
        expect(result, isNotNull);
      });

      test('should parse note with quantity mention', () {
        final result = ExpenseInputParser.parseSingle('2 coffees for team 15');
        expect(result, isNotNull);
      });

      test('should handle mixed Unicode and ASCII', () {
        final result = ExpenseInputParser.parseSingle('☕ café test 10');
        expect(result, isNotNull);
      });

      test('should parse with multiple decimal-like numbers', () {
        final result = ExpenseInputParser.parseSingle('v2.0 price 10.5');
        expect(result, isNotNull);
      });
    });

    group('Fallback behavior', () {
      test('parseMultiple falls back to parseSingle behavior', () {
        final result = ExpenseInputParser.parseMultiple('some random text');
        expect(result, isEmpty);
      });

      test('parseMultiple successfully returns list with single item', () {
        final result = ExpenseInputParser.parseMultiple('coffee 50');
        expect(result, isNotEmpty);
        expect(result.length, greaterThanOrEqualTo(1));
      });

      test('should maintain category defaulting in parsed results', () {
        final result = ExpenseInputParser.parseSingle('coffee 50');
        expect(result, isNotNull);
        if (result != null) {
          // Category should be defaulted by parser
          expect(result.category, isNotNull);
        }
      });
    });
  });
}
