import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../models/expense_firestore_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final FirebaseFirestore _firestore;
  final String _uid;

  ExpenseRepositoryImpl(this._firestore, this._uid);

  CollectionReference<Map<String, dynamic>> get _expensesRef =>
      _firestore.collection('users').doc(_uid).collection('expenses');

  @override
  Stream<List<Expense>> getExpenses() {
    return _expensesRef
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExpenseFirestoreModel.fromFirestore(doc).toEntity())
            .toList());
  }

  @override
  Future<void> addExpense(Expense expense) async {
    final expenseId =
        expense.id.isEmpty ? _expensesRef.doc().id : expense.id;
    final model =
        ExpenseFirestoreModel.fromEntity(expense.copyWith(id: expenseId));
    await _expensesRef.doc(expenseId).set(model.toFirestore());
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    final model = ExpenseFirestoreModel.fromEntity(expense);
    await _expensesRef.doc(expense.id).update(model.toFirestore());
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _expensesRef.doc(id).delete();
  }

  @override
  Future<void> deleteAllExpenses() async {
    final batch = _firestore.batch();
    final snapshot = await _expensesRef.get();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
