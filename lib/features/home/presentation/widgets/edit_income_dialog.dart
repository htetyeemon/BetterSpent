import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/amount_formatter.dart';
import 'income_dialog_content.dart';

class EditIncomeDialog extends StatefulWidget {
  final String currencySymbol;
  final double initialAmount;
  final void Function(double amount) onSave;

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
    required void Function(double amount) onSave,
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
      text: formatAmount(widget.initialAmount),
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
    widget.onSave(amount);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return IncomeDialogContent(
      formKey: _formKey,
      controller: _controller,
      title: 'Edit Income',
      icon: Icons.edit,
      currencySymbol: widget.currencySymbol,
      primaryButtonText: 'Update',
      onSubmit: _submit,
    );
  }
}
