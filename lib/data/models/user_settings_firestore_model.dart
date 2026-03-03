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
    final data = doc.data()!;
    return UserSettingsFirestoreModel(
      currency: (data['currency'] as String?) ?? 'USD',
      aiInputEnabled: (data['aiInputEnabled'] as bool?) ?? true,
      budgetWarningEnabled: (data['budgetWarningEnabled'] as bool?) ?? true,
      motivationalMessageEnabled:
          (data['motivationalMessageEnabled'] as bool?) ?? false,
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
