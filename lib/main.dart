import 'package:flutter/material.dart';
import 'core/router/app_router.dart';

void main() {
  runApp(const BetterSpentApp());
}

class BetterSpentApp extends StatelessWidget {
  const BetterSpentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter.router,
    );
  }
}
