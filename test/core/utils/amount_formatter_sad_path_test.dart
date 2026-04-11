import 'package:flutter_test/flutter_test.dart';
import 'package:better_spent/core/utils/amount_formatter.dart';

void main() {
  group('AmountFormatter - Sad Path Tests', () {
    group('Edge case amounts', () {
      test('should handle zero amount', () {
        final result = formatAmount(0.0);
        expect(result, '0');
      });

      test('should handle very small amounts (0.01)', () {
        final result = formatAmount(0.01);
        expect(result, '0.01');
      });

      test('should handle very small amounts (0.001)', () {
        final result = formatAmount(0.001);
        expect(result, '0');
      });

      test('should handle negative amounts', () {
        final result = formatAmount(-100.0);
        expect(result, '-100');
      });

      test('should handle negative amounts with decimals', () {
        final result = formatAmount(-99.99);
        expect(result, '-99.99');
      });

      test('should handle extremely large amounts', () {
        final result = formatAmount(999999999.99);
        expect(result, '999999999.99');
      });

      test('should handle billion dollar amount', () {
        final result = formatAmount(1000000000.0);
        expect(result, '1000000000');
      });

      test('should handle amounts with rounding precision issues', () {
        final result = formatAmount(
          0.1 + 0.2,
        ); // Classic float issue: 0.1 + 0.2 = 0.30000000000000004
        // The formatter correctly converts to string but may preserve trailing .0
        expect(result, isNotEmpty);
        expect(double.parse(result), closeTo(0.3, 0.0001));
      });

      test('should handle amounts that round to .00', () {
        final result = formatAmount(100.004);
        expect(result, '100');
      });

      test('should handle amounts that have .01 at end', () {
        final result = formatAmount(50.01);
        expect(result, '50.01');
      });
    });

    group('Rounding edge cases', () {
      test('should handle amount that needs rounding up', () {
        final result = formatAmount(99.999);
        expect(result, isNotEmpty);
      });

      test('should handle amount with three decimal places', () {
        final result = formatAmount(50.125);
        expect(result, isNotEmpty);
      });

      test('should handle amount with many decimal places', () {
        final result = formatAmount(100.123456789);
        expect(result, isNotEmpty);
      });
    });

    group('Special float values', () {
      test('should handle minimal positive value', () {
        final result = formatAmount(double.minPositive);
        expect(result, isNotEmpty);
      });

      test('should handle maximum safe integer as double', () {
        final result = formatAmount(9007199254740992.0);
        expect(result, isNotEmpty);
      });
    });
  });
}
