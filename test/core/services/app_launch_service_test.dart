import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:better_spent/core/services/app_launch_service.dart';

class MockUser extends Mock implements User {}

void main() {
  late Directory tempDir;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('app_launch_service_test_');
    Hive.init(tempDir.path);
    AppLaunchService.resetForTest();

    if (Hive.isBoxOpen('app_launch_box')) {
      await Hive.box('app_launch_box').close();
    }
    if (Hive.isBoxOpen('app_state_box')) {
      await Hive.box('app_state_box').close();
    }
  });

  tearDown(() async {
    if (Hive.isBoxOpen('app_launch_box')) {
      final box = Hive.box('app_launch_box');
      await box.clear();
      await box.close();
    }
    if (Hive.isBoxOpen('app_state_box')) {
      final box = Hive.box('app_state_box');
      await box.clear();
      await box.close();
    }
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('shows get started for new anonymous user', () async {
    final user = MockUser();
    when(() => user.isAnonymous).thenReturn(true);
    when(() => user.uid).thenReturn('anon-1');
    AppLaunchService.setTestUser(user, disableFirebase: true);

    await AppLaunchService.initialize();

    expect(AppLaunchService.shouldShowGetStarted, isTrue);
  });

  test('does not show get started for signed-in user', () async {
    final user = MockUser();
    when(() => user.isAnonymous).thenReturn(false);
    when(() => user.uid).thenReturn('user-1');
    AppLaunchService.setTestUser(user, disableFirebase: true);

    await AppLaunchService.initialize();

    expect(AppLaunchService.shouldShowGetStarted, isFalse);
  });

  test('markGetStartedSeen saves anonymous uid and hides onboarding', () async {
    final user = MockUser();
    when(() => user.isAnonymous).thenReturn(true);
    when(() => user.uid).thenReturn('anon-1');
    AppLaunchService.setTestUser(user, disableFirebase: true);

    await AppLaunchService.initialize();
    await AppLaunchService.markGetStartedSeen();

    expect(AppLaunchService.shouldShowGetStarted, isFalse);
    final box = Hive.box('app_launch_box');
    expect(box.get('seen_anonymous_uid'), 'anon-1');
    expect(box.get('pending_seen_anonymous'), isFalse);
  });

  test('same anonymous user does not re-show onboarding', () async {
    final user = MockUser();
    when(() => user.isAnonymous).thenReturn(true);
    when(() => user.uid).thenReturn('anon-1');
    AppLaunchService.setTestUser(user, disableFirebase: true);

    await AppLaunchService.initialize();
    await AppLaunchService.markGetStartedSeen();
    await AppLaunchService.refreshForCurrentUser();

    expect(AppLaunchService.shouldShowGetStarted, isFalse);
  });

  test('pending anonymous flag resolves when user appears', () async {
    AppLaunchService.setTestUser(null, disableFirebase: true);
    await AppLaunchService.initialize();
    await AppLaunchService.markGetStartedSeen();

    final user = MockUser();
    when(() => user.isAnonymous).thenReturn(true);
    when(() => user.uid).thenReturn('anon-2');
    AppLaunchService.setTestUser(user, disableFirebase: true);

    await AppLaunchService.refreshForCurrentUser();

    expect(AppLaunchService.shouldShowGetStarted, isFalse);
    final box = Hive.box('app_launch_box');
    expect(box.get('seen_anonymous_uid'), 'anon-2');
    expect(box.get('pending_seen_anonymous'), isFalse);
  });

  test(
    'does not show get started when no user exists but cached uid exists',
    () async {
      AppLaunchService.setTestUser(null, disableFirebase: true);
      final appStateBox = await Hive.openBox('app_state_box');
      await appStateBox.put('last_known_uid', 'cached-user-1');

      await AppLaunchService.initialize();

      expect(AppLaunchService.shouldShowGetStarted, isFalse);
    },
  );
}
