import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AppLaunchService {
  static const String _boxName = 'app_launch_box';
  static const String _seenAnonymousUidKey = 'seen_anonymous_uid';
  static const String _pendingSeenAnonymousKey = 'pending_seen_anonymous';
  static bool _shouldShowGetStarted = false;
  static Box<dynamic>? _box;

  static bool get shouldShowGetStarted => _shouldShowGetStarted;

  static Future<void> initialize() async {
    try {
      _box ??= await Hive.openBox<dynamic>(_boxName);
      _refreshOnboardingState(FirebaseAuth.instance.currentUser);
    } catch (e, st) {
      debugPrint('AppLaunchService.initialize failed: $e');
      debugPrintStack(stackTrace: st);
      _shouldShowGetStarted = false;
    }
  }

  static Future<void> refreshForCurrentUser() async {
    _box ??= await Hive.openBox<dynamic>(_boxName);
    _refreshOnboardingState(FirebaseAuth.instance.currentUser);
  }

  static void _refreshOnboardingState(User? user) {
    if (user == null) {
      // A new anonymous session will be created shortly.
      _shouldShowGetStarted = true;
      return;
    }

    if (!user.isAnonymous) {
      _shouldShowGetStarted = false;
      return;
    }

    final seenAnonymousUid = _box?.get(_seenAnonymousUidKey) as String?;
    final pendingSeenAnonymous =
        _box?.get(_pendingSeenAnonymousKey) as bool? ?? false;

    if (pendingSeenAnonymous && seenAnonymousUid != user.uid) {
      _box?.put(_seenAnonymousUidKey, user.uid);
      _box?.put(_pendingSeenAnonymousKey, false);
      _shouldShowGetStarted = false;
      return;
    }

    _shouldShowGetStarted = seenAnonymousUid != user.uid;
  }

  static Future<void> markGetStartedSeen() async {
    _box ??= await Hive.openBox<dynamic>(_boxName);
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid != null) {
      await _box!.put(_seenAnonymousUidKey, currentUid);
      await _box!.put(_pendingSeenAnonymousKey, false);
    } else {
      await _box!.put(_pendingSeenAnonymousKey, true);
    }
    _shouldShowGetStarted = false;
  }
}
