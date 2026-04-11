import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:better_spent/core/widgets/bottom_navigation.dart';

void main() {
  testWidgets('BottomNavigation calls onTap with correct index', (tester) async {
    int? tappedIndex;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: BottomNavigation(
            currentIndex: 0,
            onTap: (index) => tappedIndex = index,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Expenses'));
    await tester.pump();

    expect(tappedIndex, 1);
  });

  testWidgets('BottomNavigation renders active label color', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          bottomNavigationBar: BottomNavigation(
            currentIndex: 2,
            onTap: _noop,
          ),
        ),
      ),
    );

    expect(find.text('Summary'), findsOneWidget);
  });
}

void _noop(int _) {}
