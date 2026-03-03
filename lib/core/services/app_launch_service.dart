import 'package:hive/hive.dart';

class AppLaunchService {
  static const String _boxName = 'app_launch_box';
  static const String _seenGetStartedKey = 'seen_get_started';
  static bool _hasSeenGetStarted = true;
  static Box<dynamic>? _box;

  static bool get hasSeenGetStarted => _hasSeenGetStarted;

  static Future<void> initialize() async {
    try {
      _box ??= await Hive.openBox<dynamic>(_boxName);
      _hasSeenGetStarted = _box?.get(_seenGetStartedKey) as bool? ?? true;
    } catch (_) {
      _hasSeenGetStarted = true;
    }
  }

  static Future<void> markGetStartedSeen() async {
    _hasSeenGetStarted = true;
    _box ??= await Hive.openBox<dynamic>(_boxName);
    await _box!.put(_seenGetStartedKey, true);
  }
}
