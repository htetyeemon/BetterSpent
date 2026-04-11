import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:better_spent/data/repositories_impl/expense_repository_impl.dart';
import 'package:better_spent/domain/entities/expense.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  const uid = 'user-123';

  ExpenseRepositoryImpl buildRepo() => ExpenseRepositoryImpl(firestore, uid);

  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  Future<CollectionReference<Map<String, dynamic>>> _expensesRef() async {
    return firestore.collection('users').doc(uid).collection('expenses');
  }

  test('getExpenses maps firestore docs to entities', () async {
    final ref = await _expensesRef();
    await ref.add({
      'amount': 12.5,
      'category': 'food and drink',
      'date': Timestamp.fromDate(DateTime(2026, 4, 1)),
      'note': 'Lunch',
    });

    final repo = buildRepo();
    final result = await repo.getExpenses().first;

    expect(result.length, 1);
    expect(result.first.category, 'Food & Drink');
    expect(result.first.amount, 12.5);
  });

  test('addExpense generates id when empty and saves document', () async {
    final repo = buildRepo();
    final expense = Expense(
      id: '',
      amount: 20,
      category: 'Food',
      date: DateTime(2026, 4, 1),
      note: 'Dinner',
    );

    await repo.addExpense(expense);

    final snapshot = await (await _expensesRef()).get();
    expect(snapshot.docs.length, 1);
    expect(snapshot.docs.first.data()['amount'], 20);
  });

  test('updateExpense updates existing document', () async {
    final ref = await _expensesRef();
    final doc = await ref.add({
      'amount': 10,
      'category': 'Transport',
      'date': Timestamp.fromDate(DateTime(2026, 4, 2)),
      'note': 'Taxi',
    });

    final repo = buildRepo();
    final expense = Expense(
      id: doc.id,
      amount: 25,
      category: 'Transport',
      date: DateTime(2026, 4, 2),
      note: 'Taxi',
    );

    await repo.updateExpense(expense);

    final updated = await doc.get();
    expect(updated.data()!['amount'], 25);
  });

  test('deleteExpense deletes document', () async {
    final ref = await _expensesRef();
    final doc = await ref.add({
      'amount': 10,
      'category': 'Transport',
      'date': Timestamp.fromDate(DateTime(2026, 4, 2)),
      'note': 'Taxi',
    });

    final repo = buildRepo();
    await repo.deleteExpense(doc.id);

    final snapshot = await ref.get();
    expect(snapshot.docs, isEmpty);
  });

  test('deleteAllExpenses deletes all docs', () async {
    final ref = await _expensesRef();
    await ref.add({
      'amount': 5,
      'category': 'Food',
      'date': Timestamp.fromDate(DateTime(2026, 4, 2)),
      'note': 'Snack',
    });
    await ref.add({
      'amount': 15,
      'category': 'Bills',
      'date': Timestamp.fromDate(DateTime(2026, 4, 2)),
      'note': 'Internet',
    });

    final repo = buildRepo();
    await repo.deleteAllExpenses();

    final snapshot = await ref.get();
    expect(snapshot.docs, isEmpty);
  });
}
