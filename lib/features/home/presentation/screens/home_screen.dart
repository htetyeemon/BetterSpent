import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/bottom_navigation.dart';
import '../../../../core/router/route_names.dart';
import '../widgets/message_card.dart';
import '../widgets/expense_input_card.dart';
import '../widgets/home_header.dart';
import '../widgets/home_stats_card.dart';
import '../widgets/daily_streak_card_inline.dart';
import '../widgets/todays_spending_section.dart';
import '../../../../models/mock_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  bool _isOnline = true;
  double _income = MockData.mockIncome;
  String _incomeDate = '1-05-2026';
  final String _currencySymbol = '\$';
  double _monthlyBudget = 2500.00;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ✅ Properly wrapped bottom nav
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentNavIndex,
        onTap: (index) {
          setState(() => _currentNavIndex = index);
          _navigateToScreen(index);
        },
      ),

      body: SafeArea(
        child: Column(
          children: [
            // Header
            HomeHeader(
              isOnline: _isOnline,
              onToggle: () => setState(() => _isOnline = !_isOnline),
            ),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeStatsCard(
                      currencySymbol: _currencySymbol,
                      income: _income,
                      incomeDate: _incomeDate,
                      onIncomeSaved: (amount, date) {
                        setState(() {
                          _income = amount;
                          _incomeDate = date;
                        });
                      },
                      monthlyBudget: _monthlyBudget,
                      onBudgetSaved: (amount) {
                        setState(() {
                          _monthlyBudget = amount;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    MessageCard(
                      message: MockData.getRandomMotivationalMessage(),
                    ),
                    const SizedBox(height: 20),

                    ExpenseInputCard(
                      isOnline: _isOnline,
                      onAddExpenseManually: () {
                        context.go(RouteNames.addExpense);
                      },
                    ),
                    const SizedBox(height: 20),

                    const DailyStreakCardInline(),
                    const SizedBox(height: 20),

                    TodaysSpendingSection(isOnline: _isOnline),

                    // Smaller padding (Scaffold handles nav space now)
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToScreen(int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        context.go(RouteNames.expenses);
        break;
      case 2:
        context.go(RouteNames.summary);
        break;
      case 3:
        context.go(RouteNames.settings);
        break;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final uri = GoRouterState.of(context).uri;
    final added = uri.queryParameters['added'];

    if (added == 'true') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.green, size: 22),
                SizedBox(width: 12),
                Text(
                  'Expense added',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: AppColors.surfaceLight,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      });
    }
  }
}
