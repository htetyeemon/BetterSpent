import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateStream => _auth.authStateChanges();
  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? true;
  bool get isEmailUser =>
      _auth.currentUser?.providerData
          .any((p) => p.providerId == 'password') ??
      false;

  Future<void> ensurePersistence() async {
    if (kIsWeb) {
      await _auth.setPersistence(Persistence.LOCAL);
    }
  }

  Future<User?> signInAnonymously() async {
    final result = await _auth.signInAnonymously();
    return result.user;
  }

  Future<User?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  Future<User?> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (displayName != null && displayName.trim().isNotEmpty) {
      await result.user?.updateDisplayName(displayName.trim());
      await result.user?.reload();
    }
    return _auth.currentUser;
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    final normalizedEmail = email.trim().toLowerCase();
    await _auth.sendPasswordResetEmail(email: normalizedEmail);
  }

  Future<User?> linkAnonymousWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null || !currentUser.isAnonymous) {
      throw Exception('No anonymous user to link');
    }
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    try {
      final result = await currentUser.linkWithCredential(credential);
      if (displayName != null && displayName.trim().isNotEmpty) {
        await result.user?.updateDisplayName(displayName.trim());
        await result.user?.reload();
      }
      return _auth.currentUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use' ||
          e.code == 'email-already-in-use') {
        throw FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'Email already in use. Please sign in instead.',
        );
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> deleteCurrentUser() async {
    await _auth.currentUser?.delete();
  }
}
