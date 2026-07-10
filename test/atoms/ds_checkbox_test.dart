import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsCheckbox', () {
    testWidgets('renders its label', (tester) async {
      await pumpDs(
        tester,
        DsCheckbox(value: false, onChanged: (_) {}, label: 'Accept terms'),
      );

      expect(find.text('Accept terms'), findsOneWidget);
    });

    testWidgets('shows a check icon when checked', (tester) async {
      await pumpDs(
        tester,
        DsCheckbox(value: true, onChanged: (_) {}, label: 'Subscribe'),
      );

      expect(find.byIcon(DsIcons.check), findsOneWidget);
    });

    testWidgets('does not show a check icon when unchecked', (tester) async {
      await pumpDs(
        tester,
        DsCheckbox(value: false, onChanged: (_) {}, label: 'Subscribe'),
      );

      expect(find.byIcon(DsIcons.check), findsNothing);
    });

    testWidgets('tapping calls onChanged with the negated value',
        (tester) async {
      bool? reported;
      await pumpDs(
        tester,
        DsCheckbox(
          value: false,
          onChanged: (v) => reported = v,
          label: 'Remember me',
        ),
      );

      await tester.tap(find.text('Remember me'));
      await tester.pump();

      expect(reported, isTrue);
    });

    testWidgets('null onChanged suppresses interaction', (tester) async {
      await pumpDs(
        tester,
        const DsCheckbox(value: false, onChanged: null, label: 'Disabled'),
      );

      // Tapping a disabled control must not throw and there is nothing to fire.
      await tester.tap(find.text('Disabled'));
      await tester.pump();

      final opacity = tester.widget<Opacity>(
        find.ancestor(
          of: find.byType(AnimatedContainer),
          matching: find.byType(Opacity),
        ),
      );
      expect(opacity.opacity, 0.5);
    });

    testWidgets('isError renders the danger border colour', (tester) async {
      await pumpDs(
        tester,
        DsCheckbox(
          value: false,
          onChanged: (_) {},
          label: 'Invalid',
          isError: true,
        ),
      );

      final tokens = DsTokens.of(
        tester.element(find.byType(DsCheckbox)),
      );
      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.border!.top.color, tokens.colorDanger);
    });

    testWidgets('does not overflow at a 320x640 surface', (tester) async {
      await pumpDs(
        tester,
        DsCheckbox(
          value: true,
          onChanged: (_) {},
          label: 'A reasonably long label that should wrap without overflowing',
        ),
        surfaceSize: const Size(320, 640),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
