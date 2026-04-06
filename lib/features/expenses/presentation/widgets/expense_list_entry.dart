import '../../../../domain/entities/expense.dart';

enum ExpenseListEntryType { header, expense, sectionSpacer, loadMore }

class ExpenseListEntry {
  final ExpenseListEntryType type;
  final String? header;
  final Expense? expense;

  const ExpenseListEntry._(this.type, {this.header, this.expense});

  factory ExpenseListEntry.header(String header) =>
      ExpenseListEntry._(ExpenseListEntryType.header, header: header);

  factory ExpenseListEntry.expense(Expense expense) =>
      ExpenseListEntry._(ExpenseListEntryType.expense, expense: expense);

  factory ExpenseListEntry.sectionSpacer() =>
      const ExpenseListEntry._(ExpenseListEntryType.sectionSpacer);

  factory ExpenseListEntry.loadMore() =>
      const ExpenseListEntry._(ExpenseListEntryType.loadMore);
}
