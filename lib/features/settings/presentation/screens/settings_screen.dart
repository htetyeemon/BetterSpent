import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/bottom_navigation.dart';
import '../../../../core/router/route_names.dart';

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

  bool _aiInputEnabled = true;
  bool _budgetAlertsEnabled = true;
  bool _motivationalEnabled = false;

  String _selectedCurrencyName = 'Baht';
  String _selectedCurrencySymbol = '฿';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ✅ FIXED HEADER
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
                    aiInputEnabled: _aiInputEnabled,
                    onAiInputChanged: (value) {
                      setState(() => _aiInputEnabled = value);
                    },
                  ),
                  const SizedBox(height: 24),

                  CurrencySettingsTile(
                    selectedCurrencyName: _selectedCurrencyName,
                    selectedCurrencySymbol: _selectedCurrencySymbol,
                    onCurrencySelected: (name, symbol) {
                      setState(() {
                        _selectedCurrencyName = name;
                        _selectedCurrencySymbol = symbol;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  NotificationsSection(
                    budgetAlertsEnabled: _budgetAlertsEnabled,
                    motivationalEnabled: _motivationalEnabled,
                    onBudgetAlertsChanged: (value) {
                      setState(() => _budgetAlertsEnabled = value);
                    },
                    onMotivationalChanged: (value) {
                      setState(() => _motivationalEnabled = value);
                    },
                  ),
                  const SizedBox(height: 24),

                  const DataManagementSection(),
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
