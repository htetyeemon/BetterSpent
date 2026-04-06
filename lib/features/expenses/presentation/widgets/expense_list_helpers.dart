import 'package:intl/intl.dart';
import '../../../../domain/entities/expense.dart';
import 'expense_list_entry.dart';

List<Expense> filterExpenses(
  List<Expense> expenses,
  String filter,
) {
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

Map<String, List<Expense>> groupByDate(
  List<Expense> expenses,
  DateFormat dayFormatter,
) {
  final Map<String, List<Expense>> groups = {};
  for (final expense in expenses) {
    final key = dayFormatter.format(expense.date);
    groups.putIfAbsent(key, () => []).add(expense);
  }
  return groups;
}

List<ExpenseListEntry> buildEntries(
  Map<String, List<Expense>> grouped,
  List<String> dateKeys, {
  required bool hasMore,
}) {
  final entries = <ExpenseListEntry>[];
  for (final dateKey in dateKeys) {
    entries.add(
      ExpenseListEntry.header(dateKey.toUpperCase()),
    );
    final dayExpenses = grouped[dateKey] ?? const [];
    for (final expense in dayExpenses) {
      entries.add(ExpenseListEntry.expense(expense));
    }
    entries.add(ExpenseListEntry.sectionSpacer());
  }
  if (hasMore) {
    entries.add(ExpenseListEntry.loadMore());
  }
  return entries;
}
