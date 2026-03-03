import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/bottom_navigation.dart';
import '../../../../core/router/route_names.dart';
import '../../../../presentation/providers/app_provider.dart';

import '../widgets/smart_input_settings_section.dart';
import '../widgets/currency_settings_tile.dart';
import '../widgets/notifications_section.dart';
import '../widgets/data_management_section.dart';
import '../widgets/help_info_section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _currentNavIndex = 3;

  String _getCurrencyName(String code) =>
      code == 'THB' ? 'Baht' : 'US Dollar';
  String _getCurrencySymbol(String code) => code == 'THB' ? '฿' : '\$';

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
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
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
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
                children: [
                  SmartInputSettingsSection(
                    aiInputEnabled: settings.aiInputEnabled,
                    onAiInputChanged: (value) {
                      provider.updateSettings(
                        settings.copyWith(aiInputEnabled: value),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  CurrencySettingsTile(
                    selectedCurrencyName: _getCurrencyName(settings.currency),
                    selectedCurrencySymbol: _getCurrencySymbol(settings.currency),
                    onCurrencySelected: (name, symbol) {
                      final code = symbol == '฿' ? 'THB' : 'USD';
                      provider.updateSettings(
                        settings.copyWith(currency: code),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

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
                  const SizedBox(height: 24),

                  DataManagementSection(
                    onClearData: () => provider.clearAllData(),
                  ),
                  const SizedBox(height: 24),

                  const HelpInfoSection(),
                ],
              ),
            ),

            // Bottom Navigation
            BottomNavigation(
              currentIndex: _currentNavIndex,
              onTap: (index) {
                setState(() => _currentNavIndex = index);
                _navigateToScreen(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToScreen(int index) {
    switch (index) {
      case 0:
        context.go(RouteNames.home);
        break;
      case 1:
        context.go(RouteNames.expenses);
        break;
      case 2:
        context.go(RouteNames.summary);
        break;
      case 3:
        break;
    }
  }
}
