import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/bottom_navigation.dart';
import '../../../../core/router/route_names.dart';
import 'package:go_router/go_router.dart';
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
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Positioned(
                    left: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.go(RouteNames.home),
                      color: AppColors.textPrimary,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                ],
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
                children: [
                  // Smart Input Settings
                  SmartInputSettingsSection(
                    aiInputEnabled: _aiInputEnabled,
                    onAiInputChanged: (value) {
                      setState(() => _aiInputEnabled = value);
                    },
                  ),
                  const SizedBox(height: 24),

                  // Currency Settings
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

                  // Notifications
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

                  // Data Management
                  const DataManagementSection(),
                  const SizedBox(height: 24),

                  // Help & Info
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
        // Already on settings
        break;
    }
  }
}
