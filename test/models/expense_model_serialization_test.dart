import 'package:flutter_test/flutter_test.dart';
import 'package:better_spent/models/expense_model.dart';

void main() {
  group('ExpenseModel - Basic Serialization', () {
    group('JSON missing required fields', () {
      test('should throw on missing id', () {
        final json = {
          'name': 'Coffee',
          'category': 'Food & Drink',
          'amount': 5.5,
          'date': '2023-06-15T10:00:00.000Z',
        };
        expect(() => ExpenseModel.fromJson(json), throwsA(isA<TypeError>()));
      });

      test('should throw on missing name', () {
        final json = {
          'id': '1',
          'category': 'Food & Drink',
          'amount': 5.5,
          'date': '2023-06-15T10:00:00.000Z',
        };
        expect(() => ExpenseModel.fromJson(json), throwsA(isA<TypeError>()));
      });

      test('should throw on missing category', () {
        final json = {
          'id': '1',
          'name': 'Coffee',
          'amount': 5.5,
          'date': '2023-06-15T10:00:00.000Z',
        };
        expect(() => ExpenseModel.fromJson(json), throwsA(isA<TypeError>()));
      });

      test('should throw on missing amount', () {
        final json = {
          'id': '1',
          'name': 'Coffee',
          'category': 'Food & Drink',
          'date': '2023-06-15T10:00:00.000Z',
        };
        expect(() => ExpenseModel.fromJson(json), throwsA(isA<TypeError>()));
      });

      test('should throw on missing date', () {
        final json = {
          'id': '1',
          'name': 'Coffee',
          'category': 'Food & Drink',
          'amount': 5.5,
        };
        expect(() => ExpenseModel.fromJson(json), throwsA(isA<TypeError>()));
      });

      test('should handle missing optional note', () {
        final json = {
          'id': '1',
          'name': 'Coffee',
          'category': 'Food & Drink',
          'amount': 5.5,
          'date': '2023-06-15T10:00:00.000Z',
        };
        final expense = ExpenseModel.fromJson(json);
        expect(expense.note, isNull);
      });

      test('should handle null note field', () {
        final json = {
          'id': '1',
          'name': 'Coffee',
          'category': 'Food & Drink',
          'amount': 5.5,
          'date': '2023-06-15T10:00:00.000Z',
          'note': null,
        };
        final expense = ExpenseModel.fromJson(json);
        expect(expense.note, isNull);
      });
    });

    group('Invalid date formats', () {
      test('should throw on invalid ISO date string', () {
        final json = {
          'id': '1',
          'name': 'Coffee',
          'category': 'Food & Drink',
          'amount': 5.5,
          'date': 'not-a-date',
        };
        expect(
          () => ExpenseModel.fromJson(json),
          throwsA(isA<FormatException>()),
        );
      });

      test(
        'should parse extremely malformed date (DateTime.parse is lenient)',
        () {
          final json = {
            'id': '1',
            'name': 'Coffee',
            'category': 'Food & Drink',
            'amount': 5.5,
            'date': '2023-13-45T25:99:99.000Z', // Invalid month, day, time
          };
          // Dart's DateTime.parse accepts this despite invalid values
          final expense = ExpenseModel.fromJson(json);
          expect(expense, isNotNull);
        },
      );

      test('should throw on numeric date (type mismatch)', () {
        final json = {
          'id': '1',
          'name': 'Coffee',
          'category': 'Food & Drink',
          'amount': 5.5,
          'date': 1234567890,
        };
        expect(() => ExpenseModel.fromJson(json), throwsA(isA<TypeError>()));
      });

      test('should throw on empty date string', () {
        final json = {
          'id': '1',
          'name': 'Coffee',
          'category': 'Food & Drink',
          'amount': 5.5,
          'date': '',
        };
        expect(
          () => ExpenseModel.fromJson(json),
          throwsA(isA<FormatException>()),
        );
      });
    });

    group('Amount field variations', () {
      test('should handle integer amount', () {
        final json = {
          'id': '1',
          'name': 'Coffee',
          'category': 'Food & Drink',
          'amount': 5,
          'date': '2023-06-15T10:00:00.000Z',
        };
        final expense = ExpenseModel.fromJson(json);
        expect(expense.amount, 5.0);
      });

      test('should handle zero amount', () {
        final json = {
          'id': '1',
          'name': 'Coffee',
          'category': 'Food & Drink',
          'amount': 0,
          'date': '2023-06-15T10:00:00.000Z',
        };
        final expense = ExpenseModel.fromJson(json);
        expect(expense.amount, 0.0);
      });

      test('should handle negative amount', () {
        final json = {
          'id': '1',
          'name': 'Refund',
          'category': 'Food & Drink',
          'amount': -50,
          'date': '2023-06-15T10:00:00.000Z',
        };
        final expense = ExpenseModel.fromJson(json);
        expect(expense.amount, -50.0);
      });

      test('should handle very large amount', () {
        final json = {
          'id': '1',
          'name': 'Large purchase',
          'category': 'Shopping',
          'amount': 999999999.99,
          'date': '2023-06-15T10:00:00.000Z',
        };
        final expense = ExpenseModel.fromJson(json);
        expect(expense.amount, 999999999.99);
      });

      test('should throw on string amount', () {
        final json = {
          'id': '1',
          'name': 'Coffee',
          'category': 'Food & Drink',
          'amount': 'fifty',
          'date': '2023-06-15T10:00:00.000Z',
        };
        expect(() => ExpenseModel.fromJson(json), throwsA(isA<TypeError>()));
      });

      test('should throw on null amount', () {
        final json = {
          'id': '1',
          'name': 'Coffee',
          'category': 'Food & Drink',
          'amount': null,
          'date': '2023-06-15T10:00:00.000Z',
        };
        expect(() => ExpenseModel.fromJson(json), throwsA(isA<TypeError>()));
      });
    });

    group('Date boundary cases', () {
      test('should handle year 2000', () {
        final json = {
          'id': '1',
          'name': 'Coffee',
          'category': 'Food & Drink',
          'amount': 5.5,
          'date': '2000-01-01T00:00:00.000Z',
        };
        final expense = ExpenseModel.fromJson(json);
        expect(expense.date.year, 2000);
      });

      test('should handle far future date', () {
        final json = {
          'id': '1',
          'name': 'Coffee',
          'category': 'Food & Drink',
          'amount': 5.5,
          'date': '2100-12-31T23:59:59.999Z',
        };
        final expense = ExpenseModel.fromJson(json);
        expect(expense.date.year, 2100);
      });
    });
  });
}
