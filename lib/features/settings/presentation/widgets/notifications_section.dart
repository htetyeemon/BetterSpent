import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/toggle_switch.dart';

class NotificationsSection extends StatelessWidget {
  final bool budgetAlertsEnabled;
  final bool motivationalEnabled;
  final Function(bool) onBudgetAlertsChanged;
  final Function(bool) onMotivationalChanged;

  const NotificationsSection({
    Key? key,
    required this.budgetAlertsEnabled,
    required this.motivationalEnabled,
    required this.onBudgetAlertsChanged,
    required this.onMotivationalChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NOTIFICATIONS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Column(
            children: [
              _buildNotificationItem(
                'Budget warning alerts',
                'Get notified when approaching limits',
                budgetAlertsEnabled,
                onBudgetAlertsChanged,
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: AppColors.borderDark,
              ),
              _buildNotificationItem(
                'Motivational messages',
                'Daily encouragement and tips',
                motivationalEnabled,
                onMotivationalChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationItem(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ToggleSwitch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
