import 'package:design_system/design_system.dart';
// The shared auth-card internals are deliberately not exported from the
// barrel; the dedup regression tests reach them through the src path.
import 'package:design_system/src/components/organisms/ds_auth_card_parts.dart';
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

    testWidgets('disables the primary button when the action has no callback',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        const DsSignInView(
          title: 'Welcome back',
          primaryAction: DsSignInAction(label: 'Continue', onPressed: null),
        ),
      );

      expect(
        tester.getSemantics(find.byType(DsButton)),
        isSemantics(isButton: true, isEnabled: false),
      );
      await tester.tap(find.byType(DsButton), warnIfMissed: false);
      await tester.pump();
      expect(tester.takeException(), isNull);
      handle.dispose();
    });

    testWidgets('does not fire onPressed while the action is pending',
        (tester) async {
      var taps = 0;
      await pumpDs(
        tester,
        DsSignInView(
          title: 'Welcome back',
          primaryAction: DsSignInAction(
            label: 'Continue',
            onPressed: () => taps++,
            pending: true,
          ),
        ),
      );

      // While pending the label is replaced by a spinner, so tap the button
      // itself. It ignores taps and must fire nothing.
      expect(find.byType(DsSpinner), findsOneWidget);
      await tester.tap(find.byType(DsButton), warnIfMissed: false);
      await tester.pump();

      expect(taps, 0);
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

    testWidgets('marks the title as a header for assistive technology',
        (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        DsSignInView(
          title: 'Welcome back',
          primaryAction: DsSignInAction(label: 'Continue', onPressed: () {}),
        ),
      );

      expect(
        tester.getSemantics(find.text('Welcome back')),
        isSemantics(isHeader: true),
      );
      handle.dispose();
    });

    testWidgets('insets the heading clear of the close button when onClose '
        'is set', (tester) async {
      await pumpDs(
        tester,
        DsSignInView(
          title: 'Sign in to your account',
          headingAlignment: DsHeadingAlignment.start,
          primaryAction: DsSignInAction(label: 'Sign in', onPressed: () {}),
          onClose: () {},
        ),
        surfaceSize: const Size(320, 800),
      );

      // The heading block ends before the close button's padded tap target,
      // so no title glyph can paint beneath the icon.
      final close = tester.getRect(find.byType(IconButton));
      expect(
        tester.getRect(find.text('Sign in to your account')).right,
        lessThanOrEqualTo(close.left),
      );
      final insetWidth =
          tester.getSize(find.text('Sign in to your account')).width;

      // Without a close button the heading keeps the full body width.
      await pumpDs(
        tester,
        DsSignInView(
          title: 'Sign in to your account',
          headingAlignment: DsHeadingAlignment.start,
          primaryAction: DsSignInAction(label: 'Sign in', onPressed: () {}),
        ),
        surfaceSize: const Size(320, 800),
      );
      expect(
        tester.getSize(find.text('Sign in to your account')).width,
        greaterThan(insetWidth),
      );
    });

    testWidgets('draws the footer band top border with the standard border '
        'colour and keeps the reveal divider subtle', (tester) async {
      await pumpDs(
        tester,
        DsSignInView(
          title: 'Sign in to your account',
          primaryAction: DsSignInAction(label: 'Sign in', onPressed: () {}),
          footerBand: const Text('New here?'),
          additionalContextLabel: 'More options',
          additionalContext: const Text('Enterprise SSO.'),
        ),
      );

      final tokens = DsTokens.of(tester.element(find.byType(DsSignInView)));
      final decoration = tester
          .widget<Container>(find.byWidgetPredicate(_isFooterBand))
          .decoration! as BoxDecoration;
      expect((decoration.border! as Border).top.color, tokens.colorBorder);

      // The reveal rule is a DsDivider, which paints the subtle hairline tier
      // by default.
      final rule = tester.widget<DecoratedBox>(
        find.descendant(
          of: find.byType(DsDivider),
          matching: find.byType(DecoratedBox),
        ),
      );
      expect(
        (rule.decoration as BoxDecoration).color,
        tokens.colorBorderSubtle,
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

    testWidgets('the reveal control announces its expanded state through a '
        'full expand and collapse cycle', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        DsSignInView(
          title: 'Sign in to your account',
          primaryAction: DsSignInAction(label: 'Sign in', onPressed: () {}),
          additionalContextLabel: 'More options',
          additionalContext: const Text('Enterprise SSO.'),
        ),
      );

      expect(
        tester.getSemantics(find.text('More options')),
        isSemantics(
          isButton: true,
          hasTapAction: true,
          hasExpandedState: true,
          isExpanded: false,
        ),
      );
      expect(find.text('Enterprise SSO.'), findsNothing);

      await tester.tap(find.text('More options'));
      await tester.pump();
      expect(
        tester.getSemantics(find.text('More options')),
        isSemantics(hasExpandedState: true, isExpanded: true),
      );
      expect(find.text('Enterprise SSO.'), findsOneWidget);

      await tester.tap(find.text('More options'));
      await tester.pump();
      expect(
        tester.getSemantics(find.text('More options')),
        isSemantics(hasExpandedState: true, isExpanded: false),
      );
      expect(find.text('Enterprise SSO.'), findsNothing);
      handle.dispose();
    });

    testWidgets('hosts the reveal ink on a transparent Material inside the '
        'card', (tester) async {
      await pumpDs(
        tester,
        DsSignInView(
          title: 'Sign in to your account',
          primaryAction: DsSignInAction(label: 'Sign in', onPressed: () {}),
          additionalContextLabel: 'More options',
          additionalContext: const Text('Enterprise SSO.'),
        ),
      );

      // The nearest Material above the reveal control must be the transparent
      // one inside the card; without it the ink would paint on the Scaffold's
      // material beneath the card's opaque background and never show.
      final material = tester.widget<Material>(
        find
            .ancestor(
              of: find.text('More options'),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(material.type, MaterialType.transparency);

      // The splash actually renders: pump a frame mid-ripple without error.
      await tester.tap(find.text('More options'));
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
    });

    testWidgets('renders the brand glyph in the shared auth brand mark',
        (tester) async {
      await pumpDs(
        tester,
        DsSignInView(
          title: 'Welcome back',
          brandIcon: Icons.lock_outline,
          primaryAction: DsSignInAction(label: 'Continue', onPressed: () {}),
        ),
      );

      // Dedup regression: the mark is the widget shared with DsSignUpView.
      final mark = find.byType(DsAuthBrandMark);
      expect(mark, findsOneWidget);
      expect(
        find.descendant(of: mark, matching: find.byIcon(Icons.lock_outline)),
        findsOneWidget,
      );
    });

    testWidgets('caps the card at its documented 420dp reading width',
        (tester) async {
      await pumpDs(
        tester,
        DsSignInView(
          title: 'Welcome back',
          primaryAction: DsSignInAction(label: 'Continue', onPressed: () {}),
        ),
        surfaceSize: const Size(800, 900),
      );

      final tokens = DsTokens.of(tester.element(find.byType(DsSignInView)));
      final card = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).color ==
                tokens.formBackgroundColor,
      );
      expect(tester.getSize(card).width, 420);
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
