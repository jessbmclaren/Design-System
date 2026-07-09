import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsPageScaffold', () {
    testWidgets('renders the title and body', (tester) async {
      await pumpDs(
        tester,
        const DsPageScaffold(
          title: 'Account overview',
          body: Text('Body content'),
        ),
      );

      expect(find.text('Account overview'), findsOneWidget);
      expect(find.text('Body content'), findsOneWidget);
    });

    testWidgets('renders the subtitle when provided', (tester) async {
      await pumpDs(
        tester,
        const DsPageScaffold(
          title: 'Settings',
          subtitle: 'Manage your preferences',
          body: SizedBox.shrink(),
        ),
      );

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Manage your preferences'), findsOneWidget);
    });

    testWidgets('renders header actions and fires their callbacks',
        (tester) async {
      var tapped = false;
      await pumpDs(
        tester,
        DsPageScaffold(
          title: 'Reports',
          actions: [
            DsButton(
              label: 'Export',
              onPressed: () => tapped = true,
            ),
          ],
          body: const Text('Report body'),
        ),
      );

      expect(find.text('Export'), findsOneWidget);
      await tester.tap(find.text('Export'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('renders a leading widget', (tester) async {
      await pumpDs(
        tester,
        DsPageScaffold(
          title: 'Detail',
          leading: DsBackLink(label: 'Back', onPressed: () {}),
          body: const Text('Detail body'),
        ),
      );

      expect(find.text('Back'), findsOneWidget);
      expect(find.text('Detail'), findsOneWidget);
    });

    testWidgets('does not overflow at 320dp', (tester) async {
      await pumpDs(
        tester,
        DsPageScaffold(
          title: 'Compact layout',
          subtitle: 'A supporting line that should wrap on narrow screens',
          actions: [
            DsButton(label: 'Primary', onPressed: () {}),
            DsButton(
              label: 'Secondary',
              variant: DsButtonVariant.secondary,
              onPressed: () {},
            ),
          ],
          body: const Text('Compact body'),
        ),
        surfaceSize: const Size(320, 640),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Compact layout'), findsOneWidget);
    });

    testWidgets('does not overflow at 1200dp', (tester) async {
      await pumpDs(
        tester,
        DsPageScaffold(
          title: 'Wide layout',
          actions: [
            DsButton(label: 'Action', onPressed: () {}),
          ],
          body: const Text('Wide body'),
        ),
        surfaceSize: const Size(1200, 800),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Wide layout'), findsOneWidget);
      expect(find.text('Wide body'), findsOneWidget);
    });
  });
}
