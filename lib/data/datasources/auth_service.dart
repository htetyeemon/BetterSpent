import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateStream => _auth.authStateChanges();
  bool get isAnonymous => _auth.currentUser?.isAnonymous ?? true;
  bool get isGoogleUser =>
      _auth.currentUser?.providerData
          .any((p) => p.providerId == 'google.com') ??
      false;

  Future<User?> signInAnonymously() async {
    final result = await _auth.signInAnonymously();
    return result.user;
  }

  Future<User?> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider()
        ..setCustomParameters({'prompt': 'select_account'});
      try {
        final result = await _auth.signInWithPopup(provider);
        return result.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'popup-blocked' ||
            e.code == 'operation-not-supported-in-this-environment') {
          // Initiate redirect flow; the result is handled by getRedirectResult() in main.dart.
          await _auth.signInWithRedirect(provider);
          return null;
        }
        rethrow;
      }
    }

    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign-in cancelled');

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final result = await _auth.signInWithCredential(credential);
    return result.user;
  }

  Future<User?> linkAnonymousWithGoogle() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null || !currentUser.isAnonymous) {
      throw Exception('No anonymous user to link');
    }

    if (kIsWeb) {
      final provider = GoogleAuthProvider()
        ..setCustomParameters({'prompt': 'select_account'});
      try {
        final result = await currentUser.linkWithPopup(provider);
        return result.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'credential-already-in-use' ||
            e.code == 'email-already-in-use') {
          try {
            final result = await _auth.signInWithPopup(provider);
            return result.user;
          } on FirebaseAuthException catch (popupError) {
            if (popupError.code == 'popup-blocked' ||
                popupError.code ==
                    'operation-not-supported-in-this-environment') {
              // Initiate redirect flow; the result is handled by getRedirectResult() in main.dart.
              await _auth.signInWithRedirect(provider);
              return null;
            }
            rethrow;
          }
        }
        if (e.code == 'popup-blocked' ||
            e.code == 'operation-not-supported-in-this-environment') {
          // Initiate redirect flow; the result is handled by getRedirectResult() in main.dart.
          await _auth.signInWithRedirect(provider);
          return null;
        }
        rethrow;
      }
    }

    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign-in cancelled');

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    try {
      // CRITICAL: Use linkWithCredential to preserve UID and Firestore data
      final result = await currentUser.linkWithCredential(credential);
      return result.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use' ||
          e.code == 'email-already-in-use') {
        // Fall back to signInWithCredential if already linked
        final result = await _auth.signInWithCredential(credential);
        return result.user;
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      await GoogleSignIn().signOut();
    }
    await _auth.signOut();
  }
}
