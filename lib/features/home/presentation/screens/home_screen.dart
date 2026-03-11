import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/bottom_navigation.dart';
import '../../../../core/router/route_names.dart';
import '../widgets/message_card.dart';
import '../widgets/expense_input_card.dart';
import '../widgets/home_header.dart';
import '../widgets/home_stats_card.dart';
import '../widgets/daily_streak_card_inline.dart';
import '../widgets/todays_spending_section.dart';
import '../../../../presentation/providers/app_provider.dart';
import '../../../../core/widgets/success_snackbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  bool _hasShownRouteMessage = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hasShownRouteMessage) return;

    final extra = GoRouterState.of(context).extra;
    final message = extra is String ? extra : null;
    if (message == null || message.isEmpty) return;

    _hasShownRouteMessage = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showSuccessSnackBar(context, message);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();

    if (!provider.isInitialized) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final currencySymbol = provider.currencySymbol;
    final income = provider.profile.income;
    final monthlyBudget = provider.profile.monthlyBudget;
    final isOnline = provider.isOnline;

    return Scaffold(
      backgroundColor: AppColors.background,
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
            HomeHeader(
              isOnline: isOnline,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spacingLg,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeStatsCard(
                      currencySymbol: currencySymbol,
                      income: income,
                      onIncomeSaved: (amount) {
                        provider.updateProfile(
                          provider.profile.copyWith(
                            income: amount,
                            incomeUpdatedAt: DateTime.now(),
                          ),
                        );
                      },
                      monthlyBudget: monthlyBudget,
                      onBudgetSaved: (amount) {
                        provider.updateProfile(
                          provider.profile.copyWith(monthlyBudget: amount),
                        );
                      },
                    ),
                    const SizedBox(height: AppConstants.spacingLg),
                    _buildMessageCard(provider),
                    const SizedBox(height: AppConstants.spacingLg),
                    ExpenseInputCard(
                      isOnline: isOnline,
                      aiInputEnabled: provider.settings.aiInputEnabled,
                      onAddExpenseManually: () {
                        context.go(RouteNames.addExpense);
                      },
                    ),
                    const SizedBox(height: AppConstants.spacingLg),
                    DailyStreakCardInline(streak: provider.dailyStreak),
                    const SizedBox(height: AppConstants.spacingLg),
                    TodaysSpendingSection(isOnline: isOnline),
                    const SizedBox(height: AppConstants.spacingLg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard(AppProvider provider) {
    final notification = _NotificationHelper(provider).getNotification();
    if (notification.isEmpty) return const SizedBox.shrink();
    if (provider.dismissedNotification == notification) {
      return const SizedBox.shrink();
    }
    final isWarning = notification.contains('⚠️');
    return MessageCard(
      message: notification,
      isWarning: isWarning,
      icon: isWarning ? Icons.warning_amber_rounded : Icons.lightbulb_outline,
      onClose: () {
        provider.dismissNotification(notification);
      },
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

}

class _NotificationHelper {
  final AppProvider provider;
  _NotificationHelper(this.provider);

  String getNotification() {
    final settings = provider.settings;
    final profile = provider.profile;
    final expenses = provider.expenses;
    final maxSpendPerDay = provider.maxSpendPerDay;

    if (profile.income == 0 && profile.monthlyBudget == 0) {
      return '';
    }

    final now = DateTime.now();
    final todaySpending = expenses
        .where((e) =>
            e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day)
        .fold<double>(0.0, (sum, e) => sum + e.amount);

    final totalMonthSpending = expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold<double>(0.0, (sum, e) => sum + e.amount);

    final totalSpending = expenses.fold<double>(0.0, (sum, e) => sum + e.amount);

    final hasWarning = (maxSpendPerDay > 0 && todaySpending > maxSpendPerDay) ||
        totalMonthSpending > profile.monthlyBudget ||
        totalSpending > profile.income;

    if (hasWarning && settings.budgetWarningEnabled) {
      if (totalSpending > profile.income) {
        return '⚠️ Your total spending has exceeded your income!';
      } else if (totalMonthSpending > profile.monthlyBudget) {
        return '⚠️ You\'ve exceeded your monthly budget!';
      } else {
        return '⚠️ You\'ve exceeded your daily spending limit!';
      }
    }

    if (!hasWarning && settings.motivationalMessageEnabled) {
      const messages = [
        'You\'re doing great! Keep tracking your expenses daily.',
        'Nice work! You\'re building a healthy financial habit.',
        'Keep it up! Small savings add up to big results.',
      ];
      final daySeed = (now.year * 10000) + (now.month * 100) + now.day;
      return messages[daySeed % messages.length];
    }

    return '';
  }
}
