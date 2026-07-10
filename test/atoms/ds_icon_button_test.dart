import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsIconButton', () {
    testWidgets('renders the icon, exposes its label and taps through',
        (tester) async {
      var taps = 0;
      await pumpDs(
        tester,
        DsIconButton(
          icon: DsIcons.close,
          semanticLabel: 'Close',
          onPressed: () => taps++,
        ),
      );

      expect(find.byIcon(DsIcons.close), findsOneWidget);
      expect(find.byTooltip('Close'), findsOneWidget);

      await tester.tap(find.byType(DsIconButton));
      expect(taps, 1);
    });

    testWidgets('a null onPressed disables it', (tester) async {
      await pumpDs(
        tester,
        const DsIconButton(
          icon: DsIcons.close,
          semanticLabel: 'Close',
          onPressed: null,
        ),
      );

      final IconButton button = tester.widget(find.byType(IconButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('does not overflow at a tight size on a 320dp phone',
        (tester) async {
      await pumpDs(
        tester,
        DsIconButton(
          icon: DsIcons.moreVertical,
          semanticLabel: 'More',
          size: 32,
          iconSize: DsIconSize.sm,
          onPressed: () {},
        ),
        surfaceSize: const Size(320, 640),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
