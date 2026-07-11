import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

const _essential = DsCookieCategory(
  id: 'essential',
  title: 'Essential',
  description: 'Required for security and sign-in.',
  enabled: true,
  locked: true,
);

const _analytics = DsCookieCategory(
  id: 'analytics',
  title: 'Analytics',
  description: 'Help us understand how the product is used.',
);

const _marketing = DsCookieCategory(
  id: 'marketing',
  title: 'Marketing',
  description: 'Personalise the content and offers you see.',
);

void main() {
  group('DsCookiePreferences', () {
    testWidgets('renders the title, description and category rows',
        (tester) async {
      await pumpDs(
        tester,
        DsCookiePreferences(
          categories: const [_essential, _analytics],
          onChanged: (_, _) {},
          description: 'Change this anytime from Cookie settings.',
        ),
      );

      expect(find.text('Cookie preferences'), findsOneWidget);
      expect(
        find.text('Change this anytime from Cookie settings.'),
        findsOneWidget,
      );
      expect(find.text('Essential'), findsOneWidget);
      expect(find.text('Analytics'), findsOneWidget);
      expect(
        find.text('Help us understand how the product is used.'),
        findsOneWidget,
      );
    });

    testWidgets('reports a toggle through onChanged with the category id',
        (tester) async {
      final changes = <(String, bool)>[];
      await pumpDs(
        tester,
        DsCookiePreferences(
          categories: const [_essential, _analytics],
          onChanged: (id, enabled) => changes.add((id, enabled)),
        ),
      );

      await tester.tap(find.byType(DsSwitch));
      await tester.pump();
      expect(changes, [('analytics', true)]);
    });

    testWidgets('a locked row renders a badge instead of a switch and '
        'announces always on', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        DsCookiePreferences(
          categories: const [_essential, _analytics],
          onChanged: (_, _) {},
        ),
      );

      // One switch for the single unlocked category; the locked row carries
      // the always-on badge.
      expect(find.byType(DsSwitch), findsOneWidget);
      expect(find.byType(DsBadge), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(DsBadge)).label,
        contains('Always on'),
      );
      handle.dispose();
    });

    testWidgets('fires the save and accept-all actions', (tester) async {
      var saved = 0;
      var accepted = 0;
      await pumpDs(
        tester,
        DsCookiePreferences(
          categories: const [_essential, _analytics],
          onChanged: (_, _) {},
          onSave: () => saved++,
          onAcceptAll: () => accepted++,
        ),
      );

      await tester.tap(find.text('Save preferences'));
      await tester.tap(find.text('Accept all'));
      await tester.pump();
      expect(saved, 1);
      expect(accepted, 1);
    });

    testWidgets('a null onChanged disables every switch', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        const DsCookiePreferences(
          categories: [_essential, _analytics],
          onChanged: null,
        ),
      );

      expect(
        tester.getSemantics(find.byType(DsSwitch)),
        isSemantics(hasEnabledState: true, isEnabled: false),
      );
      handle.dispose();
    });

    testWidgets('shows a close button only when onClose is provided',
        (tester) async {
      var closed = 0;
      await pumpDs(
        tester,
        DsCookiePreferences(
          categories: const [_essential],
          onChanged: (_, _) {},
          onClose: () => closed++,
        ),
      );

      await tester.tap(find.byTooltip('Close'));
      await tester.pump();
      expect(closed, 1);

      await pumpDs(
        tester,
        DsCookiePreferences(
          categories: const [_essential],
          onChanged: (_, _) {},
        ),
      );
      expect(find.byTooltip('Close'), findsNothing);
    });

    testWidgets('keyboard traversal reaches every action', (tester) async {
      final changes = <(String, bool)>[];
      var saved = 0;
      var accepted = 0;
      var closed = 0;
      await pumpDs(
        tester,
        DsCookiePreferences(
          categories: const [_essential, _analytics, _marketing],
          onChanged: (id, enabled) => changes.add((id, enabled)),
          onSave: () => saved++,
          onAcceptAll: () => accepted++,
          onClose: () => closed++,
        ),
        surfaceSize: const Size(800, 900),
      );

      // Tab through every focusable control (close, two switches, accept
      // all, save) activating each; every action must be reachable and
      // fire from the keyboard.
      for (var i = 0; i < 5; i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
      }

      expect(closed, 1);
      expect(changes.map((c) => c.$1).toSet(), {'analytics', 'marketing'});
      expect(accepted, 1);
      expect(saved, 1);
    });

    testWidgets('does not overflow at 320dp', (tester) async {
      await pumpDs(
        tester,
        DsCookiePreferences(
          categories: const [_essential, _analytics, _marketing],
          onChanged: (_, _) {},
          onSave: () {},
          onAcceptAll: () {},
          description: 'Choose which cookies this product can use. You can '
              'change this anytime from Cookie settings.',
        ),
        surfaceSize: const Size(320, 900),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Cookie preferences'), findsOneWidget);
    });

    testWidgets('does not overflow on a wide desktop', (tester) async {
      await pumpDs(
        tester,
        DsCookiePreferences(
          categories: const [_essential, _analytics, _marketing],
          onChanged: (_, _) {},
          onSave: () {},
          onAcceptAll: () {},
        ),
        surfaceSize: const Size(1920, 1080),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders under the dark and skinned themes', (tester) async {
      final themes = <String, ThemeData>{
        'dark': DsTheme.dark(),
        'engen': DsTheme.light(tokens: DsSkins.engenLight()),
      };
      for (final entry in themes.entries) {
        await pumpDs(
          tester,
          DsCookiePreferences(
            categories: const [_essential, _analytics],
            onChanged: (_, _) {},
            onSave: () {},
          ),
          theme: entry.value,
        );
        expect(tester.takeException(), isNull, reason: entry.key);
        expect(find.text('Cookie preferences'), findsOneWidget,
            reason: entry.key);
      }
    });

    testWidgets('renders inside a DsTakeover without stealing background '
        'semantics', (tester) async {
      await pumpDs(
        tester,
        SizedBox(
          width: 700,
          height: 560,
          child: DsTakeover(
            background: const Text('Page behind'),
            child: DsCookiePreferences(
              categories: const [_essential, _analytics],
              onChanged: (_, _) {},
              onSave: () {},
            ),
          ),
        ),
      );

      expect(find.text('Cookie preferences'), findsOneWidget);
      expect(find.text('Page behind'), findsOneWidget);
    });
  });
}
