import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/currency_catalog.dart';
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

  List<Currency> get _filteredCurrencies {
    if (_searchQuery.isEmpty) {
      return CurrencyCatalog.currencies;
    }
    return CurrencyCatalog.currencies.where((currency) {
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
