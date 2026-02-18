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

class AddIncomeDialog extends StatefulWidget {
  final String currencySymbol;
  final void Function(double amount, String date) onSave;
  final String mode;

  const AddIncomeDialog({
    Key? key,
    required this.currencySymbol,
    required this.onSave,
    this.mode = 'add',
  }) : super(key: key);

  static void show(
    BuildContext context, {
    required String currencySymbol,
    required void Function(double amount, String date) onSave,
    String mode = 'add',
  }) {
    showDialog(
      context: context,
      barrierColor: AppColors.overlay,
      builder: (_) => AddIncomeDialog(
        currencySymbol: currencySymbol,
        onSave: onSave,
        mode: mode,
      ),
    );
  }

  @override
  State<AddIncomeDialog> createState() => _AddIncomeDialogState();
}

class _AddIncomeDialogState extends State<AddIncomeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  bool get _isAdd => widget.mode == 'add';

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
                    Icons.attach_money,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppConstants.spacingSm),
                Expanded(
                  child: Text(
                    _isAdd ? 'Add Income' : 'Update Income',
                    style: AppTextStyles.h2,
                  ),
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
                  child: PrimaryButton(
                    text: _isAdd ? 'Add Income' : 'Update Income',
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
