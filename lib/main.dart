import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/router/route_names.dart';
import 'features/home/screens/home_screen.dart';
import 'features/expenses/screens/expense_list_screen.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  initialLocation: RouteNames.home.path,
  routes: <GoRoute>[
    GoRoute(
      path: RouteNames.home.path,
      builder: (BuildContext context, GoRouterState state) =>
          const HomeScreen(),
    ),
    GoRoute(
      path: RouteNames.expenses.path,
      builder: (BuildContext context, GoRouterState state) =>
          const ExpenseListScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'BetterSpent (Demo)',
      routerConfig: _router,
      theme: ThemeData(useMaterial3: true),
    );
  }
}
