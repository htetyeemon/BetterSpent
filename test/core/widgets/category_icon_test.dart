import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:better_spent/core/widgets/category_icon.dart';

void main() {
  testWidgets('CategoryIcon renders correct icon for Food & Drink', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CategoryIcon(category: 'Food & Drink'),
        ),
      ),
    );

    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.icon, Icons.restaurant_outlined);
  });

  testWidgets('CategoryIcon falls back to category icon for unknown category', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CategoryIcon(category: 'Unknown'),
        ),
      ),
    );

    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.icon, Icons.category_outlined);
  });
}
