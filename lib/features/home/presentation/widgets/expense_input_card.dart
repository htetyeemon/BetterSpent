import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/category_helper.dart';
import '../../../../core/widgets/success_snackbar.dart';
import '../../../../data/datasources/gemini_service.dart';
import '../../../../domain/entities/expense.dart';
import '../../../../presentation/providers/app_provider.dart';
import '../../../../features/expenses/presentation/utils/expense_screen_actions.dart';
import 'expense_input_body.dart';
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
  String? _progressMessage;
  Expense? _pendingPreview;
  int _pendingCount = 0;
  static const int _maxAiInputWords = 500;

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
                progressMessage: _progressMessage,
                pendingPreview: _pendingPreview,
                pendingCount: _pendingCount,
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
    final words = rawInput.split(RegExp(r'\s+'));
    if (words.length > _maxAiInputWords) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please keep AI input under 500 words.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      setState(() {
        _progressMessage = 'Analyzing with AI parser...';
        _pendingPreview = null;
        _pendingCount = 0;
      });

      final aiParsedList = await _geminiService.parseExpenseInputs(rawInput);

      final expenses = aiParsedList
          .map(
            (aiParsed) => Expense(
              id: '',
              amount: aiParsed.amount,
              category: CategoryHelper.normalizeLabel(aiParsed.category),
              date: aiParsed.date,
              note: ExpenseScreenActions.sanitizeNote(aiParsed.note),
            ),
          )
          .toList();

      final validated = ExpenseInputValidator.filterValidExpenses(
        expenses,
        rawInput,
        requireInputOverlap: false,
      );

      if (validated.isEmpty) {
        final reason = ExpenseInputValidator.firstValidationError(
              expenses,
              rawInput,
              requireInputOverlap: false,
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

      if (!mounted) return;
      final provider = context.read<AppProvider>();
      setState(() {
        _progressMessage =
            validated.length == 1 ? 'Adding expense...' : 'Adding expenses...';
        _pendingPreview = validated.first;
        _pendingCount = validated.length;
      });

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
    } catch (e, st) {
      debugPrint('AI expense parse failed: $e');
      debugPrintStack(stackTrace: st);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'AI parser failed: $e. Your text is still in the input for editing.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _progressMessage = null;
          _pendingPreview = null;
          _pendingCount = 0;
        });
      }
    }
  }
}
