import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsAuthShell', () {
    testWidgets('renders the child, header and footer slots', (tester) async {
      await pumpDs(
        tester,
        const DsAuthShell(
          header: DsWordmark(primary: 'acme', accent: 'id'),
          footer: Text('Privacy'),
          child: Text('Card content'),
        ),
      );

      expect(find.text('Card content'), findsOneWidget);
      expect(find.byType(DsWordmark), findsOneWidget);
      expect(find.text('Privacy'), findsOneWidget);
    });

    testWidgets('pins the header top-start and the footer to the bottom',
        (tester) async {
      await pumpDs(
        tester,
        const DsAuthShell(
          header: DsWordmark(primary: 'acme'),
          footer: Text('Terms'),
          child: Text('Card'),
        ),
        surfaceSize: const Size(800, 600),
      );

      final header = tester.getTopLeft(find.byType(DsWordmark));
      final footer = tester.getBottomLeft(find.text('Terms'));
      final card = tester.getCenter(find.text('Card'));
      expect(header.dy, lessThan(card.dy));
      expect(footer.dy, greaterThan(card.dy));
      expect(footer.dy, lessThanOrEqualTo(600));
    });

    testWidgets('renders a back affordance beside the header and fires it',
        (tester) async {
      var backs = 0;
      await pumpDs(
        tester,
        DsAuthShell(
          header: const DsWordmark(primary: 'acme'),
          onBack: () => backs++,
          child: const Text('Card'),
        ),
      );

      expect(find.byTooltip('Back'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pump();
      expect(backs, 1);
    });

    testWidgets('hides the back affordance when onBack is null',
        (tester) async {
      await pumpDs(
        tester,
        const DsAuthShell(
          header: DsWordmark(primary: 'acme'),
          child: Text('Card'),
        ),
      );

      expect(find.byType(DsIconButton), findsNothing);
    });

    testWidgets('shows the hero only at the expanded breakpoint',
        (tester) async {
      Widget shell() => const DsAuthShell(
            hero: Text('Hero panel'),
            child: Text('Card'),
          );

      await pumpDs(tester, shell(), surfaceSize: const Size(1000, 800));
      expect(find.text('Hero panel'), findsOneWidget);
      // The hero takes the start side and the card the end side.
      expect(
        tester.getCenter(find.text('Hero panel')).dx,
        lessThan(tester.getCenter(find.text('Card')).dx),
      );

      await pumpDs(tester, shell(), surfaceSize: const Size(700, 800));
      expect(find.text('Hero panel'), findsNothing);
      expect(find.text('Card'), findsOneWidget);
    });

    testWidgets('scrolls a tall card on a short viewport at 2x text scale',
        (tester) async {
      await pumpDs(
        tester,
        DsAuthShell(
          header: const DsWordmark(primary: 'acme'),
          footer: const Text('Terms'),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 12; i++)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text('Row $i'),
                ),
            ],
          ),
        ),
        surfaceSize: const Size(320, 480),
        textScale: 2.0,
      );

      expect(tester.takeException(), isNull);
      // The last row starts beyond the viewport, then scrolls into it.
      expect(tester.getBottomLeft(find.text('Row 11')).dy, greaterThan(480));
      await tester.scrollUntilVisible(find.text('Row 11'), 100);
      expect(tester.getBottomLeft(find.text('Row 11')).dy,
          lessThanOrEqualTo(480));
      expect(tester.takeException(), isNull);
    });

    testWidgets('overlays the banner at the bottom without stealing focus',
        (tester) async {
      final node = FocusNode();
      addTearDown(node.dispose);
      Widget shell({Widget? banner}) => DsAuthShell(
            header: const DsWordmark(primary: 'acme'),
            footer: const Text('Terms'),
            banner: banner,
            child: Focus(
              focusNode: node,
              child: const SizedBox(width: 120, height: 40),
            ),
          );

      await pumpDs(tester, shell(), surfaceSize: const Size(800, 600));
      node.requestFocus();
      await tester.pump();
      expect(node.hasPrimaryFocus, isTrue);

      await pumpDs(
        tester,
        shell(
          banner: DsCookieBanner(
            message: 'We use cookies.',
            onAcceptAll: () {},
            onRejectNonEssential: () {},
            onManagePreferences: () {},
          ),
        ),
        surfaceSize: const Size(800, 600),
      );
      await tester.pump();

      // The banner sits on the bottom edge and the card keeps its focus.
      expect(find.byType(DsCookieBanner), findsOneWidget);
      expect(
        tester.getBottomLeft(find.byType(DsCookieBanner)).dy,
        moreOrLessEquals(600),
      );
      expect(node.hasPrimaryFocus, isTrue);
    });

    testWidgets('paints the default backdrop and lets null opt out',
        (tester) async {
      await pumpDs(tester, const DsAuthShell(child: Text('Card')));
      expect(find.byType(DsAuthGradient), findsOneWidget);
      expect(find.byType(DsBrandBloom), findsOneWidget);

      await pumpDs(
        tester,
        const DsAuthShell(backdrop: null, child: Text('Card')),
      );
      expect(find.byType(DsAuthGradient), findsNothing);
      expect(find.byType(DsBrandBloom), findsNothing);
    });

    testWidgets('does not overflow at 320dp with every slot filled',
        (tester) async {
      await pumpDs(
        tester,
        DsAuthShell(
          header: const DsWordmark(primary: 'acme', accent: 'id'),
          onBack: () {},
          hero: const Text('Hero panel'),
          footer: Wrap(
            children: [
              DsLink(label: 'Privacy', onPressed: () {}),
              DsLink(label: 'Terms', onPressed: () {}),
              DsLink(label: 'Cookie settings', onPressed: () {}),
            ],
          ),
          child: const Text('Card'),
        ),
        surfaceSize: const Size(320, 640),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Card'), findsOneWidget);
    });

    testWidgets('renders under the dark and skinned themes', (tester) async {
      final themes = <String, ThemeData>{
        'dark': DsTheme.dark(),
        'engen': DsTheme.light(tokens: DsSkins.engenLight()),
      };
      for (final entry in themes.entries) {
        await pumpDs(
          tester,
          const DsAuthShell(
            header: DsWordmark(primary: 'acme'),
            footer: Text('Terms'),
            child: Text('Card'),
          ),
          theme: entry.value,
        );
        expect(tester.takeException(), isNull, reason: entry.key);
        expect(find.text('Card'), findsOneWidget, reason: entry.key);
      }
    });

    testWidgets('does not overflow on a wide desktop with the hero split',
        (tester) async {
      await pumpDs(
        tester,
        DsAuthShell(
          header: const DsWordmark(primary: 'acme', accent: 'id'),
          onBack: () {},
          hero: const Text('Hero panel'),
          footer: const Text('Terms'),
          child: const SizedBox(width: 400, height: 300, child: Text('Card')),
        ),
        surfaceSize: const Size(1920, 1080),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Hero panel'), findsOneWidget);
      expect(find.text('Card'), findsOneWidget);
    });
  });
}
