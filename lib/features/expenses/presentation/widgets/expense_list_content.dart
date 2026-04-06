import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/category_icon.dart';
import '../../../../core/utils/category_helper.dart';
import '../../../../domain/entities/expense.dart';
import '../../../../presentation/providers/app_provider.dart';
import 'expense_card.dart';
import 'expense_detail_dialog.dart';
import 'delete_expense_dialog.dart';
import 'expense_list_entry.dart';
import 'expense_list_helpers.dart';

class ExpenseListContent extends StatefulWidget {
  final String selectedFilter;
  static final DateFormat _dayFormatter = DateFormat('MMM d, yyyy');
  static final DateFormat _timeFormatter = DateFormat('MMM d, h:mm a');

  const ExpenseListContent({super.key, required this.selectedFilter});

  @override
  State<ExpenseListContent> createState() => _ExpenseListContentState();
}

class _ExpenseListContentState extends State<ExpenseListContent> {
  static const int _pageSize = 50;
  List<Expense>? _cachedExpenses;
  String? _cachedFilter;
  int _cachedVisibleCount = 0;
  List<Expense> _cachedFiltered = const [];
  Map<String, List<Expense>> _cachedGrouped = const {};
  List<String> _cachedDateKeys = const [];
  List<ExpenseListEntry> _cachedEntries = const [];
  int _visibleCount = _pageSize;

  List<Expense> _filterExpenses(List<Expense> expenses, String filter) {
    return filterExpenses(expenses, filter);
  }

  Map<String, List<Expense>> _groupByDate(List<Expense> expenses) {
    return groupByDate(expenses, ExpenseListContent._dayFormatter);
  }

  void _ensureCache(List<Expense> expenses) {
    final filterChanged = _cachedFilter != widget.selectedFilter;
    if (filterChanged) {
      _visibleCount = _pageSize;
    }
    if (identical(expenses, _cachedExpenses) &&
        !filterChanged &&
        _cachedVisibleCount == _visibleCount) {
      return;
    }

    _cachedExpenses = expenses;
    _cachedFilter = widget.selectedFilter;
    _cachedFiltered = _filterExpenses(expenses, widget.selectedFilter);
    final visibleFiltered = _cachedFiltered.length > _visibleCount
        ? _cachedFiltered.sublist(0, _visibleCount)
        : _cachedFiltered;
    _cachedGrouped = _groupByDate(visibleFiltered);
    _cachedDateKeys = _cachedGrouped.keys.toList();
    _cachedEntries = buildEntries(
      _cachedGrouped,
      _cachedDateKeys,
      hasMore: _cachedFiltered.length > _visibleCount,
    );
    _cachedVisibleCount = _visibleCount;
  }

  @override
  Widget build(BuildContext context) {
    final expenses = context.select((AppProvider p) => p.expenses);
    final currencySymbol = context.select((AppProvider p) => p.currencySymbol);
    _ensureCache(expenses);
    final filtered = _cachedFiltered;
    final entries = _cachedEntries;

    if (filtered.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Text(
            'No expenses found',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
      itemCount: entries.length,
      separatorBuilder: (_, _) => const SizedBox(height: 0),
      itemBuilder: (context, index) {
        final entry = entries[index];
        if (entry.type == ExpenseListEntryType.header) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.header!,
                style: AppTextStyles.labelSmall.copyWith(letterSpacing: 1.5),
              ),
              const SizedBox(height: AppConstants.spacingMd),
            ],
          );
        }
        if (entry.type == ExpenseListEntryType.sectionSpacer) {
          return const SizedBox(height: AppConstants.spacingLg);
        }
        if (entry.type == ExpenseListEntryType.loadMore) {
          return Padding(
            padding: const EdgeInsets.only(
              top: AppConstants.spacingSm,
              bottom: AppConstants.spacingLg,
            ),
            child: Center(
              child: OutlinedButton(
                onPressed: _handleLoadMore,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.borderDark),
                ),
                child: Text('Load more'),
              ),
            ),
          );
        }

        final expense = entry.expense!;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.spacingMd),
          child: ExpenseCard(
            name: expense.note.isNotEmpty ? expense.note : expense.category,
            category: expense.category,
            amount: expense.amount,
            time: ExpenseListContent._dayFormatter.format(expense.date),
            currencySymbol: currencySymbol,
            onTap: () => _showExpenseDetail(context, expense),
          ),
        );
      },
    );
  }

  void _showExpenseDetail(
    BuildContext context,
    Expense expense,
  ) {
    final currencySymbol = context.read<AppProvider>().currencySymbol;
    ExpenseDetailDialog.show(
      context,
      name: expense.note.isNotEmpty ? expense.note : expense.category,
      category: CategoryHelper.normalizeLabel(expense.category).toUpperCase(),
      amount: expense.amount,
      currencySymbol: currencySymbol,
      time: ExpenseListContent._timeFormatter.format(expense.date),
      note: expense.note,
      categoryIcon: CategoryIcon.iconForCategory(expense.category),
      iconColor: CategoryIcon.colorForCategory(expense.category),
      onEdit: () => context.push(RouteNames.editExpense, extra: expense),
      onDelete: () => DeleteExpenseDialog.show(
        context,
        onConfirm: () {
          context.read<AppProvider>().deleteExpense(expense.id);
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

  void _handleLoadMore() {
    setState(() {
      _visibleCount += _pageSize;
    });
  }
}

