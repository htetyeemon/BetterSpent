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
  List<_ExpenseListEntry> _cachedEntries = const [];
  int _visibleCount = _pageSize;

  List<Expense> _filterExpenses(List<Expense> expenses, String filter) {
    final now = DateTime.now();
    switch (filter) {
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
      final key = ExpenseListContent._dayFormatter.format(expense.date);
      groups.putIfAbsent(key, () => []).add(expense);
    }
    return groups;
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
    _cachedEntries = _buildEntries(
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
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
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
        if (entry.type == _ExpenseListEntryType.header) {
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
        if (entry.type == _ExpenseListEntryType.sectionSpacer) {
          return const SizedBox(height: AppConstants.spacingLg);
        }
        if (entry.type == _ExpenseListEntryType.loadMore) {
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
                child: const Text('Load more'),
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

  List<_ExpenseListEntry> _buildEntries(
    Map<String, List<Expense>> grouped,
    List<String> dateKeys, {
    required bool hasMore,
  }) {
    final entries = <_ExpenseListEntry>[];
    for (final dateKey in dateKeys) {
      entries.add(
        _ExpenseListEntry.header(dateKey.toUpperCase()),
      );
      final dayExpenses = grouped[dateKey] ?? const [];
      for (final expense in dayExpenses) {
        entries.add(_ExpenseListEntry.expense(expense));
      }
      entries.add(_ExpenseListEntry.sectionSpacer());
    }
    if (hasMore) {
      entries.add(_ExpenseListEntry.loadMore());
    }
    return entries;
  }

  void _handleLoadMore() {
    setState(() {
      _visibleCount += _pageSize;
    });
  }
}

enum _ExpenseListEntryType { header, expense, sectionSpacer, loadMore }

class _ExpenseListEntry {
  final _ExpenseListEntryType type;
  final String? header;
  final Expense? expense;

  const _ExpenseListEntry._(this.type, {this.header, this.expense});

  factory _ExpenseListEntry.header(String header) =>
      _ExpenseListEntry._(_ExpenseListEntryType.header, header: header);

  factory _ExpenseListEntry.expense(Expense expense) =>
      _ExpenseListEntry._(_ExpenseListEntryType.expense, expense: expense);

  factory _ExpenseListEntry.sectionSpacer() =>
      const _ExpenseListEntry._(_ExpenseListEntryType.sectionSpacer);

  factory _ExpenseListEntry.loadMore() =>
      const _ExpenseListEntry._(_ExpenseListEntryType.loadMore);
}
