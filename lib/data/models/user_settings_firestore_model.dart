import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_settings.dart';

class UserSettingsFirestoreModel {
  final String currency;
  final bool aiInputEnabled;
  final bool budgetWarningEnabled;
  final bool motivationalMessageEnabled;

  const UserSettingsFirestoreModel({
    required this.currency,
    required this.aiInputEnabled,
    required this.budgetWarningEnabled,
    required this.motivationalMessageEnabled,
  });

  factory UserSettingsFirestoreModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final firestoreData = doc.data()!;
    return UserSettingsFirestoreModel(
      currency: (firestoreData['currency'] as String?) ?? 'THB',
      aiInputEnabled: (firestoreData['aiInputEnabled'] as bool?) ?? true,
      budgetWarningEnabled: (firestoreData['budgetWarningEnabled'] as bool?) ?? true,
      motivationalMessageEnabled:
          (firestoreData['motivationalMessageEnabled'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'currency': currency,
      'aiInputEnabled': aiInputEnabled,
      'budgetWarningEnabled': budgetWarningEnabled,
      'motivationalMessageEnabled': motivationalMessageEnabled,
    };
  }

  factory UserSettingsFirestoreModel.fromEntity(UserSettings settings) {
    return UserSettingsFirestoreModel(
      currency: settings.currency,
      aiInputEnabled: settings.aiInputEnabled,
      budgetWarningEnabled: settings.budgetWarningEnabled,
      motivationalMessageEnabled: settings.motivationalMessageEnabled,
    );
  }

  UserSettings toEntity() {
    return UserSettings(
      currency: currency,
      aiInputEnabled: aiInputEnabled,
      budgetWarningEnabled: budgetWarningEnabled,
      motivationalMessageEnabled: motivationalMessageEnabled,
    );
  }
}
