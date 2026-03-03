import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/expense.dart';

class ExpenseFirestoreModel {
  final String id;
  final double amount;
  final String category;
  final Timestamp date;
  final String note;

  const ExpenseFirestoreModel({
    required this.id,
    required this.amount,
    required this.category,
    required this.date,
    required this.note,
  });

  factory ExpenseFirestoreModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return ExpenseFirestoreModel(
      id: doc.id,
      amount: (data['amount'] as num).toDouble(),
      category: data['category'] as String,
      date: data['date'] as Timestamp,
      note: (data['note'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'category': category,
      'date': date,
      'note': note,
    };
  }

  factory ExpenseFirestoreModel.fromEntity(Expense expense) {
    return ExpenseFirestoreModel(
      id: expense.id,
      amount: expense.amount,
      category: expense.category,
      date: Timestamp.fromDate(expense.date),
      note: expense.note,
    );
  }

  Expense toEntity() {
    return Expense(
      id: id,
      amount: amount,
      category: category,
      date: date.toDate(),
      note: note,
    );
  }
}
