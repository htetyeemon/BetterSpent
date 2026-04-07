import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:better_spent/core/router/route_names.dart';
import 'package:better_spent/core/utils/bottom_nav_helper.dart';

class NavActionScreen extends StatelessWidget {
  final int targetIndex;
  final int currentIndex;

  const NavActionScreen({
    super.key,
    required this.targetIndex,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => handleBottomNavTap(context, targetIndex, currentIndex),
          child: const Text('Go'),
        ),
      ),
    );
  }
}

GoRouter buildRouter({
  required ValueNotifier<String> location,
  required int targetIndex,
  required int currentIndex,
}) {
  Widget builder(String path) {
    location.value = path;
    return NavActionScreen(targetIndex: targetIndex, currentIndex: currentIndex);
  }

  return GoRouter(
    initialLocation: RouteNames.home,
    routes: [
      GoRoute(path: RouteNames.home, builder: (_, __) => builder(RouteNames.home)),
      GoRoute(path: RouteNames.expenses, builder: (_, __) => builder(RouteNames.expenses)),
      GoRoute(path: RouteNames.summary, builder: (_, __) => builder(RouteNames.summary)),
      GoRoute(path: RouteNames.settings, builder: (_, __) => builder(RouteNames.settings)),
    ],
  );
}

void main() {
  testWidgets('handleBottomNavTap navigates to selected index', (tester) async {
    final location = ValueNotifier<String>(RouteNames.home);
    final router = buildRouter(
      location: location,
      targetIndex: 1,
      currentIndex: 0,
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();

    expect(location.value, RouteNames.expenses);
  });

  testWidgets('handleBottomNavTap ignores tap on current index', (tester) async {
    final location = ValueNotifier<String>(RouteNames.home);
    final router = buildRouter(
      location: location,
      targetIndex: 0,
      currentIndex: 0,
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();

    expect(location.value, RouteNames.home);
  });
}
