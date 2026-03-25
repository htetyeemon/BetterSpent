part of 'app_provider.dart';

void _disposeImpl(AppProvider self) {
  self._expenseSub?.cancel();
  self._profileSub?.cancel();
  self._settingsSub?.cancel();
  self._connectivitySub?.cancel();
}
