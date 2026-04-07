import 'package:flutter_test/flutter_test.dart';
import 'package:better_spent/core/utils/amount_formatter.dart';

void main() {
  test('formatAmount trims trailing .00', () {
    expect(formatAmount(120.0), '120');
    expect(formatAmount(0.0), '0');
  });

  test('formatAmount keeps two decimals when needed', () {
    expect(formatAmount(120.5), '120.50');
    expect(formatAmount(120.56), '120.56');
  });
}
