import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:better_spent/core/widgets/primary_button.dart';

void main() {
  testWidgets('PrimaryButton triggers onPressed when enabled', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            text: 'Continue',
            onPressed: () => tapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(tapped, isTrue);
  });

  testWidgets('PrimaryButton does not trigger when disabled', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            text: 'Continue',
            onPressed: () => tapped = true,
            isEnabled: false,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(tapped, isFalse);
  });

  testWidgets('PrimaryButton shows loader when isLoading', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            text: 'Continue',
            onPressed: _noop,
            isLoading: true,
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}

void _noop() {}
