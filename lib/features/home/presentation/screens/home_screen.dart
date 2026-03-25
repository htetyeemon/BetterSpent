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
import '../utils/home_notification_helper.dart';
import '../../../../core/utils/bottom_nav_helper.dart';

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
          final currentIndex = _currentNavIndex;
          setState(() => _currentNavIndex = index);
          handleBottomNavTap(context, index, currentIndex);
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
    final notification = HomeNotificationHelper(provider).getNotification();
    if (notification.isEmpty) return const SizedBox.shrink();
    if (provider.dismissedNotification == notification) {
      return const SizedBox.shrink();
    }
    final isWarning = notification.contains('⚠️');
    return MessageCard(
      message: notification,
      isWarning: isWarning,
      icon: isWarning ? Icons.warning_amber_rounded : Icons.lightbulb_outline,
    );
  }
}
