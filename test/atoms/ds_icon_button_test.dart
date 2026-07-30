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

    testWidgets('announces a named, enabled button', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        DsIconButton(
          icon: DsIcons.close,
          semanticLabel: 'Close',
          onPressed: () {},
        ),
      );

      // The name rides on the tooltip (the stock Material pattern); the
      // semantics label itself stays empty.
      expect(
        tester.getSemantics(find.byType(IconButton)),
        isSemantics(
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          isFocusable: true,
          hasTapAction: true,
          tooltip: 'Close',
          label: '',
        ),
      );
      handle.dispose();
    });

    testWidgets('a disabled icon button keeps its role and name but loses '
        'the enabled state and focus', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        const DsIconButton(
          icon: DsIcons.close,
          semanticLabel: 'Close',
          onPressed: null,
        ),
      );

      expect(
        tester.getSemantics(find.byType(IconButton)),
        isSemantics(
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
          isFocusable: false,
          tooltip: 'Close',
        ),
      );
      handle.dispose();
    });

    testWidgets('a skin can retune the state opacities and focus ring',
        (tester) async {
      final skin = DsTokens.light().copyWith(
        statePressedOpacity: 0.4,
        stateHoverOpacity: 0.2,
        stateDisabledIconOpacity: 0.15,
        focusRingWidth: 5,
      );
      await pumpDs(
        tester,
        DsIconButton(
          icon: DsIcons.close,
          semanticLabel: 'Close',
          onPressed: () {},
        ),
        theme: DsTheme.light(tokens: skin),
      );

      final style = tester.widget<IconButton>(find.byType(IconButton)).style!;
      final foreground = skin.colorText;
      expect(
        style.backgroundColor!.resolve({WidgetState.pressed}),
        foreground.withValues(alpha: 0.4),
      );
      expect(
        style.backgroundColor!.resolve({WidgetState.hovered}),
        foreground.withValues(alpha: 0.2),
      );
      expect(
        style.foregroundColor!.resolve({WidgetState.disabled}),
        foreground.withValues(alpha: 0.15),
      );
      final focused =
          style.shape!.resolve({WidgetState.focused})! as CircleBorder;
      expect(focused.side.width, 5);
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

    testWidgets('carries no indicator by default', (tester) async {
      await pumpDs(
        tester,
        DsIconButton(
          icon: DsIcons.notifications,
          semanticLabel: 'Notifications',
          onPressed: () {},
        ),
      );

      expect(find.byTooltip('Notifications'), findsOneWidget);
      // No dot means no Stack wrapping the glyph.
      expect(
        find.descendant(
          of: find.byType(IconButton),
          matching: find.byType(Stack),
        ),
        findsNothing,
      );
    });

    testWidgets('the indicator is spoken with the control name', (
      tester,
    ) async {
      // A dot nobody can hear is a state change left silent, so the meaning
      // rides on the label.
      await pumpDs(
        tester,
        DsIconButton(
          icon: DsIcons.notifications,
          semanticLabel: 'Notifications',
          showIndicator: true,
          indicatorSemanticLabel: '3 unread',
          onPressed: () {},
        ),
      );

      expect(find.byTooltip('Notifications, 3 unread'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(IconButton),
          matching: find.byType(Stack),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the indicator takes the danger signal by default', (
      tester,
    ) async {
      late DsTokens tokens;
      await pumpDs(
        tester,
        Builder(
          builder: (BuildContext context) {
            tokens = DsTokens.of(context);
            return DsIconButton(
              icon: DsIcons.notifications,
              semanticLabel: 'Notifications',
              showIndicator: true,
              indicatorSemanticLabel: 'unread',
              onPressed: () {},
            );
          },
        ),
      );

      final BoxDecoration dot = tester
          .widget<Container>(
            find.descendant(
              of: find.byType(IconButton),
              matching: find.byType(Container),
            ).first,
          )
          .decoration! as BoxDecoration;

      expect(dot.color, tokens.colorDanger);
      expect(dot.shape, BoxShape.circle);
    });

    testWidgets('the indicator holds the tap target at 320dp, every theme', (
      tester,
    ) async {
      for (final ThemeData theme in <ThemeData>[
        DsTheme.light(),
        DsTheme.dark(),
        DsTheme.light(tokens: DsSkins.engenMobileLight()),
      ]) {
        await pumpDs(
          tester,
          DsIconButton(
            icon: DsIcons.notifications,
            semanticLabel: 'Notifications',
            showIndicator: true,
            indicatorSemanticLabel: 'unread',
            onPressed: () {},
          ),
          theme: theme,
          surfaceSize: const Size(320, 640),
        );

        final Size size = tester.getSize(find.byType(IconButton));
        expect(size.width, greaterThanOrEqualTo(48));
        expect(size.height, greaterThanOrEqualTo(48));
        expect(tester.takeException(), isNull);
      }
    });
  });
}
