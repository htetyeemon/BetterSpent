import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../models/currency.dart';

class CurrencySelectorSheet extends StatefulWidget {
  final String selectedCurrency;
  final void Function(String name, String symbol) onCurrencySelected;

  const CurrencySelectorSheet({
    Key? key,
    required this.selectedCurrency,
    required this.onCurrencySelected,
  }) : super(key: key);

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
          // Header with Search
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.borderDark)),
            ),
            child: Column(
              children: [
                // Title and Close Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Currency',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      color: AppColors.textSecondary,
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Search Bar
                TextField(
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search currencies...',
                    hintStyle: TextStyle(color: AppColors.textSecondary),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF0A0A0A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.borderDark),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.borderDark),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Currency List
          Flexible(
            child: _filteredCurrencies.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'No currencies found',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: _filteredCurrencies.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.borderDark,
                    ),
                    itemBuilder: (context, index) {
                      final currency = _filteredCurrencies[index];
                      final isSelected =
                          widget.selectedCurrency == currency.name;

                      return InkWell(
                        onTap: () {
                          widget.onCurrencySelected(
                            currency.name,
                            currency.symbol,
                          );
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          color: isSelected
                              ? AppColors.borderDark
                              : Colors.transparent,
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      currency.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      currency.code,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                currency.symbol,
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  static void show(
    BuildContext context, {
    required String selectedCurrency,
    required void Function(String name, String symbol) onCurrencySelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CurrencySelectorSheet(
        selectedCurrency: selectedCurrency,
        onCurrencySelected: onCurrencySelected,
      ),
    );
  }
}
