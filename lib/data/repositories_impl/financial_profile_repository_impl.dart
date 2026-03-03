import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/financial_profile.dart';
import '../../domain/repositories/financial_profile_repository.dart';
import '../models/financial_profile_firestore_model.dart';

class FinancialProfileRepositoryImpl implements FinancialProfileRepository {
  final FirebaseFirestore _firestore;
  final String _uid;

  FinancialProfileRepositoryImpl(this._firestore, this._uid);

  DocumentReference<Map<String, dynamic>> get _profileRef =>
      _firestore.collection('users').doc(_uid).collection('data').doc('financial_profile');

  @override
  Stream<FinancialProfile?> getProfile() {
    return _profileRef.snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return FinancialProfileFirestoreModel.fromFirestore(doc).toEntity();
    });
  }

  @override
  Future<void> updateProfile(FinancialProfile profile) async {
    final model = FinancialProfileFirestoreModel.fromEntity(profile);
    await _profileRef.set(model.toFirestore(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteProfile() async {
    await _profileRef.delete();
  }
}
