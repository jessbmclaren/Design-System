import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsChip', () {
    testWidgets('renders its label', (tester) async {
      await pumpDs(tester, const DsChip(label: 'Active'));

      expect(find.text('Active'), findsOneWidget);
    });

    testWidgets('renders an optional trailing widget', (tester) async {
      await pumpDs(
        tester,
        const DsChip(
          label: 'Filter',
          trailing: Icon(Icons.close, key: Key('trailing')),
        ),
      );

      expect(find.text('Filter'), findsOneWidget);
      expect(find.byKey(const Key('trailing')), findsOneWidget);
    });

    testWidgets('onTap fires when the pill is tapped', (tester) async {
      var taps = 0;
      await pumpDs(
        tester,
        DsChip(label: 'Tap me', onTap: () => taps++),
      );

      expect(find.byType(InkWell), findsOneWidget);

      await tester.tap(find.text('Tap me'));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('is inert without onTap (no InkWell)', (tester) async {
      await pumpDs(tester, const DsChip(label: 'Static'));

      // The chip itself wires no InkWell when non-interactive. (Scope to the
      // chip's subtree; the surrounding Scaffold provides its own Material.)
      expect(
        find.descendant(
          of: find.byType(DsChip),
          matching: find.byType(InkWell),
        ),
        findsNothing,
      );
    });

    testWidgets('long label ellipsizes without overflow at 320dp',
        (tester) async {
      await pumpDs(
        tester,
        const DsChip(
          label:
              'A very long chip label that would otherwise push everything '
              'off the edge of the screen and overflow the row',
          trailing: Icon(Icons.close),
        ),
        surfaceSize: const Size(320, 640),
      );

      expect(tester.takeException(), isNull);

      final text = tester.widget<Text>(find.textContaining('A very long'));
      expect(text.overflow, TextOverflow.ellipsis);
    });
  });
}
