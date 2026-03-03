import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/category_helper.dart';
import '../../../../core/widgets/success_snackbar.dart';
import '../../../../data/datasources/gemini_service.dart';
import '../../../../domain/entities/expense.dart';
import '../../../../presentation/providers/app_provider.dart';
import 'expense_input_body.dart';
import 'expense_input_parser.dart';
import 'expense_input_validator.dart';

class ExpenseInputCard extends StatefulWidget {
  final bool isOnline;
  final bool aiInputEnabled;
  final VoidCallback onAddExpenseManually;

  const ExpenseInputCard({
    super.key,
    required this.isOnline,
    required this.aiInputEnabled,
    required this.onAddExpenseManually,
  });

  @override
  State<ExpenseInputCard> createState() => _ExpenseInputCardState();
}

class _ExpenseInputCardState extends State<ExpenseInputCard> {
  final TextEditingController _inputController = TextEditingController();
  final GeminiService _geminiService = GeminiService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = !widget.aiInputEnabled
        ? ExpenseInputManualBody(
            message: 'AI input is turned off in Settings',
            onAddExpenseManually: widget.onAddExpenseManually,
          )
        : (widget.isOnline
            ? ExpenseInputOnlineBody(
                controller: _inputController,
                isSubmitting: _isSubmitting,
                onSubmit: _handleAddExpense,
              )
            : ExpenseInputManualBody(
                message: 'Smart input is unavailable offline',
                onAddExpenseManually: widget.onAddExpenseManually,
              ));

    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: child,
    );
  }

  Future<void> _handleAddExpense() async {
    final rawInput = _inputController.text.trim();
    if (rawInput.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      final aiParsedList = await _geminiService.parseExpenseInputs(rawInput);

      final expenses = aiParsedList
          .map(
            (aiParsed) => Expense(
              id: '',
              amount: aiParsed.amount,
              category: CategoryHelper.normalizeLabel(aiParsed.category),
              date: aiParsed.date,
              note: aiParsed.note,
            ),
          )
          .toList();

      final toAdd = expenses.isNotEmpty
          ? expenses
          : ExpenseInputParser.parseMultiple(rawInput);
      final isAiResult = expenses.isNotEmpty;
      final validated = ExpenseInputValidator.filterValidExpenses(
        toAdd,
        rawInput,
        requireInputOverlap: !isAiResult,
      );

      if (validated.isEmpty) {
        final reason = ExpenseInputValidator.firstValidationError(
              toAdd,
              rawInput,
              requireInputOverlap: !isAiResult,
            ) ??
            'Could not detect a valid expense.';
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$reason Your text is still in the input so you can edit and resubmit.',
            ),
          ),
        );
        return;
      }

      final provider = context.read<AppProvider>();
      for (final expense in validated) {
        await provider.addExpense(expense);
      }
      if (!mounted) return;

      _inputController.clear();
      showSuccessSnackBar(
        context,
        validated.length == 1
            ? '1 expense added'
            : '${validated.length} expenses added',
      );
    } catch (e) {
      final fallback = ExpenseInputParser.parseMultiple(rawInput);
      final validated = ExpenseInputValidator.filterValidExpenses(
        fallback,
        rawInput,
        requireInputOverlap: true,
      );
      if (validated.isNotEmpty) {
        final provider = context.read<AppProvider>();
        for (final expense in validated) {
          await provider.addExpense(expense);
        }
        if (!mounted) return;
        _inputController.clear();
        showSuccessSnackBar(
          context,
          validated.length == 1
              ? '1 expense added (fallback parser)'
              : '${validated.length} expenses added (fallback parser)',
        );
        return;
      }

      if (!mounted) return;
      final reason = ExpenseInputValidator.firstValidationError(
            fallback,
            rawInput,
            requireInputOverlap: true,
          ) ??
          'AI input failed and no valid expense was detected.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$reason Error: $e. Your text is still in the input for editing.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
