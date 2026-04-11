import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:better_spent/data/repositories_impl/financial_profile_repository_impl.dart';
import 'package:better_spent/domain/entities/financial_profile.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  const uid = 'user-123';

  FinancialProfileRepositoryImpl buildRepo() =>
      FinancialProfileRepositoryImpl(firestore, uid);

  CollectionReference<Map<String, dynamic>> _dataRef() {
    return firestore.collection('users').doc(uid).collection('data');
  }

  DocumentReference<Map<String, dynamic>> _profileDoc() {
    return _dataRef().doc('financial_profile');
  }

  setUp(() {
    firestore = FakeFirebaseFirestore();
  });

  test('getProfile returns null when document missing', () async {
    final repo = buildRepo();
    final result = await repo.getProfile().first;

    expect(result, isNull);
  });

  test('getProfile maps document to entity when present', () async {
    await _profileDoc().set({
      'income': 1200,
      'monthlyBudget': 800,
      'incomeUpdatedAt': '2026-04-01T10:00:00.000',
    });

    final repo = buildRepo();
    final result = await repo.getProfile().first;

    expect(result, isNotNull);
    expect(result!.income, 1200);
    expect(result.monthlyBudget, 800);
  });

  test('updateProfile writes with merge true', () async {
    final repo = buildRepo();
    final profile = FinancialProfile(
      income: 1000,
      monthlyBudget: 700,
      incomeUpdatedAt: DateTime(2026, 4, 1),
    );

    await repo.updateProfile(profile);

    final snapshot = await _profileDoc().get();
    expect(snapshot.exists, isTrue);
    expect(snapshot.data()!['income'], 1000);
    expect(snapshot.data()!['monthlyBudget'], 700);
  });

  test('deleteProfile deletes document', () async {
    await _profileDoc().set({
      'income': 1000,
      'monthlyBudget': 700,
    });

    final repo = buildRepo();
    await repo.deleteProfile();

    final snapshot = await _profileDoc().get();
    expect(snapshot.exists, isFalse);
  });
}
