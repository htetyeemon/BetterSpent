import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/category_helper.dart';
import '../../../../core/utils/date_helper.dart';
import '../widgets/edit_expense_actions.dart';
import '../widgets/amount_input_field.dart';
import '../widgets/category_chip_selector.dart';
import '../../../../domain/entities/expense.dart';
import '../../../../presentation/providers/app_provider.dart';
import '../../../../core/utils/amount_formatter.dart';
import '../utils/expense_screen_actions.dart';
import '../widgets/expense_screen_header.dart';
import '../widgets/expense_note_section.dart';
import '../widgets/expense_date_section.dart';

class EditExpenseScreen extends StatefulWidget {
  const EditExpenseScreen({super.key});
  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Other';
  Expense? _originalExpense;
  bool _initializedFromExtra = false;

  final List<String> _categories = AppConstants.expenseCategories;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initializedFromExtra) return;
    _initializedFromExtra = true;

    final extra = GoRouterState.of(context).extra;
    if (extra is Expense) {
      _originalExpense = extra;
      _amountController.text = formatAmount(extra.amount);
      _noteController.text = extra.note;
      _selectedDate = extra.date;
      _selectedCategory = CategoryHelper.normalizeLabel(extra.category);
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(AppConstants.expenseStartYear),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencySymbol = context.watch<AppProvider>().currencySymbol;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            ExpenseScreenHeader(
              title: 'Edit Expense',
              onBack: () => context.go(RouteNames.expenses),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAmountSection(currencySymbol),
                    const SizedBox(height: AppConstants.spacingLg),
                    _buildCategorySection(),
                    const SizedBox(height: AppConstants.spacingLg),
                    ExpenseNoteSection(controller: _noteController),
                    const SizedBox(height: AppConstants.spacingLg),
                    ExpenseDateSection(
                      dateLabel: DateHelper.formatIsoDate(_selectedDate),
                      onTap: () => _pickDate(context),
                    ),
                  ],
                ),
              ),
            ),

            EditExpenseActions(
              onCancel: () => context.go(RouteNames.expenses),
              onSave: () async {
                final original = _originalExpense;
                if (original == null) {
                  context.go(RouteNames.expenses);
                  return;
                }

                final amount = double.tryParse(_amountController.text.trim());
                if (amount == null || amount <= 0) return;

                final updated = original.copyWith(
                  amount: amount,
                  category: CategoryHelper.normalizeLabel(_selectedCategory),
                  date: _selectedDate,
                  note: ExpenseScreenActions.sanitizeNote(_noteController.text),
                );

                await ExpenseScreenActions.updateExpense(
                  provider: context.read<AppProvider>(),
                  expense: updated,
                );
                if (!context.mounted) return;
                context.go(RouteNames.expenses);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountSection(String currencySymbol) {
    return AmountInputField(
      controller: _amountController,
      currencySymbol: currencySymbol,
    );
  }

  Widget _buildCategorySection() {
    return CategoryChipSelector(
      categories: _categories,
      selectedCategory: _selectedCategory,
      onCategorySelected: (s) => setState(() => _selectedCategory = s),
    );
  }

}
