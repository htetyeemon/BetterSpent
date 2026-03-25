import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/utils/category_helper.dart';
import '../../../../core/utils/date_helper.dart';
import '../widgets/category_chip_selector.dart';
import '../widgets/amount_input_field.dart';
import '../utils/expense_screen_actions.dart';
import '../../../../presentation/providers/app_provider.dart';

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
            _buildHeader(context),

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
                    _buildNoteSection(),
                    const SizedBox(height: AppConstants.spacingLg),
                    _buildDateSection(context),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(RouteNames.home),
            color: AppColors.textPrimary,
          ),
          const Expanded(
            child: Center(
              child: Text('Add Expense', style: AppTextStyles.h2),
            ),
          ),
          const SizedBox(width: 48),
        ],
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

  Widget _buildNoteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NOTE',
          style: AppTextStyles.labelSmall.copyWith(
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        CustomTextField(
          controller: _noteController,
          hintText: 'Add a note...',
        ),
      ],
    );
  }

  Widget _buildDateSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DATE',
          style: AppTextStyles.labelSmall.copyWith(
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSm),
        GestureDetector(
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
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(
                AppConstants.radiusLg,
              ),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Text(
              DateHelper.formatIsoDate(_selectedDate),
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ),
      ],
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
