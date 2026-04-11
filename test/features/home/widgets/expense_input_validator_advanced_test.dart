import 'package:flutter_test/flutter_test.dart';
import 'package:better_spent/features/home/presentation/widgets/expense_input_validator.dart';
import '../../../helpers/expense_test_helper.dart';

void main() {
  group('ExpenseInputValidator - Input Overlap & Advanced', () {
    group('Input overlap checking', () {
      test('should reject note with no overlap in input', () {
        final expense = ExpenseTestHelper.createExpenseWithNote('coffee');
        final error = ExpenseInputValidator.firstValidationError(
          [expense],
          'something completely different',
          requireInputOverlap: true,
        );
        expect(error, isNotNull);
      });

      test('should accept when overlap not required', () {
        final expense = ExpenseTestHelper.createExpenseWithNote('coffee');
        final filtered = ExpenseInputValidator.filterValidExpenses(
          [expense],
          'unrelated text',
          requireInputOverlap: false,
        );
        expect(filtered.length, 1);
      });

      test('should accept partial overlap with input', () {
        final expense = ExpenseTestHelper.createExpenseWithNote('coffee');
        final filtered = ExpenseInputValidator.filterValidExpenses(
          [expense],
          'coffee shop',
          requireInputOverlap: true,
        );
        expect(filtered.length, 1);
      });

      test('should ignore short words in overlap check', () {
        final expense = ExpenseTestHelper.createExpenseWithNote('pizza');
        final filtered = ExpenseInputValidator.filterValidExpenses(
          [expense],
          'pi', // Too short
          requireInputOverlap: true,
        );
        expect(filtered, isEmpty);
      });

      test('should match with Levenshtein distance 1 (typo tolerance)', () {
        final expense = ExpenseTestHelper.createExpenseWithNote('coffee');
        final filtered = ExpenseInputValidator.filterValidExpenses(
          [expense],
          'coffe', // Missing one letter
          requireInputOverlap: true,
        );
        expect(filtered, isNotEmpty);
      });
    });

    group('Ignored words in overlap', () {
      test('should ignore "today" when matching', () {
        final expense = ExpenseTestHelper.createExpenseWithNote('lunch');
        final filtered = ExpenseInputValidator.filterValidExpenses(
          [expense],
          'lunch today',
          requireInputOverlap: true,
        );
        expect(filtered.length, 1);
      });

      test('should ignore "yesterday" when matching', () {
        final expense = ExpenseTestHelper.createExpenseWithNote('dinner');
        final filtered = ExpenseInputValidator.filterValidExpenses(
          [expense],
          'dinner yesterday',
          requireInputOverlap: true,
        );
        expect(filtered.length, 1);
      });

      test('should ignore currency words', () {
        final expense = ExpenseTestHelper.createExpenseWithNote('pizza');
        final filtered = ExpenseInputValidator.filterValidExpenses(
          [expense],
          'pizza dollar',
          requireInputOverlap: true,
        );
        expect(filtered.length, 1);
      });

      test('should ignore common English words', () {
        final expense = ExpenseTestHelper.createExpenseWithNote('coffee');
        final filtered = ExpenseInputValidator.filterValidExpenses(
          [expense],
          'coffee and water',
          requireInputOverlap: true,
        );
        expect(filtered.length, 1);
      });

      test('should ignore "spent", "cost", "bought"', () {
        final expense = ExpenseTestHelper.createExpenseWithNote('lunch');
        final testInputs = ['lunch spent', 'lunch cost', 'lunch bought'];

        for (final input in testInputs) {
          final filtered = ExpenseInputValidator.filterValidExpenses(
            [expense],
            input,
            requireInputOverlap: true,
          );
          expect(filtered.length, 1, reason: 'Should match with input: $input');
        }
      });
    });

    group('Unicode in descriptions', () {
      test('should handle emoji in note', () {
        final expense = ExpenseTestHelper.createExpenseWithNote('coffee ☕');
        final filtered = ExpenseInputValidator.filterValidExpenses([
          expense,
        ], 'coffee');
        expect(filtered, isNotEmpty);
      });

      test('should handle Chinese characters with English vowels', () {
        final expense = ExpenseTestHelper.createExpenseWithNote('咖啡test');
        final filtered = ExpenseInputValidator.filterValidExpenses(
          [expense],
          '咖啡',
          requireInputOverlap: false,
        );
        expect(filtered, isNotEmpty);
      });

      test('should handle accented characters', () {
        final expense = ExpenseTestHelper.createExpenseWithNote('café');
        final filtered = ExpenseInputValidator.filterValidExpenses(
          [expense],
          'cafe',
          requireInputOverlap: false,
        );
        expect(filtered, isNotEmpty);
      });

      test('should handle Arabic text with English vowels', () {
        final expense = ExpenseTestHelper.createExpenseWithNote('طعام food');
        final filtered = ExpenseInputValidator.filterValidExpenses(
          [expense],
          'food',
          requireInputOverlap: false,
        );
        expect(filtered, isNotEmpty);
      });

      test('should handle mixed scripts', () {
        final expense = ExpenseTestHelper.createExpenseWithNote('café ☕ test');
        final filtered = ExpenseInputValidator.filterValidExpenses(
          [expense],
          'cafe',
          requireInputOverlap: false,
        );
        expect(filtered, isNotEmpty);
      });
    });

    group('Complex edge cases', () {
      test('should handle note overlap with multiple word possibilities', () {
        final expense = ExpenseTestHelper.createExpenseWithNote('coffee shop');
        final filtered = ExpenseInputValidator.filterValidExpenses(
          [expense],
          'coffee',
          requireInputOverlap: true,
        );
        expect(filtered.length, 1);
      });

      test('should reject when all words are ignored', () {
        final expense = ExpenseTestHelper.createExpenseWithNote('test');
        final filtered = ExpenseInputValidator.filterValidExpenses(
          [expense],
          'today and for the', // All ignored words
          requireInputOverlap: true,
        );
        // Should be rejected since no meaningful word matches
        expect(filtered, isEmpty);
      });

      test('should validate multiple expenses with overlap requirement', () {
        final expenses = [
          ExpenseTestHelper.createExpenseWithNote('coffee'),
          ExpenseTestHelper.createExpenseWithNote('tea'),
        ];
        final filtered = ExpenseInputValidator.filterValidExpenses(
          expenses,
          'coffee tea',
          requireInputOverlap: true,
        );
        expect(filtered.length, 2);
      });

      test('should handle very long expense descriptions', () {
        final longNote = 'lunch ' * 50;
        final expense = ExpenseTestHelper.createExpenseWithNote(longNote);
        final filtered = ExpenseInputValidator.filterValidExpenses(
          [expense],
          'lunch',
          requireInputOverlap: false,
        );
        expect(filtered.length, 1);
      });

      test('should handle special unicode edge cases', () {
        final expense = ExpenseTestHelper.createExpenseWithNote(
          '😀😁😂 test emoji faces',
        );
        final filtered = ExpenseInputValidator.filterValidExpenses(
          [expense],
          'emoji',
          requireInputOverlap: false,
        );
        expect(filtered, isNotEmpty);
      });
    });
  });
}
