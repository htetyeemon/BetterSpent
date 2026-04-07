import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_text_styles.dart';
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
    final isInitialized =
        context.select((AppProvider p) => p.isInitialized);
    final currencySymbol =
        context.select((AppProvider p) => p.currencySymbol);
    final income = context.select((AppProvider p) => p.profile.income);
    final monthlyBudget =
        context.select((AppProvider p) => p.profile.monthlyBudget);
    final isOnline = context.select((AppProvider p) => p.isOnline);
    final aiInputEnabled =
        context.select((AppProvider p) => p.settings.aiInputEnabled);
    final dailyStreak = context.select((AppProvider p) => p.dailyStreak);
    final dismissedNotification =
        context.select((AppProvider p) => p.dismissedNotification);
    final notification =
        context.select((AppProvider p) => p.notification);

    if (!isInitialized) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: _buildLoadingState(),
        ),
      );
    }

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
                        final provider = context.read<AppProvider>();
                        provider.updateProfile(
                          provider.profile.copyWith(
                            income: amount,
                            incomeUpdatedAt: DateTime.now(),
                          ),
                        );
                      },
                      monthlyBudget: monthlyBudget,
                      onBudgetSaved: (amount) {
                        final provider = context.read<AppProvider>();
                        provider.updateProfile(
                          provider.profile.copyWith(monthlyBudget: amount),
                        );
                      },
                    ),
                    const SizedBox(height: AppConstants.spacingLg),
                    _buildMessageCard(
                      notification: notification,
                      dismissedNotification: dismissedNotification,
                    ),
                    const SizedBox(height: AppConstants.spacingLg),
                    ExpenseInputCard(
                      isOnline: isOnline,
                      aiInputEnabled: aiInputEnabled,
                      onAddExpenseManually: () {
                        context.go(RouteNames.addExpense);
                      },
                    ),
                    const SizedBox(height: AppConstants.spacingLg),
                    DailyStreakCardInline(streak: dailyStreak),
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

  Widget _buildMessageCard({
    required String notification,
    required String? dismissedNotification,
  }) {
    if (notification.isEmpty) return const SizedBox.shrink();
    if (dismissedNotification == notification) {
      return const SizedBox.shrink();
    }
    final isWarning = notification.contains('⚠️');
    return MessageCard(
      message: notification,
      isWarning: isWarning,
      icon: isWarning ? Icons.warning_amber_rounded : Icons.lightbulb_outline,
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingLg,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLoadingLogo(),
            const SizedBox(height: AppConstants.spacingLg),
            Text(
              'Getting your dashboard ready',
              textAlign: TextAlign.center,
              style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppConstants.spacingSm),
            Text(
              'Syncing your latest expenses and insights.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            const LinearProgressIndicator(
              minHeight: 4,
              color: AppColors.primary,
              backgroundColor: AppColors.surface,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: AppConstants.iconLg,
          height: AppConstants.iconLg,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          ),
          child: const Icon(
            Icons.check,
            color: Colors.black,
            size: 20,
          ),
        ),
        const SizedBox(width: AppConstants.spacingSm),
        Text(
          'BetterSpent',
          style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
