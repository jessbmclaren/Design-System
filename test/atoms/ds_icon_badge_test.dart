import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsIconBadge', () {
    testWidgets('renders its icon in a circle at the default size',
        (tester) async {
      await pumpDs(tester, const DsIconBadge(icon: DsIcons.check));

      expect(find.byIcon(DsIcons.check), findsOneWidget);
      expect(tester.getSize(find.byType(DsIconBadge)), const Size(28, 28));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(DsIconBadge),
          matching: find.byType(Container),
        ),
      );
      expect(
        (container.decoration! as BoxDecoration).shape,
        BoxShape.circle,
      );
    });

    testWidgets('honours a custom diameter and glyph size', (tester) async {
      await pumpDs(
        tester,
        const DsIconBadge(icon: DsIcons.check, size: 48, iconSize: 20),
      );

      expect(tester.getSize(find.byType(DsIconBadge)), const Size(48, 48));
      expect(tester.widget<Icon>(find.byIcon(DsIcons.check)).size, 20);
    });

    testWidgets('colours each tone from its token pair', (tester) async {
      final tokens = DsTheme.light().extension<DsTokens>()!;
      final expectations = <DsIconBadgeTone, (Color, Color)>{
        DsIconBadgeTone.primary: (
          tokens.buttonPrimaryColorBackground,
          tokens.buttonPrimaryColorText,
        ),
        DsIconBadgeTone.success: (
          tokens.badgeSuccessColorBackground,
          tokens.badgeSuccessColorText,
        ),
        DsIconBadgeTone.warning: (
          tokens.badgeWarningColorBackground,
          tokens.badgeWarningColorText,
        ),
        DsIconBadgeTone.danger: (
          tokens.badgeDangerColorBackground,
          tokens.badgeDangerColorText,
        ),
        DsIconBadgeTone.neutral: (
          tokens.badgeNeutralColorBackground,
          tokens.badgeNeutralColorText,
        ),
      };

      for (final entry in expectations.entries) {
        await pumpDs(
          tester,
          DsIconBadge(icon: DsIcons.check, tone: entry.key),
        );

        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(DsIconBadge),
            matching: find.byType(Container),
          ),
        );
        expect(
          (container.decoration! as BoxDecoration).color,
          entry.value.$1,
          reason: '${entry.key.name} background',
        );
        expect(
          tester.widget<Icon>(find.byIcon(DsIcons.check)).color,
          entry.value.$2,
          reason: '${entry.key.name} glyph',
        );
      }
    });

    testWidgets('accepts explicit colour overrides', (tester) async {
      const background = Color(0xFF123456);
      const foreground = Color(0xFF654321);

      await pumpDs(
        tester,
        const DsIconBadge(
          icon: DsIcons.check,
          backgroundColor: background,
          foregroundColor: foreground,
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(DsIconBadge),
          matching: find.byType(Container),
        ),
      );
      expect((container.decoration! as BoxDecoration).color, background);
      expect(
        tester.widget<Icon>(find.byIcon(DsIcons.check)).color,
        foreground,
      );
    });

    testWidgets('is decorative by default', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(tester, const DsIconBadge(icon: DsIcons.check));

      // The mark's own subtree is excluded outright, so the badge contributes
      // nothing for a neighbouring label to compete with.
      final exclude = tester.firstWidget<ExcludeSemantics>(
        find.descendant(
          of: find.byType(DsIconBadge),
          matching: find.byType(ExcludeSemantics),
        ),
      );
      expect(exclude.excluding, isTrue);
      handle.dispose();
    });

    testWidgets('announces a semantic label when given one', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        const DsIconBadge(
          icon: DsIcons.check,
          tone: DsIconBadgeTone.success,
          semanticLabel: 'Completed',
        ),
      );

      expect(find.bySemanticsLabel('Completed'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('renders without overflow at 320dp', (tester) async {
      await pumpDs(
        tester,
        const DsIconBadge(icon: DsIcons.check, size: 48),
        surfaceSize: const Size(320, 640),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
