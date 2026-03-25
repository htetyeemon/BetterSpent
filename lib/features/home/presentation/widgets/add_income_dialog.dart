import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'income_dialog_content.dart';

class AddIncomeDialog extends StatefulWidget {
  final String currencySymbol;
  final void Function(double amount) onSave;
  final String mode;

  const AddIncomeDialog({
    super.key,
    required this.currencySymbol,
    required this.onSave,
    this.mode = 'add',
  });

  static void show(
    BuildContext context, {
    required String currencySymbol,
    required void Function(double amount) onSave,
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
    widget.onSave(amount);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return IncomeDialogContent(
      formKey: _formKey,
      controller: _controller,
      title: _isAdd ? 'Add Income' : 'Update Income',
      icon: Icons.attach_money,
      currencySymbol: widget.currencySymbol,
      primaryButtonText: _isAdd ? 'Add' : 'Update',
      onSubmit: _submit,
    );
  }
}
