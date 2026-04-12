import '../models/currency.dart';

class CurrencyCatalog {
  static const List<Currency> currencies = [
    Currency(name: 'US Dollar', symbol: '\$', code: 'USD'),
    Currency(name: 'Euro', symbol: '€', code: 'EUR'),
    Currency(name: 'British Pound', symbol: '£', code: 'GBP'),
    Currency(name: 'Japanese Yen', symbol: '¥', code: 'JPY'),
    Currency(name: 'Chinese Yuan', symbol: '¥', code: 'CNY'),
    Currency(name: 'Australian Dollar', symbol: '\$', code: 'AUD'),
    Currency(name: 'Canadian Dollar', symbol: '\$', code: 'CAD'),
    Currency(name: 'Swiss Franc', symbol: 'Fr', code: 'CHF'),
    Currency(name: 'Indian Rupee', symbol: '₹', code: 'INR'),
    Currency(name: 'Singapore Dollar', symbol: '\$', code: 'SGD'),
    Currency(name: 'Baht', symbol: '฿', code: 'THB'),
    Currency(name: 'South Korean Won', symbol: '₩', code: 'KRW'),
    Currency(name: 'Hong Kong Dollar', symbol: '\$', code: 'HKD'),
    Currency(name: 'New Zealand Dollar', symbol: '\$', code: 'NZD'),
    Currency(name: 'Swedish Krona', symbol: 'kr', code: 'SEK'),
    Currency(name: 'Norwegian Krone', symbol: 'kr', code: 'NOK'),
    Currency(name: 'Mexican Peso', symbol: '\$', code: 'MXN'),
    Currency(name: 'Brazilian Real', symbol: 'R\$', code: 'BRL'),
    Currency(name: 'South African Rand', symbol: 'R', code: 'ZAR'),
    Currency(name: 'Russian Ruble', symbol: '₽', code: 'RUB'),
  ];

  static Currency byCode(String code) {
    for (final currency in currencies) {
      if (currency.code == code) return currency;
    }
    return currencies.first;
  }

  static String nameForCode(String code) => byCode(code).name;

  static String symbolForCode(String code) => byCode(code).symbol;
}
