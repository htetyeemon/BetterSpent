import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../../../domain/entities/expense.dart';
import '../../../../presentation/providers/app_provider.dart';
import 'expense_card.dart';
import 'date_section_widget.dart';
import 'expense_detail_dialog.dart';
import 'delete_expense_dialog.dart';

class ExpenseListContent extends StatelessWidget {
  final String selectedFilter;

  const ExpenseListContent({super.key, required this.selectedFilter});

  List<Expense> _filterExpenses(List<Expense> expenses) {
    final now = DateTime.now();
    switch (selectedFilter) {
      case 'Today':
        return expenses
            .where((e) =>
                e.date.year == now.year &&
                e.date.month == now.month &&
                e.date.day == now.day)
            .toList();
      case 'This Week':
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
        return expenses.where((e) => !e.date.isBefore(start)).toList();
      case 'This Month':
        return expenses
            .where((e) => e.date.year == now.year && e.date.month == now.month)
            .toList();
      default:
        return expenses;
    }
  }

  Map<String, List<Expense>> _groupByDate(List<Expense> expenses) {
    final Map<String, List<Expense>> groups = {};
    for (final expense in expenses) {
      final key = DateFormat('MMM d, yyyy').format(expense.date);
      groups.putIfAbsent(key, () => []).add(expense);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final filtered = _filterExpenses(provider.expenses);
    final grouped = _groupByDate(filtered);
    final dateKeys = grouped.keys.toList();

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            'No expenses found',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
      itemCount: dateKeys.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppConstants.spacingLg),
      itemBuilder: (context, index) {
        final dateKey = dateKeys[index];
        final dayExpenses = grouped[dateKey]!;
        return DateSectionWidget(
          date: dateKey,
          expenses: dayExpenses.map((expense) {
            return ExpenseCard(
              name: expense.note.isNotEmpty ? expense.note : expense.category,
              category: expense.category.toUpperCase(),
              amount: expense.amount,
              time: DateFormat('MMM d, h:mm a').format(expense.date),
              onTap: () => _showExpenseDetail(context, expense, provider),
            );
          }).toList(),
        );
      },
    );
  }

  void _showExpenseDetail(
    BuildContext context,
    Expense expense,
    AppProvider provider,
  ) {
    ExpenseDetailDialog.show(
      context,
      name: expense.note.isNotEmpty ? expense.note : expense.category,
      category: expense.category.toUpperCase(),
      amount: expense.amount,
      time: DateFormat('MMM d, h:mm a').format(expense.date),
      note: expense.note,
      categoryIcon: Icons.category_outlined,
      iconColor: AppColors.accent,
      onEdit: () => context.push(RouteNames.editExpense),
      onDelete: () => DeleteExpenseDialog.show(
        context,
        onConfirm: () {
          provider.deleteExpense(expense.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense deleted'),
              backgroundColor: AppColors.error,
            ),
          );
        },
      ),
    );
  }
}
