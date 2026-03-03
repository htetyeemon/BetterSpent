import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/financial_profile.dart';

class FinancialProfileFirestoreModel {
  final double income;
  final double monthlyBudget;

  const FinancialProfileFirestoreModel({
    required this.income,
    required this.monthlyBudget,
  });

  factory FinancialProfileFirestoreModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return FinancialProfileFirestoreModel(
      income: (data['income'] as num).toDouble(),
      monthlyBudget: (data['monthlyBudget'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'income': income,
      'monthlyBudget': monthlyBudget,
    };
  }

  factory FinancialProfileFirestoreModel.fromEntity(FinancialProfile profile) {
    return FinancialProfileFirestoreModel(
      income: profile.income,
      monthlyBudget: profile.monthlyBudget,
    );
  }

  FinancialProfile toEntity() {
    return FinancialProfile(income: income, monthlyBudget: monthlyBudget);
  }
}
