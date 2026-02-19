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
      GoRoute(
        path: RouteNames.getStarted,
        builder: (context, state) => const GetStartedScreen(),
      ),
      GoRoute(
        path: RouteNames.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: RouteNames.expenses,
        builder: (context, state) => const ExpenseListScreen(),
      ),
      GoRoute(
        path: RouteNames.addExpense,
        builder: (context, state) => const AddExpenseScreen(),
      ),
      GoRoute(
        path: RouteNames.editExpense,
        builder: (context, state) => const EditExpenseScreen(),
      ),
      GoRoute(
        path: RouteNames.summary,
        builder: (context, state) => const SummaryScreen(),
      ),
      GoRoute(
        path: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );

  AppRouter._();
}
