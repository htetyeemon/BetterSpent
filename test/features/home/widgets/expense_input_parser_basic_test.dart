import 'package:flutter_test/flutter_test.dart';
import 'package:better_spent/features/home/presentation/widgets/expense_input_parser.dart';

void main() {
  group('ExpenseInputParser - Basic Parsing', () {
    group('Null and empty inputs', () {
      test('should return null for empty string', () {
        final result = ExpenseInputParser.parseSingle('');
        expect(result, isNull);
      });

      test('should return empty list for empty string in parseMultiple', () {
        final result = ExpenseInputParser.parseMultiple('');
        expect(result, isEmpty);
      });

      test('should return null for whitespace only', () {
        final result = ExpenseInputParser.parseSingle('   ');
        expect(result, isNull);
      });

      test('should return null for just text without number', () {
        final result = ExpenseInputParser.parseSingle('coffee');
        expect(result, isNull);
      });

      test('should parse just a number (uses Quick add as default)', () {
        final result = ExpenseInputParser.parseSingle('100');
        expect(result, isNotNull);
        if (result != null) {
          expect(result.amount, 100);
          expect(result.note, 'Quick add');
        }
      });
    });

    group('Malformed amounts', () {
      test('should return null for zero amount', () {
        final result = ExpenseInputParser.parseSingle('coffee 0');
        expect(result, isNull);
      });

      test('should parse negative amounts (minus sign ignored by regex)', () {
        final result = ExpenseInputParser.parseSingle('coffee -50');
        expect(result, isNotNull);
        if (result != null) {
          expect(result.amount, 50);
        }
      });

      test('should parse three decimal place amount', () {
        final result = ExpenseInputParser.parseSingle('coffee 5.505');
        expect(result, isNotNull);
      });

      test('should parse very large amounts', () {
        final result = ExpenseInputParser.parseSingle('expensive 999999999.99');
        expect(result, isNotNull);
        if (result != null) {
          expect(result.amount, 999999999.99);
        }
      });

      test('should return null for non-numeric amounts', () {
        final result = ExpenseInputParser.parseSingle('coffee 50abc');
        expect(result, isNull);
      });

      test('should parse amount with currency symbol', () {
        final result = ExpenseInputParser.parseSingle('lunch \$50');
        expect(result, isNotNull);
      });

      test('should return null for comma-separated amounts', () {
        final result = ExpenseInputParser.parseSingle('expensive 1,000');
        expect(result, isNull); // Comma breaks the number
      });
    });

    group('Decimal precision', () {
      test('should handle one decimal place', () {
        final result = ExpenseInputParser.parseSingle('coffee 5.5');
        expect(result, isNotNull);
        if (result != null) {
          expect(result.amount, 5.5);
        }
      });

      test('should handle two decimal places', () {
        final result = ExpenseInputParser.parseSingle('coffee 5.50');
        expect(result, isNotNull);
        if (result != null) {
          expect(result.amount, 5.5);
        }
      });

      test('should handle very small positive amount', () {
        final result = ExpenseInputParser.parseSingle('item 0.01');
        expect(result, isNotNull);
        if (result != null) {
          expect(result.amount, 0.01);
        }
      });
    });

    group('Multiple expenses basic parsing', () {
      test('should handle input with no amounts', () {
        final result = ExpenseInputParser.parseMultiple('coffee tea snacks');
        expect(result, isEmpty);
      });

      test('should handle input with only numbers', () {
        final result = ExpenseInputParser.parseMultiple('100 200 300');
        expect(result, isNotEmpty);
      });

      test('should parse multiple expenses separated by commas', () {
        final result = ExpenseInputParser.parseMultiple(
          'coffee 5, tea 3, snack 2',
        );
        expect(result.isNotEmpty, true);
      });

      test('should parse multiple expenses separated by periods', () {
        final result = ExpenseInputParser.parseMultiple(
          'coffee 5. tea 3. snack 2',
        );
        expect(result, isNotEmpty);
      });

      test('should parse multiple expenses separated by semicolons', () {
        final result = ExpenseInputParser.parseMultiple(
          'coffee 5; tea 3; snack 2',
        );
        expect(result, isNotEmpty);
      });

      test('should parse multiple with exclamation marks', () {
        final result = ExpenseInputParser.parseMultiple(
          'coffee 5! tea 3! snack 2',
        );
        expect(result, isNotEmpty);
      });

      test('should parse multiple with question marks', () {
        final result = ExpenseInputParser.parseMultiple(
          'coffee 5? tea 3? snack 2',
        );
        expect(result, isNotEmpty);
      });
    });
  });
}
