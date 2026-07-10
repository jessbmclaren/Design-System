import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    testWidgets('pads the tap target to 48dp and fires at its edge',
        (tester) async {
      var taps = 0;
      await pumpDs(
        tester,
        DsIconButton(
          icon: DsIcons.close,
          semanticLabel: 'Close',
          onPressed: () => taps++,
        ),
        // shrinkWrap themes (desktop) are the case the explicit padding must
        // override; mobile themes already pad.
        theme: DsTheme.light()
            .copyWith(materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
      );

      final rect = tester.getRect(find.byType(DsIconButton));
      expect(rect.width, greaterThanOrEqualTo(48));
      expect(rect.height, greaterThanOrEqualTo(48));

      // A corner of the 48dp box lies outside the 40dp visual circle but must
      // still reach the button.
      await tester.tapAt(rect.topLeft + const Offset(2, 2));
      expect(taps, 1);
    });

    testWidgets('keyboard focus draws an accent ring distinct from rest',
        (tester) async {
      await pumpDs(
        tester,
        DsIconButton(
          icon: DsIcons.close,
          semanticLabel: 'Close',
          onPressed: () {},
        ),
      );

      Material buttonMaterial() => tester.widget<Material>(
            find
                .descendant(
                  of: find.byType(IconButton),
                  matching: find.byType(Material),
                )
                .first,
          );

      final restShape = buttonMaterial().shape! as CircleBorder;
      expect(restShape.side, BorderSide.none);

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();

      final tokens = DsTokens.of(tester.element(find.byType(DsIconButton)));
      final focusedShape = buttonMaterial().shape! as CircleBorder;
      expect(focusedShape.side.width, 2);
      expect(focusedShape.side.color, tokens.formAccentColor);
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
