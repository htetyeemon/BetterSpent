import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';

import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/expenses/presentation/screens/expense_list_screen.dart';
import '../../features/expenses/presentation/screens/add_expense_screen.dart';
import '../../features/expenses/presentation/screens/edit_expense_screen.dart';
import '../../features/summary/presentation/screens/summary_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/onboarding/presentation/screens/get_started_screen.dart';

class AppRouter {
  static final GoRouter appRouter = GoRouter(
    initialLocation: RouteNames.getStarted,
    routes: [
      _noTransitionRoute(
        path: RouteNames.getStarted,
        child: const GetStartedScreen(),
      ),
      _noTransitionRoute(path: RouteNames.home, child: const HomeScreen()),
      _noTransitionRoute(
        path: RouteNames.expenses,
        child: const ExpenseListScreen(),
      ),
      _noTransitionRoute(
        path: RouteNames.addExpense,
        child: const AddExpenseScreen(),
      ),
      _noTransitionRoute(
        path: RouteNames.editExpense,
        child: const EditExpenseScreen(),
      ),
      _noTransitionRoute(
        path: RouteNames.summary,
        child: const SummaryScreen(),
      ),
      _noTransitionRoute(
        path: RouteNames.settings,
        child: const SettingsScreen(),
      ),
    ],
  );

  static GoRoute _noTransitionRoute({
    required String path,
    required Widget child,
  }) {
    return GoRoute(
      path: path,
      pageBuilder: (context, state) => NoTransitionPage<void>(
        key: state.pageKey,
        child: child,
      ),
    );
  }

  AppRouter._();
}
