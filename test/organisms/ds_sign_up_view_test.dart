import 'package:design_system/design_system.dart';
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
  });
}
