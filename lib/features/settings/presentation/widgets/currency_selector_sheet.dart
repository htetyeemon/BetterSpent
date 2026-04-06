import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/currency.dart';
import 'currency_selector_widgets.dart';

class CurrencySelectorSheet extends StatefulWidget {
  final String selectedCurrencyCode;
  final void Function(String code) onCurrencySelected;

  const CurrencySelectorSheet({
    super.key,
    required this.selectedCurrencyCode,
    required this.onCurrencySelected,
  });

  @override
  State<CurrencySelectorSheet> createState() => _CurrencySelectorSheetState();
}

class _CurrencySelectorSheetState extends State<CurrencySelectorSheet> {
  String _searchQuery = '';

  static const List<Currency> _currencies = [
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

  List<Currency> get _filteredCurrencies {
    if (_searchQuery.isEmpty) {
      return _currencies;
    }
    return _currencies.where((currency) {
      final query = _searchQuery.toLowerCase();
      return currency.name.toLowerCase().contains(query) ||
          currency.code.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CurrencySelectorHeader(
            onSearchChanged: (value) {
              setState(() => _searchQuery = value);
            },
          ),

          // Currency List
          Flexible(
            child: CurrencyList(
              currencies: _filteredCurrencies,
              selectedCurrencyCode: widget.selectedCurrencyCode,
              onSelected: (code) {
                widget.onCurrencySelected(code);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

}
