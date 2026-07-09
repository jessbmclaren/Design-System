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
  });
}
