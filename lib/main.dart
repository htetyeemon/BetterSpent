import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(const BetterSpentApp());
}

class BetterSpentApp extends StatelessWidget {
  const BetterSpentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.appRouter,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.background,
        canvasColor: AppColors.background,
      ),
    );
  }
}
