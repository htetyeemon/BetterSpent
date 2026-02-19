import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../models/category_option.dart';
import '../widgets/edit_expense_actions.dart';
import '../widgets/amount_input_field.dart';
import '../widgets/category_chip_selector.dart';
import '../../../../core/widgets/custom_text_field.dart';

class EditExpenseScreen extends StatefulWidget {
  const EditExpenseScreen({super.key});
  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final TextEditingController _amountController = TextEditingController(
    text: '4.50',
  );
  final TextEditingController _noteController = TextEditingController(
    text: 'Coffee at Starbucks',
  );
  DateTime _selectedDate = DateTime.now();
  String _selectedCategory = 'Coffee';

  final List<CategoryOption> _categories = [
    CategoryOption(
      name: 'Food',
      icon: Icons.restaurant_outlined,
      color: AppColors.primary,
    ),
    CategoryOption(
      name: 'Coffee',
      icon: Icons.local_cafe_outlined,
      color: Color(0xFFFF8800),
    ),
    CategoryOption(
      name: 'Transport',
      icon: Icons.directions_car_outlined,
      color: AppColors.secondary,
    ),
    CategoryOption(
      name: 'Shopping',
      icon: Icons.shopping_cart_outlined,
      color: AppColors.primary,
    ),
    CategoryOption(
      name: 'Other',
      icon: Icons.category_outlined,
      color: AppColors.textSecondary,
    ),
  ];

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
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.go(RouteNames.expenses),
                    color: AppColors.textPrimary,
                  ),
                  const Expanded(
                    child: Center(
                      child: Text('Edit Expense', style: AppTextStyles.h2),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AmountInputField(controller: _amountController),
                    const SizedBox(height: AppConstants.spacingLg),
                    CategoryChipSelector(
                      categories: _categories.map((c) => c.name).toList(),
                      selectedCategory: _selectedCategory,
                      onCategorySelected: (s) =>
                          setState(() => _selectedCategory = s),
                    ),
                    const SizedBox(height: AppConstants.spacingLg),
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
                    const SizedBox(height: AppConstants.spacingLg),
                    Text(
                      'DATE',
                      style: AppTextStyles.labelSmall.copyWith(
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingSm),
                    GestureDetector(
                      onTap: () => _pickDate(context),
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
                          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            EditExpenseActions(
              onCancel: () => context.go(RouteNames.expenses),
              onSave: () => context.go(RouteNames.expenses),
            ),
          ],
        ),
      ),
    );
  }
}
