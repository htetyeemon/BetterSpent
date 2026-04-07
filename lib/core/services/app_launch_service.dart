import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AppLaunchService {
  static const String _boxName = 'app_launch_box';
  static const String _seenAnonymousUidKey = 'seen_anonymous_uid';
  static const String _pendingSeenAnonymousKey = 'pending_seen_anonymous';
  static bool _shouldShowGetStarted = false;
  static Box<dynamic>? _box;
  static final ValueNotifier<int> _refreshSignal = ValueNotifier<int>(0);
  static User? _testUserOverride;
  static bool _disableFirebaseForTest = false;

  static bool get shouldShowGetStarted => _shouldShowGetStarted;
  static ValueListenable<int> get refreshListenable => _refreshSignal;

  static void _notifyRefresh() {
    _refreshSignal.value++;
  }

  static User? _currentUser() {
    if (_disableFirebaseForTest) return _testUserOverride;
    return _testUserOverride ?? FirebaseAuth.instance.currentUser;
  }

  @visibleForTesting
  static void setTestUser(User? user, {bool disableFirebase = false}) {
    _testUserOverride = user;
    _disableFirebaseForTest = disableFirebase;
  }

  @visibleForTesting
  static void resetForTest() {
    _box = null;
    _testUserOverride = null;
    _disableFirebaseForTest = false;
    _shouldShowGetStarted = false;
    _refreshSignal.value = 0;
  }

  static Future<void> initialize() async {
    try {
      _box ??= await Hive.openBox<dynamic>(_boxName);
      _refreshOnboardingState(_currentUser());
      _notifyRefresh();
    } catch (e, st) {
      debugPrint('AppLaunchService.initialize failed: $e');
      debugPrintStack(stackTrace: st);
      _shouldShowGetStarted = false;
      _notifyRefresh();
    }
  }

  static Future<void> refreshForCurrentUser() async {
    _box ??= await Hive.openBox<dynamic>(_boxName);
    _refreshOnboardingState(_currentUser());
    _notifyRefresh();
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
    final currentUid = _currentUser()?.uid;
    if (currentUid != null) {
      await _box!.put(_seenAnonymousUidKey, currentUid);
      await _box!.put(_pendingSeenAnonymousKey, false);
    } else {
      await _box!.put(_pendingSeenAnonymousKey, true);
    }
    _shouldShowGetStarted = false;
    _notifyRefresh();
  }
}
