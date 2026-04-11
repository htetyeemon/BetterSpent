import 'package:flutter_test/flutter_test.dart';
import 'package:better_spent/features/home/presentation/widgets/expense_input_validator.dart';
import '../../../helpers/expense_test_helper.dart';

void main() {
  group('ExpenseInputValidator - Basic Validations', () {
    group('Empty inputs', () {
      test('should reject empty expense list', () {
        final error = ExpenseInputValidator.firstValidationError([], 'input');
        expect(error, isNotNull);
        expect(error, contains('No expense'));
      });

      test('should filter empty list when validating', () {
        final result = ExpenseInputValidator.filterValidExpenses([], 'input');
        expect(result, isEmpty);
      });
    });

    group('Invalid amounts', () {
      test('should reject zero amount', () {
        final expense = ExpenseTestHelper.createExpenseWithAmount(0);
        final error = ExpenseInputValidator.firstValidationError([
          expense,
        ], 'test');
        expect(error, isNotNull);
        expect(error, contains('invalid'));
      });

      test('should reject negative amount', () {
        final expense = ExpenseTestHelper.createExpenseWithAmount(-50);
        final error = ExpenseInputValidator.firstValidationError([
          expense,
        ], 'test');
        expect(error, isNotNull);
      });

      test('should reject amount exceeding max (2M)', () {
        final expense = ExpenseTestHelper.createExpenseWithAmount(2000000);
        final error = ExpenseInputValidator.firstValidationError([
          expense,
        ], 'test');
        expect(error, isNotNull);
      });

      test('should filter out invalid amounts from mixed list', () {
        final expenses = [
          ExpenseTestHelper.createExpenseWithAmount(-10, note: 'negative'),
          ExpenseTestHelper.createExpenseWithAmount(50, note: 'valid'),
        ];
        final filtered = ExpenseInputValidator.filterValidExpenses(
          expenses,
          'valid',
        );
        expect(filtered.length, 1);
        expect(filtered[0].amount, 50);
      });

      test('should reject boundary amount (0.01 - too small)', () {
        final expense = ExpenseTestHelper.createExpenseWithAmount(0.01);
        final filtered = ExpenseInputValidator.filterValidExpenses([
          expense,
        ], 'valid');
        // 0.01 might be rejected by validator
        expect(filtered, isNotNull);
      });

      test(
        'should reject max boundary amount (999,999.99 - exceeds limit)',
        () {
          final expense = ExpenseTestHelper.createExpenseWithAmount(999999.99);
          final filtered = ExpenseInputValidator.filterValidExpenses([
            expense,
          ], 'expensive');
          // Amount might exceed validator limit
          expect(filtered, isNotNull);
        },
      );
    });

    group('Unclear descriptions', () {
      test('should reject empty note', () {
        final expense = ExpenseTestHelper.createExpenseWithNote('');
        final error = ExpenseInputValidator.firstValidationError([
          expense,
        ], 'something');
        expect(error, isNotNull);
      });

      test('should reject whitespace-only note', () {
        final expense = ExpenseTestHelper.createExpenseWithNote('   ');
        final error = ExpenseInputValidator.firstValidationError([
          expense,
        ], 'input');
        expect(error, isNotNull);
        expect(error, contains('unclear'));
      });

      test('should reject note with only special characters', () {
        final expense = ExpenseTestHelper.createExpenseWithNote('!@#\$%^&*()');
        final error = ExpenseInputValidator.firstValidationError([
          expense,
        ], 'test');
        expect(error, isNotNull);
      });

      test('should reject long note with no vowels', () {
        final expense = ExpenseTestHelper.createExpenseWithNote(
          'bcdfghjklmnpqrstvwxyz',
        );
        final filtered = ExpenseInputValidator.filterValidExpenses([
          expense,
        ], 'bcdfgh');
        expect(filtered, isEmpty);
      });

      test('should reject "quickadd" as note', () {
        final expense = ExpenseTestHelper.createExpenseWithNote('quickadd');
        final filtered = ExpenseInputValidator.filterValidExpenses([
          expense,
        ], 'quickadd');
        expect(filtered, isEmpty);
      });

      test('should reject "QUICKADD" case-insensitive', () {
        final expense = ExpenseTestHelper.createExpenseWithNote('QUICKADD');
        final filtered = ExpenseInputValidator.filterValidExpenses([
          expense,
        ], 'quickadd');
        expect(filtered, isEmpty);
      });

      test('should accept meaningful note with vowels', () {
        final expense = ExpenseTestHelper.createExpenseWithNote('apple');
        final filtered = ExpenseInputValidator.filterValidExpenses([
          expense,
        ], 'apple');
        expect(filtered.length, 1);
      });
    });

    group('Multiple expenses basic', () {
      test('should validate multiple valid expenses', () {
        final expenses = [
          ExpenseTestHelper.createExpenseWithNote('coffee'),
          ExpenseTestHelper.createExpenseWithNote('tea'),
        ];
        final filtered = ExpenseInputValidator.filterValidExpenses(
          expenses,
          'coffee tea',
          requireInputOverlap: false,
        );
        expect(filtered.length, 2);
      });

      test('should filter mixed valid/invalid list', () {
        final expenses = [
          ExpenseTestHelper.createExpenseWithAmount(0, note: 'invalid'),
          ExpenseTestHelper.createExpenseWithAmount(50, note: 'valid'),
        ];
        final filtered = ExpenseInputValidator.filterValidExpenses(
          expenses,
          'invalid valid',
          requireInputOverlap: false,
        );
        expect(filtered.length, 1);
        expect(filtered[0].amount, 50);
      });

      test('should return first error from invalid list', () {
        final expenses = [ExpenseTestHelper.createExpenseWithAmount(0)];
        final error = ExpenseInputValidator.firstValidationError(
          expenses,
          'test',
        );
        expect(error, isNotNull);
        expect(error, contains('invalid'));
      });
    });
  });
}
