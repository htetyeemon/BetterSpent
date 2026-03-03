import '../entities/user_settings.dart';

abstract class UserSettingsRepository {
  Stream<UserSettings?> getSettings();
  Future<void> updateSettings(UserSettings settings);
  Future<void> deleteSettings();
}
