import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsWaitingScreen', () {
    testWidgets('renders the headline, supporting line and spinner',
        (tester) async {
      await pumpDs(
        tester,
        const DsWaitingScreen(
          headline: 'Signing you in',
          supportingText: 'This will only take a moment.',
        ),
      );
      await tester.pump(DsMotion.expressive);

      expect(find.textContaining('Signing you in'), findsOneWidget);
      expect(find.text('This will only take a moment.'), findsOneWidget);
      expect(find.byType(DsSpinner), findsOneWidget);
      expect(find.byType(DsAnimatedEllipsis), findsOneWidget);
    });

    testWidgets('shows the header slot pinned over the backdrop',
        (tester) async {
      await pumpDs(
        tester,
        const DsWaitingScreen(
          headline: 'Preparing your workspace',
          header: DsWordmark(primary: 'acme'),
        ),
      );
      await tester.pump(DsMotion.expressive);

      expect(find.byType(DsWordmark), findsOneWidget);
      expect(find.byType(DsAuthGradient), findsOneWidget);
    });

    testWidgets('drops the spinner when showSpinner is false',
        (tester) async {
      await pumpDs(
        tester,
        const DsWaitingScreen(
          headline: 'Preparing your workspace',
          showSpinner: false,
        ),
      );
      await tester.pump(DsMotion.expressive);

      expect(find.byType(DsSpinner), findsNothing);
    });

    testWidgets('a null backdrop leaves a plain surface', (tester) async {
      await pumpDs(
        tester,
        const DsWaitingScreen(
          headline: 'Preparing your workspace',
          backdrop: null,
        ),
      );
      await tester.pump(DsMotion.expressive);

      expect(find.byType(DsAuthGradient), findsNothing);
    });

    testWidgets('accepts a custom backdrop widget', (tester) async {
      await pumpDs(
        tester,
        const DsWaitingScreen(
          headline: 'Preparing your workspace',
          backdrop: DsAuthGradient(child: DsBrandBloom()),
        ),
      );
      await tester.pump(DsMotion.expressive);

      expect(find.byType(DsBrandBloom), findsOneWidget);
    });

    testWidgets('holds no timers: the frame settles under reduced motion',
        (tester) async {
      await pumpDs(
        tester,
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: DsWaitingScreen(
            headline: 'Signing you in',
            supportingText: 'This will only take a moment.',
          ),
        ),
      );

      // Everything settles with nothing scheduled, which pumpAndSettle
      // verifies by returning; a looping timer or animation would hang it.
      await tester.pumpAndSettle();

      // The entrance shows its settled frame immediately.
      final fade = tester.widget<FadeTransition>(
        find
            .descendant(
              of: find.byType(DsFadeSlideIn),
              matching: find.byType(FadeTransition),
            )
            .first,
      );
      expect(fade.opacity.value, 1);

      // The spinner stills to a static three-quarter ring.
      final ring = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(ring.value, 0.75);

      // The ellipsis renders as a full stop-free still frame of three dots.
      expect(find.text('...'), findsOneWidget);
    });

    testWidgets('announces the headline through a live region',
        (tester) async {
      await pumpDs(
        tester,
        const DsWaitingScreen(headline: 'Signing you in'),
      );
      await tester.pump(DsMotion.expressive);

      final region = tester.widget<Semantics>(
        find
            .ancestor(
              of: find.textContaining('Signing you in'),
              matching: find.byType(Semantics),
            )
            .first,
      );
      expect(region.properties.liveRegion, isTrue);
    });

    testWidgets('does not overflow at 320dp', (tester) async {
      await pumpDs(
        tester,
        const DsWaitingScreen(
          headline: 'Preparing your brand new workspace environment',
          supportingText:
              'A longer supporting sentence that has to wrap on a small '
              'phone without spilling out of its bounds.',
          header: DsWordmark(primary: 'acme'),
        ),
        surfaceSize: const Size(320, 640),
      );
      await tester.pump(DsMotion.expressive);

      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow at a wide width', (tester) async {
      await pumpDs(
        tester,
        const DsWaitingScreen(headline: 'Signing you in'),
        surfaceSize: const Size(1920, 800),
      );
      await tester.pump(DsMotion.expressive);

      expect(tester.takeException(), isNull);
    });

    testWidgets('scrolls rather than overflowing on a very short viewport',
        (tester) async {
      await pumpDs(
        tester,
        const DsWaitingScreen(
          headline: 'Preparing your brand new workspace environment',
          supportingText:
              'A longer supporting sentence that has to wrap on a small '
              'phone without spilling out of its bounds.',
        ),
        surfaceSize: const Size(320, 200),
        textScale: 2,
      );
      await tester.pump(DsMotion.expressive);

      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
