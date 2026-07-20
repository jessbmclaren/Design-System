import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsSummarySection', () {
    testWidgets('renders its title, values and a named edit link', (
      tester,
    ) async {
      bool edited = false;
      await pumpDs(
        tester,
        DsSummarySection(
          title: 'Business details',
          onEdit: () => edited = true,
          child: const Text('Northwind Traders'),
        ),
        surfaceSize: const Size(600, 400),
      );

      expect(find.text('Business details'), findsOneWidget);
      expect(find.text('Northwind Traders'), findsOneWidget);
      // The link says what it edits, so several sections never read alike.
      expect(find.bySemanticsLabel('Edit Business details'), findsOneWidget);

      await tester.tap(find.text('Edit'));
      await tester.pump();
      expect(edited, isTrue);
    });

    testWidgets('hides the link when the section cannot be changed', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const DsSummarySection(
          title: 'Business details',
          child: Text('Northwind Traders'),
        ),
        surfaceSize: const Size(600, 400),
      );
      expect(find.text('Edit'), findsNothing);
    });
  });

  group('DsIntroCard', () {
    testWidgets('renders eyebrow, title, body, actions and close', (
      tester,
    ) async {
      bool closed = false;
      await pumpDs(
        tester,
        DsIntroCard(
          eyebrow: 'New',
          title: 'Track spend as it happens',
          body: const Text('Every transaction lands here within a minute.'),
          primaryAction: DsButton(label: 'Show me', onPressed: () {}),
          secondaryAction: DsButton(
            label: 'Not now',
            variant: DsButtonVariant.tertiary,
            onPressed: () {},
          ),
          onClose: () => closed = true,
        ),
        surfaceSize: const Size(900, 700),
      );

      expect(find.text('New'), findsOneWidget);
      expect(find.text('Track spend as it happens'), findsOneWidget);
      expect(find.text('Show me'), findsOneWidget);
      expect(find.text('Not now'), findsOneWidget);

      await tester.tap(find.byTooltip('Close'));
      await tester.pump();
      expect(closed, isTrue);
    });

    testWidgets('holds 320dp and 1440dp in every theme', (tester) async {
      for (final ThemeData theme in <ThemeData>[
        DsTheme.light(),
        DsTheme.dark(),
        DsTheme.light(tokens: DsSkins.engenLight()),
      ]) {
        for (final Size size in <Size>[
          const Size(320, 720),
          const Size(1440, 900),
        ]) {
          await pumpDs(
            tester,
            DsIntroCard(
              eyebrow: 'New',
              title: 'Track spend as it happens',
              body: const Text('Every transaction lands here in a minute.'),
              primaryAction: DsButton(label: 'Show me', onPressed: () {}),
              secondaryAction: DsButton(
                label: 'Not now',
                variant: DsButtonVariant.tertiary,
                onPressed: () {},
              ),
              onClose: () {},
            ),
            surfaceSize: size,
            theme: theme,
          );
          expect(tester.takeException(), isNull);
        }
      }
    });
  });

  group('DsTimeField', () {
    testWidgets('shows the hint until a time is chosen, then formats it', (
      tester,
    ) async {
      await pumpDs(
        tester,
        DsTimeField(
          label: 'Opens at',
          hintText: 'Choose a time',
          onChanged: (_) {},
        ),
        surfaceSize: const Size(500, 400),
      );
      expect(find.text('Choose a time'), findsOneWidget);

      await pumpDs(
        tester,
        DsTimeField(
          label: 'Opens at',
          value: const TimeOfDay(hour: 9, minute: 30),
          onChanged: (_) {},
        ),
        surfaceSize: const Size(500, 400),
      );
      // Formatted by the locale, so match loosely on the digits.
      expect(find.textContaining('9:30'), findsOneWidget);
    });

    testWidgets('announces itself as a button carrying its value', (
      tester,
    ) async {
      await pumpDs(
        tester,
        DsTimeField(
          label: 'Opens at',
          value: const TimeOfDay(hour: 9, minute: 30),
          onChanged: (_) {},
        ),
        surfaceSize: const Size(500, 400),
      );
      expect(find.bySemanticsLabel(RegExp('Opens at')), findsAtLeastNWidgets(1));
    });

    testWidgets('a null onChanged disables it', (tester) async {
      await pumpDs(
        tester,
        const DsTimeField(label: 'Opens at', onChanged: null),
        surfaceSize: const Size(500, 400),
      );
      final InkWell well = tester.widget<InkWell>(find.byType(InkWell).first);
      expect(well.onTap, isNull);
    });

    testWidgets('holds 320dp with an error, in every theme', (tester) async {
      for (final ThemeData theme in <ThemeData>[
        DsTheme.light(),
        DsTheme.dark(),
        DsTheme.light(tokens: DsSkins.engenLight()),
      ]) {
        await pumpDs(
          tester,
          DsTimeField(
            label: 'Opens at',
            value: const TimeOfDay(hour: 17, minute: 5),
            errorText: 'Choose a time inside opening hours',
            onChanged: (_) {},
          ),
          surfaceSize: const Size(320, 600),
          theme: theme,
        );
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('DsWaitingScreen arrival', () {
    testWidgets('an icon replaces the spinner and stills the headline', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const DsWaitingScreen(
          headline: 'You are in',
          icon: DsIconBadge(icon: DsIcons.check, size: 56),
        ),
        surfaceSize: const Size(600, 700),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(DsSpinner), findsNothing);
      expect(find.byType(DsIconBadge), findsOneWidget);
      expect(find.byType(DsAnimatedEllipsis), findsNothing);
    });

    testWidgets('without an icon it still waits', (tester) async {
      await pumpDs(
        tester,
        const DsWaitingScreen(headline: 'Signing you in'),
        surfaceSize: const Size(600, 700),
      );
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(DsSpinner), findsOneWidget);
    });
  });
}
