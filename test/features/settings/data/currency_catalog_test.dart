import 'package:better_spent/features/settings/data/currency_catalog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CurrencyCatalog', () {
    test('returns symbol for known currency codes', () {
      expect(CurrencyCatalog.symbolForCode('THB'), '฿');
      expect(CurrencyCatalog.symbolForCode('RUB'), '₽');
    });

    test('returns fallback currency metadata for unknown codes', () {
      expect(CurrencyCatalog.nameForCode('UNKNOWN'), 'US Dollar');
      expect(CurrencyCatalog.symbolForCode('UNKNOWN'), '\$');
    });
  });
}
