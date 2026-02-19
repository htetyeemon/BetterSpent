import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/toggle_switch.dart';

class SmartInputSettingsSection extends StatelessWidget {
  final bool aiInputEnabled;
  final Function(bool) onAiInputChanged;

  const SmartInputSettingsSection({
    super.key,
    required this.aiInputEnabled,
    required this.onAiInputChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SMART INPUT SETTINGS',
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
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'AI expense input',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Use natural language to add expenses',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              ToggleSwitch(value: aiInputEnabled, onChanged: onAiInputChanged),
            ],
          ),
        ),
      ],
    );
  }
}
