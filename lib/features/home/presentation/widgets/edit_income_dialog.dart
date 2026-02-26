import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_helper.dart';
import '../../../../core/widgets/base_dialog.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/widgets/secondary_button.dart';
import '../../../../core/widgets/app_text_field.dart';

class EditIncomeDialog extends StatefulWidget {
  final String currencySymbol;
  final double initialAmount;
  final void Function(double amount, String date) onSave;

  const EditIncomeDialog({
    super.key,
    required this.currencySymbol,
    required this.initialAmount,
    required this.onSave,
  });

  static void show(
    BuildContext context, {
    required String currencySymbol,
    required double initialAmount,
    required void Function(double amount, String date) onSave,
  }) {
    showDialog(
      context: context,
      barrierColor: AppColors.overlay,
      builder: (_) => EditIncomeDialog(
        currencySymbol: currencySymbol,
        initialAmount: initialAmount,
        onSave: onSave,
      ),
    );
  }

  @override
  State<EditIncomeDialog> createState() => _EditIncomeDialogState();
}

class _EditIncomeDialogState extends State<EditIncomeDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialAmount.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_controller.text);
    final date = DateHelper.formatDate(DateTime.now());

    widget.onSave(amount, date);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BaseDialog(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingSm),
                const Expanded(
                  child: Text('Edit Income', style: AppTextStyles.h2),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.close,
                    size: 20,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.spacingXl),

            /// LABEL
            const Text('AMOUNT', style: AppTextStyles.labelSmall),
            const SizedBox(height: AppConstants.spacingSm),

            /// FIELD
            AppTextField(
              controller: _controller,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              hintText: '0.00',
              style: AppTextStyles.h3,
              prefix: Padding(
                padding: const EdgeInsets.only(
                  left: AppConstants.spacingMd,
                  right: AppConstants.spacingSm,
                ),
                child: Text(
                  widget.currencySymbol,
                  style: AppTextStyles.h3.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Please enter an amount';
                }
                final value = double.tryParse(v);
                if (value == null) {
                  return 'Please enter a valid number';
                }
                if (value <= 0) {
                  return 'Amount must be greater than 0';
                }
                return null;
              },
            ),

            const SizedBox(height: AppConstants.spacingXl),

            /// BUTTONS
            Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    text: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingSm),
                Expanded(
                  child: PrimaryButton(text: 'Update', onPressed: _submit),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
