import 'package:design_system/design_system.dart';
// The shared auth-card internals are deliberately not exported from the
// barrel; the dedup regression tests reach them through the src path.
import 'package:design_system/src/components/organisms/ds_auth_card_parts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsSignUpView', () {
    testWidgets('renders title, description and primary action label',
        (tester) async {
      await pumpDs(
        tester,
        DsSignUpView(
          title: 'Create your workspace',
          description: 'Start your 14-day trial. No card required.',
          form: const TextField(key: Key('email')),
          primaryActionLabel: 'Create account',
          onSubmit: () {},
        ),
      );

      expect(find.text('Create your workspace'), findsOneWidget);
      expect(
        find.text('Start your 14-day trial. No card required.'),
        findsOneWidget,
      );
      expect(find.text('Create account'), findsOneWidget);
      expect(find.byKey(const Key('email')), findsOneWidget);
    });

    testWidgets('renders the brand icon and footer when supplied',
        (tester) async {
      await pumpDs(
        tester,
        DsSignUpView(
          title: 'Sign up',
          brandIcon: Icons.workspaces_outline,
          form: const SizedBox.shrink(),
          primaryActionLabel: 'Continue',
          onSubmit: () {},
          footer: const Text('Already have an account?'),
        ),
      );

      expect(find.byIcon(Icons.workspaces_outline), findsOneWidget);
      expect(find.text('Already have an account?'), findsOneWidget);
    });

    testWidgets('renders the brand glyph in the shared auth brand mark',
        (tester) async {
      await pumpDs(
        tester,
        DsSignUpView(
          title: 'Sign up',
          brandIcon: Icons.workspaces_outline,
          form: const SizedBox.shrink(),
          primaryActionLabel: 'Continue',
          onSubmit: () {},
        ),
      );

      // Dedup regression: the mark is the widget shared with DsSignInView.
      final mark = find.byType(DsAuthBrandMark);
      expect(mark, findsOneWidget);
      expect(
        find.descendant(
          of: mark,
          matching: find.byIcon(Icons.workspaces_outline),
        ),
        findsOneWidget,
      );
    });

    testWidgets('caps the card at its documented 440dp reading width',
        (tester) async {
      await pumpDs(
        tester,
        DsSignUpView(
          title: 'Sign up',
          form: const SizedBox.shrink(),
          primaryActionLabel: 'Continue',
          onSubmit: () {},
        ),
        surfaceSize: const Size(800, 900),
      );

      final tokens = DsTokens.of(tester.element(find.byType(DsSignUpView)));
      final card = find.byWidgetPredicate(
        (w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration! as BoxDecoration).color ==
                tokens.formBackgroundColor,
      );
      expect(tester.getSize(card).width, 440);
    });

    testWidgets('fires onSubmit when the primary button is tapped',
        (tester) async {
      var submitted = 0;
      await pumpDs(
        tester,
        DsSignUpView(
          title: 'Sign up',
          form: const SizedBox.shrink(),
          primaryActionLabel: 'Create account',
          onSubmit: () => submitted++,
        ),
      );

      await tester.tap(find.text('Create account'));
      await tester.pump();

      expect(submitted, 1);
    });

    testWidgets('does not fire onSubmit while submit is pending',
        (tester) async {
      var submitted = 0;
      await pumpDs(
        tester,
        DsSignUpView(
          title: 'Sign up',
          form: const SizedBox.shrink(),
          primaryActionLabel: 'Create account',
          submitPending: true,
          onSubmit: () => submitted++,
        ),
      );

      // While pending the label is replaced by a spinner, so tap the button
      // itself — it is disabled and must fire nothing.
      await tester.tap(find.byType(DsButton), warnIfMissed: false);
      await tester.pump();

      expect(submitted, 0);
    });

    testWidgets('lays out without overflow on a small phone', (tester) async {
      await pumpDs(
        tester,
        DsSignUpView(
          title: 'Create your workspace',
          description: 'Start your 14-day trial.',
          brandIcon: Icons.workspaces_outline,
          form: const SizedBox(height: 120),
          primaryActionLabel: 'Create account',
          onSubmit: () {},
          aside: const Text('Marketing benefits panel'),
          footer: const Text('Already have an account?'),
        ),
        surfaceSize: const Size(320, 900),
      );
      await tester.pump();

      expect(find.text('Create your workspace'), findsOneWidget);
      expect(find.text('Marketing benefits panel'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('lays out without overflow on a large desktop',
        (tester) async {
      await pumpDs(
        tester,
        DsSignUpView(
          title: 'Create your workspace',
          description: 'Start your 14-day trial.',
          brandIcon: Icons.workspaces_outline,
          form: const SizedBox(height: 120),
          primaryActionLabel: 'Create account',
          onSubmit: () {},
          aside: const Text('Marketing benefits panel'),
          footer: const Text('Already have an account?'),
        ),
        surfaceSize: const Size(1200, 900),
      );
      await tester.pump();

      expect(find.text('Create your workspace'), findsOneWidget);
      expect(find.text('Marketing benefits panel'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders the header in place of the brand icon',
        (tester) async {
      await pumpDs(
        tester,
        DsSignUpView(
          title: 'Sign up',
          brandIcon: Icons.workspaces_outline,
          header: const DsWordmark(primary: 'acme', accent: 'id'),
          form: const SizedBox.shrink(),
          primaryActionLabel: 'Continue',
          onSubmit: () {},
        ),
      );

      expect(find.byType(DsWordmark), findsOneWidget);
      expect(find.byIcon(Icons.workspaces_outline), findsNothing);
    });

    testWidgets('renders aboveForm between the description and the form',
        (tester) async {
      await pumpDs(
        tester,
        DsSignUpView(
          title: 'Sign up',
          description: 'Takes seconds.',
          aboveForm: const Text('Already have an account?'),
          form: const TextField(key: Key('email')),
          primaryActionLabel: 'Continue',
          onSubmit: () {},
        ),
      );

      final promptY =
          tester.getTopLeft(find.text('Already have an account?')).dy;
      expect(
        promptY,
        greaterThan(tester.getTopLeft(find.text('Takes seconds.')).dy),
      );
      expect(
        promptY,
        lessThan(tester.getTopLeft(find.byKey(const Key('email'))).dy),
      );
    });

    testWidgets('start-aligns the heading by default and centres it on request',
        (tester) async {
      await pumpDs(
        tester,
        DsSignUpView(
          title: 'Sign up',
          form: const SizedBox.shrink(),
          primaryActionLabel: 'Continue',
          onSubmit: () {},
        ),
      );

      expect(
        tester.widget<Text>(find.text('Sign up')).textAlign,
        TextAlign.start,
      );

      await pumpDs(
        tester,
        DsSignUpView(
          title: 'Sign up',
          headingAlignment: DsHeadingAlignment.center,
          form: const SizedBox.shrink(),
          primaryActionLabel: 'Continue',
          onSubmit: () {},
        ),
      );

      expect(
        tester.widget<Text>(find.text('Sign up')).textAlign,
        TextAlign.center,
      );
    });

    testWidgets('shows a labelled close button that fires onClose',
        (tester) async {
      var closed = 0;
      await pumpDs(
        tester,
        DsSignUpView(
          title: 'Sign up',
          form: const SizedBox.shrink(),
          primaryActionLabel: 'Continue',
          onSubmit: () {},
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
        DsSignUpView(
          title: 'Sign up',
          form: const SizedBox.shrink(),
          primaryActionLabel: 'Continue',
          onSubmit: () {},
        ),
      );

      expect(find.byType(DsIconButton), findsNothing);
    });

    testWidgets('insets the heading clear of the close button when onClose '
        'is set', (tester) async {
      await pumpDs(
        tester,
        DsSignUpView(
          title: 'Create your account',
          description: 'Start your 14-day trial.',
          form: const SizedBox.shrink(),
          primaryActionLabel: 'Continue',
          onSubmit: () {},
          onClose: () {},
        ),
        surfaceSize: const Size(320, 800),
      );

      // The heading block ends before the close button's padded tap target,
      // so no title or description glyph can paint beneath the icon.
      final close = tester.getRect(find.byType(IconButton));
      expect(
        tester.getRect(find.text('Create your account')).right,
        lessThanOrEqualTo(close.left),
      );
      expect(
        tester.getRect(find.text('Start your 14-day trial.')).right,
        lessThanOrEqualTo(close.left),
      );
      final insetWidth = tester.getSize(find.text('Create your account')).width;

      // Without a close button the heading keeps the full body width.
      await pumpDs(
        tester,
        DsSignUpView(
          title: 'Create your account',
          description: 'Start your 14-day trial.',
          form: const SizedBox.shrink(),
          primaryActionLabel: 'Continue',
          onSubmit: () {},
        ),
        surfaceSize: const Size(320, 800),
      );
      expect(
        tester.getSize(find.text('Create your account')).width,
        greaterThan(insetWidth),
      );
    });

    testWidgets('draws the card border by default and drops it on request',
        (tester) async {
      BoxDecoration cardDecoration() {
        final tokens = DsTokens.of(tester.element(find.byType(DsSignUpView)));
        return tester
            .widgetList<Container>(find.byType(Container))
            .map((c) => c.decoration)
            .whereType<BoxDecoration>()
            .singleWhere((d) => d.color == tokens.formBackgroundColor);
      }

      await pumpDs(
        tester,
        DsSignUpView(
          title: 'Sign up',
          form: const SizedBox.shrink(),
          primaryActionLabel: 'Continue',
          onSubmit: () {},
        ),
      );
      expect(cardDecoration().border, isNotNull);

      await pumpDs(
        tester,
        DsSignUpView(
          title: 'Sign up',
          showBorder: false,
          form: const SizedBox.shrink(),
          primaryActionLabel: 'Continue',
          onSubmit: () {},
        ),
      );
      expect(cardDecoration().border, isNull);
    });

    testWidgets('lays out the new slots without overflow on a small phone',
        (tester) async {
      await pumpDs(
        tester,
        DsSignUpView(
          title: 'Seconds to sign up!',
          headingAlignment: DsHeadingAlignment.center,
          header: const DsWordmark(primary: 'acme', accent: 'id'),
          aboveForm: const Text('Already have an account?'),
          form: const SizedBox(height: 120),
          primaryActionLabel: 'Sign up with Email',
          onSubmit: () {},
          footer: const Text('Terms apply'),
          onClose: () {},
          showBorder: false,
        ),
        surfaceSize: const Size(320, 900),
      );
      await tester.pump();

      expect(find.text('Seconds to sign up!'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('lays out the new slots without overflow on a large desktop',
        (tester) async {
      await pumpDs(
        tester,
        DsSignUpView(
          title: 'Seconds to sign up!',
          headingAlignment: DsHeadingAlignment.center,
          header: const DsWordmark(primary: 'acme', accent: 'id'),
          aboveForm: const Text('Already have an account?'),
          form: const SizedBox(height: 120),
          primaryActionLabel: 'Sign up with Email',
          onSubmit: () {},
          footer: const Text('Terms apply'),
          aside: const Text('Marketing benefits panel'),
          onClose: () {},
          showBorder: false,
        ),
        surfaceSize: const Size(1200, 900),
      );
      await tester.pump();

      expect(find.text('Seconds to sign up!'), findsOneWidget);
      expect(find.text('Marketing benefits panel'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
