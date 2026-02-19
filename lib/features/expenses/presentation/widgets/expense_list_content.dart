import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import 'expense_card.dart';
import 'date_section_widget.dart';
import 'expense_detail_dialog.dart';
import 'delete_expense_dialog.dart';

class ExpenseListContent extends StatelessWidget {
  final String selectedFilter;

  const ExpenseListContent({super.key, required this.selectedFilter});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
      children: [
        if (_showSection('Today'))
          DateSectionWidget(
            date: 'Feb 17, 2026',
            expenses: [
              ExpenseCard(
                name: 'Morning Coffee',
                category: 'FOOD & DRINK',
                amount: 4.50,
                time: 'Today, 8:30 AM',
                onTap: () => _showExpenseDetail(
                  context,
                  name: 'Morning Coffee',
                  category: 'FOOD & DRINK',
                  amount: 4.50,
                  time: 'Today, 8:30 AM',
                  note: 'Coffee at local café',
                  icon: Icons.local_cafe_outlined,
                  iconColor: AppColors.accent,
                ),
              ),
              ExpenseCard(
                name: 'Lunch at Subway',
                category: 'FOOD & DRINK',
                amount: 12.30,
                time: 'Today, 12:15 PM',
                onTap: () => _showExpenseDetail(
                  context,
                  name: 'Lunch at Subway',
                  category: 'FOOD & DRINK',
                  amount: 12.30,
                  time: 'Today, 12:15 PM',
                  note: 'Quick lunch break',
                  icon: Icons.restaurant_outlined,
                  iconColor: AppColors.accent,
                ),
              ),
            ],
          ),

        if (_showSection('Yesterday') || selectedFilter == 'All Time')
          const SizedBox(height: AppConstants.spacingLg),

        if (_showSection('This Week') || selectedFilter == 'All Time')
          DateSectionWidget(
            date: 'Feb 16, 2026',
            expenses: [
              ExpenseCard(
                name: 'Dinner at Olive Garden',
                category: 'FOOD & DRINK',
                amount: 45.00,
                time: 'Yesterday, 7:30 PM',
                onTap: () => _showExpenseDetail(
                  context,
                  name: 'Dinner at Olive Garden',
                  category: 'FOOD & DRINK',
                  amount: 45.00,
                  time: 'Yesterday, 7:30 PM',
                  note: 'Dinner outing',
                  icon: Icons.restaurant_outlined,
                  iconColor: AppColors.accent,
                ),
              ),
              ExpenseCard(
                name: 'Gas Station',
                category: 'TRANSPORT',
                amount: 50.00,
                time: 'Yesterday, 6:00 PM',
                onTap: () => _showExpenseDetail(
                  context,
                  name: 'Gas Station',
                  category: 'TRANSPORT',
                  amount: 50.00,
                  time: 'Yesterday, 6:00 PM',
                  note: 'Fuel refill',
                  icon: Icons.local_gas_station_outlined,
                  iconColor: AppColors.accent,
                ),
              ),
            ],
          ),

        if (_showSection('This Month') || selectedFilter == 'All Time')
          const SizedBox(height: AppConstants.spacingLg),

        if (_showSection('This Month') || selectedFilter == 'All Time')
          DateSectionWidget(
            date: 'Feb 14, 2026',
            expenses: [
              ExpenseCard(
                name: 'Grocery Shopping',
                category: 'GROCERY',
                amount: 85.20,
                time: 'Feb 14, 2:45 PM',
                onTap: () => _showExpenseDetail(
                  context,
                  name: 'Grocery Shopping',
                  category: 'GROCERY',
                  amount: 85.20,
                  time: 'Feb 14, 2:45 PM',
                  note: 'Weekly groceries',
                  icon: Icons.shopping_cart_outlined,
                  iconColor: AppColors.accent,
                ),
              ),
            ],
          ),

        const SizedBox(height: AppConstants.spacingXl),
      ],
    );
  }

  bool _showSection(String sectionType) {
    if (selectedFilter == 'All Time') return true;

    switch (selectedFilter) {
      case 'Today':
        return sectionType == 'Today';
      case 'This Week':
        return sectionType == 'This Week';
      case 'This Month':
        return sectionType == 'This Month';
      default:
        return true;
    }
  }

  void _showExpenseDetail(
    BuildContext context, {
    required String name,
    required String category,
    required double amount,
    required String time,
    required String note,
    required IconData icon,
    required Color iconColor,
  }) {
    ExpenseDetailDialog.show(
      context,
      name: name,
      category: category,
      amount: amount,
      time: time,
      note: note,
      categoryIcon: icon,
      iconColor: iconColor,
      onEdit: () => context.push(RouteNames.editExpense),
      onDelete: () => DeleteExpenseDialog.show(
        context,
        onConfirm: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense deleted'),
            backgroundColor: AppColors.error,
          ),
        ),
      ),
    );
  }
}
