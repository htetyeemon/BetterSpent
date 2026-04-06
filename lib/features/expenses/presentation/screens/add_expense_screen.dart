import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/utils/category_helper.dart';
import '../../../../core/utils/date_helper.dart';
import '../widgets/category_chip_selector.dart';
import '../widgets/amount_input_field.dart';
import '../utils/expense_screen_actions.dart';
import '../../../../presentation/providers/app_provider.dart';
import '../widgets/expense_screen_header.dart';
import '../widgets/expense_note_section.dart';
import '../widgets/expense_date_section.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String _selectedCategory = AppConstants.expenseCategories.first;
  DateTime _selectedDate = DateTime.now();

  final List<String> _categories = AppConstants.expenseCategories;

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
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
              title: 'Add Expense',
              onBack: () => context.go(RouteNames.home),
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
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(AppConstants.expenseStartYear),
                          lastDate: DateTime.now(),
                        );

                        if (picked != null) {
                          setState(() => _selectedDate = picked);
                        }
                      },
                    ),
                    const SizedBox(height: AppConstants.spacingXl),
                    const SizedBox(height: AppConstants.spacingXl),
                    _buildSaveButton(context),
                  ],
                ),
              ),
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
      onCategorySelected: (category) {
        setState(() => _selectedCategory = category);
      },
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return PrimaryButton(
      text: 'ADD EXPENSE',
      onPressed: () async {
        final expense = ExpenseScreenActions.buildExpense(
          amountText: _amountController.text,
          category: CategoryHelper.normalizeLabel(_selectedCategory),
          date: _selectedDate,
          note: _noteController.text,
        );
        if (expense == null) return;

        final provider = context.read<AppProvider>();
        final result = await ExpenseScreenActions.addExpense(
          provider: provider,
          expense: expense,
        );
        if (!context.mounted) return;
        if (!result.ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to add expense: ${result.error}'),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }

        context.go(
          RouteNames.home,
          extra: 'Expense added successfully',
        );
      },
    );
  }
}
