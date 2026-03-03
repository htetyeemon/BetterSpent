import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/financial_profile.dart';

class FinancialProfileFirestoreModel {
  final double income;
  final double monthlyBudget;
  final DateTime? incomeUpdatedAt;

  const FinancialProfileFirestoreModel({
    required this.income,
    required this.monthlyBudget,
    this.incomeUpdatedAt,
  });

  factory FinancialProfileFirestoreModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return FinancialProfileFirestoreModel(
      income: (data['income'] as num?)?.toDouble() ?? 0.0,
      monthlyBudget: (data['monthlyBudget'] as num?)?.toDouble() ?? 0.0,
      incomeUpdatedAt: _parseDateTime(data['incomeUpdatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'income': income,
      'monthlyBudget': monthlyBudget,
      'incomeUpdatedAt': incomeUpdatedAt?.toIso8601String(),
    };
  }

  factory FinancialProfileFirestoreModel.fromEntity(FinancialProfile profile) {
    return FinancialProfileFirestoreModel(
      income: profile.income,
      monthlyBudget: profile.monthlyBudget,
      incomeUpdatedAt: profile.incomeUpdatedAt,
    );
  }

  FinancialProfile toEntity() {
    return FinancialProfile(
      income: income,
      monthlyBudget: monthlyBudget,
      incomeUpdatedAt: incomeUpdatedAt,
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
