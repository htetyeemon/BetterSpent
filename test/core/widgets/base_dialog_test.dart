import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:better_spent/core/widgets/base_dialog.dart';

void main() {
  testWidgets('BaseDialog renders child content', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: BaseDialog(
            child: Text('Dialog Body'),
          ),
        ),
      ),
    );

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Dialog Body'), findsOneWidget);
  });
}
