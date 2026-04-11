import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:better_spent/core/widgets/expanded_tap_target.dart';

void main() {
  testWidgets('ExpandedTapTarget responds to tap', (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ExpandedTapTarget(
              onTap: () => tapped = true,
              child: const SizedBox(width: 10, height: 10),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ExpandedTapTarget));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
