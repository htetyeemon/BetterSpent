import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/primary_button.dart';

class ExpenseInputCard extends StatefulWidget {
  final bool isOnline;
  final VoidCallback onAddExpenseManually;

  const ExpenseInputCard({
    Key? key,
    required this.isOnline,
    required this.onAddExpenseManually,
  }) : super(key: key);

  @override
  State<ExpenseInputCard> createState() => _ExpenseInputCardState();
}

class _ExpenseInputCardState extends State<ExpenseInputCard> {
  final TextEditingController _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: widget.isOnline ? _buildOnlineInput() : _buildOfflineInput(),
    );
  }

  Widget _buildOnlineInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Expense Input', style: AppTextStyles.h3),
        const SizedBox(height: AppConstants.spacingMd),

        // Natural Language Input
        TextField(
          controller: _inputController,
          maxLines: 3,
          style: AppTextStyles.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Type naturally (e.g. coffee 8, lunch 25, taxi 12)',
            hintStyle: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            filled: true,
            fillColor: const Color(0xFF0F0F0F),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              borderSide: const BorderSide(color: AppColors.borderDark),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              borderSide: const BorderSide(color: AppColors.borderDark),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm),

        // Example Text
        Text(
          '"Coffee 5.50" or "Dinner 42"',
          style: AppTextStyles.bodySmall.copyWith(
            color: const Color(0xFF505050),
          ),
        ),
        const SizedBox(height: AppConstants.spacingMd),

        // Add Button
        PrimaryButton(
          text: 'Add expense',
          onPressed: () {
            // Parse and add expense
            _inputController.clear();
          },
        ),
      ],
    );
  }

  Widget _buildOfflineInput() {
    return Column(
      children: [
        // Offline Message
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off,
              size: 20,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: AppConstants.spacingSm),
            Text(
              'Smart input is unavailable offline',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spacingLg),

        // Manual Add Button
        PrimaryButton(
          text: 'ADD EXPENSE MANUALLY',
          onPressed: widget.onAddExpenseManually,
        ),
      ],
    );
  }
}
