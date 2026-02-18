import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/help_content.dart';

class HelpInfoSection extends StatelessWidget {
  const HelpInfoSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HELP & INFO',
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
              _buildHelpItem(
                context,
                'How to use BetterSpent',
                null,
                Icons.arrow_forward_ios,
                const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.borderDark,
              ),
              _buildHelpItem(
                context,
                'Offline vs online mode',
                null,
                Icons.arrow_forward_ios,
                null,
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.borderDark,
              ),
              _buildHelpItem(
                context,
                'About this app',
                'VERSION 1.4.2',
                Icons.info_outline,
                const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHelpItem(
    BuildContext context,
    String title,
    String? subtitle,
    IconData icon,
    BorderRadius? borderRadius,
  ) {
    return InkWell(
      onTap: () => _showHelpDialog(context, title),
      borderRadius: borderRadius,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: subtitle != null
                  ? Column(
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
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            Icon(icon, color: AppColors.textSecondary, size: 20),
          ],
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context, String title) {
    final content = HelpContent.content[title] ?? '';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surface,
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderDark),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
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
              ),
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.borderDark,
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    content,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
