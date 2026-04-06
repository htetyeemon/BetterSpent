import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/bottom_navigation.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/success_snackbar.dart';
import '../../../../presentation/providers/app_provider.dart';
import '../../../../core/utils/bottom_nav_helper.dart';

import '../widgets/smart_input_settings_section.dart';
import '../widgets/currency_settings_tile.dart';
import '../widgets/notifications_section.dart';
import '../widgets/data_management_section.dart';
import '../widgets/help_info_section.dart';
import '../widgets/account_section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _currentNavIndex = 3;
  bool _hasShownRouteMessage = false;

  static const Map<String, String> _currencyNames = {
    'USD': 'US Dollar',
    'EUR': 'Euro',
    'GBP': 'British Pound',
    'JPY': 'Japanese Yen',
    'CNY': 'Chinese Yuan',
    'AUD': 'Australian Dollar',
    'CAD': 'Canadian Dollar',
    'CHF': 'Swiss Franc',
    'INR': 'Indian Rupee',
    'SGD': 'Singapore Dollar',
    'THB': 'Baht',
    'KRW': 'South Korean Won',
    'HKD': 'Hong Kong Dollar',
    'NZD': 'New Zealand Dollar',
    'SEK': 'Swedish Krona',
    'NOK': 'Norwegian Krone',
    'MXN': 'Mexican Peso',
    'BRL': 'Brazilian Real',
    'ZAR': 'South African Rand',
    'RUB': 'Russian Ruble',
  };

  static const Map<String, String> _currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'CNY': '¥',
    'AUD': '\$',
    'CAD': '\$',
    'CHF': 'Fr',
    'INR': '₹',
    'SGD': '\$',
    'THB': '฿',
    'KRW': '₩',
    'HKD': '\$',
    'NZD': '\$',
    'SEK': 'kr',
    'NOK': 'kr',
    'MXN': '\$',
    'BRL': 'R\$',
    'ZAR': 'R',
    'RUB': '₽',
  };

  String _getCurrencyName(String code) => _currencyNames[code] ?? 'US Dollar';
  String _getCurrencySymbol(String code) => _currencySymbols[code] ?? '\$';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasShownRouteMessage) return;

    final extra = GoRouterState.of(context).extra;
    final message = extra is String ? extra : null;
    if (message == null || message.isEmpty) return;

    _hasShownRouteMessage = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showSuccessSnackBar(context, message);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final settings = provider.settings;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spacingLg,
                AppConstants.spacingLg,
                AppConstants.spacingLg,
                AppConstants.spacingLg,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.go(RouteNames.home),
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Settings',
                    style: AppTextStyles.h2,
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.spacingLg,
                  0,
                  AppConstants.spacingLg,
                  AppConstants.spacingXl * 3,
                ),
                children: [
                  SmartInputSettingsSection(
                    aiInputEnabled: settings.aiInputEnabled,
                    onAiInputChanged: (value) {
                      provider.updateSettings(
                        settings.copyWith(aiInputEnabled: value),
                      );
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingLg),

                  CurrencySettingsTile(
                    selectedCurrencyCode: settings.currency,
                    selectedCurrencyName: _getCurrencyName(settings.currency),
                    selectedCurrencySymbol: _getCurrencySymbol(settings.currency),
                    onCurrencySelected: (code) {
                      provider.updateSettings(
                        settings.copyWith(currency: code),
                      );
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingLg),

                  NotificationsSection(
                    budgetAlertsEnabled: settings.budgetWarningEnabled,
                    motivationalEnabled: settings.motivationalMessageEnabled,
                    onBudgetAlertsChanged: (value) {
                      provider.updateSettings(
                        settings.copyWith(budgetWarningEnabled: value),
                      );
                    },
                    onMotivationalChanged: (value) {
                      provider.updateSettings(
                        settings.copyWith(motivationalMessageEnabled: value),
                      );
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingLg),

                  DataManagementSection(
                    onClearData: () => provider.clearAllData(),
                  ),
                  const SizedBox(height: AppConstants.spacingLg),

                  const AccountSection(),
                  const SizedBox(height: AppConstants.spacingLg),

                  const HelpInfoSection(),
                ],
              ),
            ),

            // Bottom Navigation
            BottomNavigation(
              currentIndex: _currentNavIndex,
              onTap: (index) {
                final currentIndex = _currentNavIndex;
                setState(() => _currentNavIndex = index);
                handleBottomNavTap(context, index, currentIndex);
              },
            ),
          ],
        ),
      ),
    );
  }

}

