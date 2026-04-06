import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/amount_formatter.dart';
import 'set_budget_dialog_content.dart';

class SetBudgetDialog extends StatefulWidget {
  final String currencySymbol;
  final void Function(double) onSave;
  final double? currentBudget;
  final double currentBalance;

  const SetBudgetDialog({
    super.key,
    required this.currencySymbol,
    required this.onSave,
    required this.currentBalance,
    this.currentBudget,
  });

  static void show(
    BuildContext context, {
    required String currencySymbol,
    required void Function(double) onSave,
    required double currentBalance,
    double? currentBudget,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (_) => SetBudgetDialog(
        currencySymbol: currencySymbol,
        onSave: onSave,
        currentBalance: currentBalance,
        currentBudget: currentBudget,
      ),
    );
  }

  @override
  State<SetBudgetDialog> createState() => _SetBudgetDialogState();
}

class _SetBudgetDialogState extends State<SetBudgetDialog> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();
  String? _balanceError;

  @override
  void initState() {
    super.initState();
    if (widget.currentBudget != null) {
      _controller.text = formatAmount(widget.currentBudget!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close() => Navigator.pop(context);

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final amount = double.parse(_controller.text);
      if (amount > widget.currentBalance) {
        setState(() {
          _balanceError = 'Budget cannot exceed your current balance';
        });
        return;
      }
      widget.onSave(amount);
      _close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SetBudgetDialogContent(
        formKey: _formKey,
        controller: _controller,
        currencySymbol: widget.currencySymbol,
        balanceError: _balanceError,
        onClose: _close,
        onSubmit: _submit,
        onChanged: (_) {
          if (_balanceError != null) {
            setState(() => _balanceError = null);
          }
        },
      ),
    );
  }
}
