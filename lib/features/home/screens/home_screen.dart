import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:better_spent/core/router/route_names.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Home Screen', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(RouteNames.expenses.path),
              child: const Text('Go to Expense List'),
            ),
          ],
        ),
      ),
    );
  }
}
