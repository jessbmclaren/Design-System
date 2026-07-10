import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsSignInView', () {
    testWidgets('renders title, description and primary action label', (
      tester,
    ) async {
      await pumpDs(
        tester,
        DsSignInView(
          title: 'Welcome back',
          description: 'Sign in to continue to your workspace.',
          primaryAction: DsSignInAction(label: 'Continue', onPressed: () {}),
        ),
      );

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Sign in to continue to your workspace.'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('primary action fires on tap', (tester) async {
      var taps = 0;
      await pumpDs(
        tester,
        DsSignInView(
          title: 'Welcome back',
          description: 'Sign in to continue.',
          primaryAction: DsSignInAction(
            label: 'Continue',
            onPressed: () => taps++,
          ),
        ),
      );

      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('renders footer when provided', (tester) async {
      await pumpDs(
        tester,
        DsSignInView(
          title: 'Welcome back',
          description: 'Sign in to continue.',
          primaryAction: DsSignInAction(label: 'Continue', onPressed: () {}),
          footer: const Text('No account yet?'),
        ),
      );

      expect(find.text('No account yet?'), findsOneWidget);
    });

    testWidgets('does not overflow at 320dp', (tester) async {
      await pumpDs(
        tester,
        DsSignInView(
          title: 'Welcome to the platform',
          description:
              'Sign in to continue to your workspace and pick up where you left off.',
          primaryAction: DsSignInAction(label: 'Continue', onPressed: () {}),
          brandIcon: Icons.lock_outline,
          footer: const Text('No account yet?'),
        ),
        surfaceSize: const Size(320, 640),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without a description', (tester) async {
      await pumpDs(
        tester,
        DsSignInView(
          title: 'Sign in to your account',
          primaryAction: DsSignInAction(label: 'Sign in', onPressed: () {}),
        ),
      );

      expect(find.text('Sign in to your account'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('centres the heading by default and start-aligns on request',
        (tester) async {
      await pumpDs(
        tester,
        DsSignInView(
          title: 'Welcome back',
          description: 'Sign in to continue.',
          primaryAction: DsSignInAction(label: 'Continue', onPressed: () {}),
        ),
      );

      expect(
        tester.widget<Text>(find.text('Welcome back')).textAlign,
        TextAlign.center,
      );

      await pumpDs(
        tester,
        DsSignInView(
          title: 'Welcome back',
          description: 'Sign in to continue.',
          headingAlignment: DsHeadingAlignment.start,
          primaryAction: DsSignInAction(label: 'Continue', onPressed: () {}),
        ),
      );

      expect(
        tester.widget<Text>(find.text('Welcome back')).textAlign,
        TextAlign.start,
      );
    });

    testWidgets('renders the footer band edge to edge in a tinted strip',
        (tester) async {
      await pumpDs(
        tester,
        DsSignInView(
          title: 'Sign in to your account',
          primaryAction: DsSignInAction(label: 'Sign in', onPressed: () {}),
          footerBand: const Text('New here?'),
        ),
      );

      final tokens = DsTokens.of(tester.element(find.byType(DsSignInView)));
      final band = find.byWidgetPredicate(_isFooterBand);
      expect(band, findsOneWidget);
      final decoration =
          tester.widget<Container>(band).decoration! as BoxDecoration;
      expect(decoration.color, tokens.offsetBackgroundColor);
      expect(
        find.descendant(of: band, matching: find.text('New here?')),
        findsOneWidget,
      );

      // Edge to edge: the band spans the full width of the card's clip,
      // outside the body's padding.
      final clip = find
          .descendant(
            of: find.byType(DsSignInView),
            matching: find.byType(ClipRRect),
          )
          .first;
      expect(tester.getSize(band).width, tester.getSize(clip).width);
    });

    testWidgets('shows no footer band tint by default', (tester) async {
      await pumpDs(
        tester,
        DsSignInView(
          title: 'Sign in to your account',
          primaryAction: DsSignInAction(label: 'Sign in', onPressed: () {}),
        ),
      );

      expect(find.byWidgetPredicate(_isFooterBand), findsNothing);
    });

    testWidgets('shows a labelled close button that fires onClose',
        (tester) async {
      var closed = 0;
      await pumpDs(
        tester,
        DsSignInView(
          title: 'Sign in to your account',
          primaryAction: DsSignInAction(label: 'Sign in', onPressed: () {}),
          onClose: () => closed++,
        ),
      );

      expect(find.byTooltip('Close'), findsOneWidget);

      await tester.tap(find.byType(DsIconButton));
      await tester.pump();

      expect(closed, 1);
    });

    testWidgets('shows no close button when onClose is null', (tester) async {
      await pumpDs(
        tester,
        DsSignInView(
          title: 'Sign in to your account',
          primaryAction: DsSignInAction(label: 'Sign in', onPressed: () {}),
        ),
      );

      expect(find.byType(DsIconButton), findsNothing);
    });

    testWidgets('draws the card border by default and drops it on request',
        (tester) async {
      BoxDecoration cardDecoration() {
        final tokens = DsTokens.of(tester.element(find.byType(DsSignInView)));
        return tester
            .widgetList<Container>(find.byType(Container))
            .map((c) => c.decoration)
            .whereType<BoxDecoration>()
            .singleWhere((d) => d.color == tokens.formBackgroundColor);
      }

      await pumpDs(
        tester,
        DsSignInView(
          title: 'Sign in to your account',
          primaryAction: DsSignInAction(label: 'Sign in', onPressed: () {}),
        ),
      );
      expect(cardDecoration().border, isNotNull);

      await pumpDs(
        tester,
        DsSignInView(
          title: 'Sign in to your account',
          showBorder: false,
          primaryAction: DsSignInAction(label: 'Sign in', onPressed: () {}),
        ),
      );
      expect(cardDecoration().border, isNull);
    });

    testWidgets('lays out the new slots without overflow at 320dp',
        (tester) async {
      await pumpDs(
        tester,
        DsSignInView(
          title: 'Sign in to your account',
          headingAlignment: DsHeadingAlignment.start,
          primaryAction: DsSignInAction(label: 'Sign in', onPressed: () {}),
          form: const SizedBox(height: 120),
          footerBand: const Text('New to the platform? Create an account.'),
          onClose: () {},
          showBorder: false,
        ),
        surfaceSize: const Size(320, 800),
      );
      await tester.pump();

      expect(find.text('Sign in to your account'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('lays out the new slots without overflow on a large desktop',
        (tester) async {
      await pumpDs(
        tester,
        DsSignInView(
          title: 'Sign in to your account',
          headingAlignment: DsHeadingAlignment.start,
          primaryAction: DsSignInAction(label: 'Sign in', onPressed: () {}),
          form: const SizedBox(height: 120),
          footerBand: const Text('New to the platform? Create an account.'),
          onClose: () {},
          showBorder: false,
        ),
        surfaceSize: const Size(1200, 900),
      );
      await tester.pump();

      expect(find.text('Sign in to your account'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

/// Matches the footer band by its structural signature, a container whose
/// border is drawn on the top edge only. The card body uses Border.all, so
/// this cannot match it, and it stays correct even in a skin where the band
/// tint equals the card background.
bool _isFooterBand(Widget w) {
  if (w is! Container) return false;
  final decoration = w.decoration;
  if (decoration is! BoxDecoration) return false;
  final border = decoration.border;
  return border is Border &&
      border.top != BorderSide.none &&
      border.bottom == BorderSide.none &&
      border.left == BorderSide.none &&
      border.right == BorderSide.none;
}
