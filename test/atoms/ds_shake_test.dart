import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// The child's horizontal offset from its resting position.
double offsetOf(WidgetTester tester) =>
    tester.getTopLeft(find.text('card')).dx;

void main() {
  testWidgets('stays still until the trigger changes', (tester) async {
    await pumpDs(
      tester,
      const DsShake(trigger: 0, child: Text('card')),
      surfaceSize: const Size(400, 200),
    );
    final double resting = offsetOf(tester);
    await tester.pump(const Duration(milliseconds: 100));
    expect(offsetOf(tester), resting);
  });

  testWidgets('shakes once on a new trigger and settles back', (tester) async {
    Object trigger = 0;
    await pumpDs(
      tester,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => Column(
          children: <Widget>[
            DsShake(trigger: trigger, child: const Text('card')),
            TextButton(
              onPressed: () => setState(() => trigger = 1),
              child: const Text('reject'),
            ),
          ],
        ),
      ),
      surfaceSize: const Size(400, 300),
    );

    final double resting = offsetOf(tester);
    await tester.tap(find.text('reject'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(offsetOf(tester), isNot(resting));

    // The shake is finite: it ends back where it started.
    await tester.pump(const Duration(milliseconds: 400));
    expect(offsetOf(tester), resting);
  });

  testWidgets('stays still under reduced motion', (tester) async {
    Object trigger = 0;
    await pumpDs(
      tester,
      MediaQuery(
        data: const MediaQueryData(disableAnimations: true),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) => Column(
            children: <Widget>[
              DsShake(trigger: trigger, child: const Text('card')),
              TextButton(
                onPressed: () => setState(() => trigger = 1),
                child: const Text('reject'),
              ),
            ],
          ),
        ),
      ),
      surfaceSize: const Size(400, 300),
    );

    final double resting = offsetOf(tester);
    await tester.tap(find.text('reject'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));
    expect(offsetOf(tester), resting);
    expect(tester.binding.transientCallbackCount, 0);
  });
}
