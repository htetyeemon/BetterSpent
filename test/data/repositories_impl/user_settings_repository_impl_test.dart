import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:better_spent/data/repositories_impl/user_settings_repository_impl.dart';
import 'package:better_spent/domain/entities/user_settings.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  const uid = 'user-123';

  UserSettingsRepositoryImpl buildRepo() =>
      UserSettingsRepositoryImpl(firestore, uid);

  CollectionReference<Map<String, dynamic>> dataRef() {
    return firestore.collection('users').doc(uid).collection('data');
  }

  DocumentReference<Map<String, dynamic>> settingsDoc() {
    return dataRef().doc('settings');
  }

  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  test('getSettings returns null when document missing', () async {
    final repo = buildRepo();
    final result = await repo.getSettings().first;

    expect(result, isNull);
  });

  test('getSettings maps document to entity', () async {
    await settingsDoc().set({
      'currency': 'USD',
      'aiInputEnabled': false,
      'budgetWarningEnabled': true,
      'motivationalMessageEnabled': false,
    });

    final repo = buildRepo();
    final result = await repo.getSettings().first;

    expect(result, isNotNull);
    expect(result!.currency, 'USD');
    expect(result.aiInputEnabled, isFalse);
    expect(result.motivationalMessageEnabled, isFalse);
  });

  test('updateSettings writes with merge true', () async {
    final repo = buildRepo();
    final settings = UserSettings(
      currency: 'EUR',
      aiInputEnabled: true,
      budgetWarningEnabled: false,
      motivationalMessageEnabled: true,
    );

    await repo.updateSettings(settings);

    final snapshot = await settingsDoc().get();
    expect(snapshot.exists, isTrue);
    expect(snapshot.data()!['currency'], 'EUR');
  });

  test('deleteSettings deletes document', () async {
    await settingsDoc().set({
      'currency': 'THB',
      'aiInputEnabled': true,
      'budgetWarningEnabled': true,
      'motivationalMessageEnabled': true,
    });

    final repo = buildRepo();
    await repo.deleteSettings();

    final snapshot = await settingsDoc().get();
    expect(snapshot.exists, isFalse);
  });
}
