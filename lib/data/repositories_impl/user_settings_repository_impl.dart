import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/user_settings_repository.dart';
import '../models/user_settings_firestore_model.dart';

class UserSettingsRepositoryImpl implements UserSettingsRepository {
  final FirebaseFirestore _firestore;
  final String _uid;

  UserSettingsRepositoryImpl(this._firestore, this._uid);

  DocumentReference<Map<String, dynamic>> get _settingsRef =>
      _firestore.collection('users').doc(_uid).collection('data').doc('settings');

  @override
  Stream<UserSettings?> getSettings() {
    return _settingsRef.snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return UserSettingsFirestoreModel.fromFirestore(doc).toEntity();
    });
  }

  @override
  Future<void> updateSettings(UserSettings settings) async {
    final model = UserSettingsFirestoreModel.fromEntity(settings);
    await _settingsRef.set(model.toFirestore(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteSettings() async {
    await _settingsRef.delete();
  }
}
