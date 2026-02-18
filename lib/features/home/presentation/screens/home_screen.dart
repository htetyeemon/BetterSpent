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
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  bool _isOnline = true;
  double _income = MockData.mockIncome;
  String _incomeDate = '1-05-2026';
  String _currencySymbol = '\$';
  double _monthlyBudget = 2500.00;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Logo and Online Toggle
            HomeHeader(
              isOnline: _isOnline,
              onToggle: () => setState(() => _isOnline = !_isOnline),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Card - Combined Balance, Income, Max Spend
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

                    // Message Card
                    MessageCard(
                      message: MockData.getRandomMotivationalMessage(),
                    ),
                    const SizedBox(height: 20),

                    // Expense Input Card
                    ExpenseInputCard(
                      isOnline: _isOnline,
                      onAddExpenseManually: () {
                        context.go(RouteNames.addExpense);
                      },
                    ),
                    const SizedBox(height: 20),

                    // Daily Streak Card
                    const DailyStreakCardInline(),
                    const SizedBox(height: 20),

                    // Today's Spending Section
                    TodaysSpendingSection(isOnline: _isOnline),
                    const SizedBox(height: 96), // Bottom padding for nav
                  ],
                ),
              ),
            ),

            // Bottom Navigation
            BottomNavigation(
              currentIndex: _currentNavIndex,
              onTap: (index) {
                setState(() => _currentNavIndex = index);
                _navigateToScreen(index);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToScreen(int index) {
    switch (index) {
      case 0:
        // Already on home
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
}
