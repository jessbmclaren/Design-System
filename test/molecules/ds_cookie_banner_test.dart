import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsCookieBanner', () {
    testWidgets('renders the message and fires all three actions',
        (tester) async {
      var accepted = 0;
      var rejected = 0;
      var managed = 0;
      await pumpDs(
        tester,
        SizedBox(
          width: 700,
          child: DsCookieBanner(
            message: 'We use cookies to keep your account secure.',
            onAcceptAll: () => accepted++,
            onRejectNonEssential: () => rejected++,
            onManagePreferences: () => managed++,
          ),
        ),
      );

      expect(
        find.text('We use cookies to keep your account secure.'),
        findsOneWidget,
      );
      await tester.tap(find.text('Accept all'));
      await tester.tap(find.text('Reject non-essential'));
      await tester.tap(find.text('Manage preferences'));
      await tester.pump();
      expect(accepted, 1);
      expect(rejected, 1);
      expect(managed, 1);
    });

    testWidgets('keeps the message and actions on one row when wide',
        (tester) async {
      // Short labels: the test font renders every glyph at the full font
      // size, so the default labels are far wider than in production.
      await pumpDs(
        tester,
        SizedBox(
          width: 1100,
          child: DsCookieBanner(
            message: 'We use cookies.',
            acceptAllLabel: 'Accept',
            rejectLabel: 'Reject',
            preferencesLabel: 'Manage',
            onAcceptAll: () {},
            onRejectNonEssential: () {},
            onManagePreferences: () {},
          ),
        ),
        surfaceSize: const Size(1200, 800),
      );

      final accept = tester.getCenter(find.text('Accept'));
      final reject = tester.getCenter(find.text('Reject'));
      final manage = tester.getCenter(find.text('Manage'));
      final message = tester.getCenter(find.text('We use cookies.'));
      expect((accept.dy - reject.dy).abs(), lessThan(1));
      expect((reject.dy - manage.dy).abs(), lessThan(1));
      expect((message.dy - accept.dy).abs(), lessThan(1));
      expect(message.dx, lessThan(manage.dx));
    });

    testWidgets('stacks the actions full-width when its own width is narrow',
        (tester) async {
      await pumpDs(
        tester,
        SizedBox(
          width: 360,
          child: DsCookieBanner(
            message: 'We use cookies.',
            onAcceptAll: () {},
            onRejectNonEssential: () {},
            onManagePreferences: () {},
          ),
        ),
      );

      final accept = tester.getCenter(find.text('Accept all'));
      final reject = tester.getCenter(find.text('Reject non-essential'));
      final manage = tester.getCenter(find.text('Manage preferences'));
      // Primary first, then reject, then the quiet preferences action, all
      // sharing one centre line.
      expect(accept.dy, lessThan(reject.dy));
      expect(reject.dy, lessThan(manage.dy));
      expect((accept.dx - reject.dx).abs(), lessThan(1));
      expect((reject.dx - manage.dx).abs(), lessThan(1));
    });

    testWidgets('a null callback disables that action', (tester) async {
      await pumpDs(
        tester,
        SizedBox(
          width: 700,
          child: DsCookieBanner(
            message: 'We use cookies.',
            onRejectNonEssential: () {},
            onManagePreferences: () {},
          ),
        ),
      );

      final accept = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Accept all'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(accept.onPressed, isNull);
    });

    testWidgets('is a polite live region', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpDs(
        tester,
        SizedBox(
          width: 700,
          child: DsCookieBanner(
            message: 'We use cookies.',
            onAcceptAll: () {},
            onRejectNonEssential: () {},
            onManagePreferences: () {},
          ),
        ),
      );

      expect(
        tester.getSemantics(find.byType(DsCookieBanner)),
        isSemantics(isLiveRegion: true),
      );
      handle.dispose();
    });

    testWidgets('renders a message widget in place of the string',
        (tester) async {
      await pumpDs(
        tester,
        SizedBox(
          width: 700,
          child: DsCookieBanner(
            messageWidget: const Text('Custom consent copy'),
            onAcceptAll: () {},
            onRejectNonEssential: () {},
            onManagePreferences: () {},
          ),
        ),
      );

      expect(find.text('Custom consent copy'), findsOneWidget);
    });

    testWidgets('asserts on both or neither message forms', (tester) async {
      expect(
        () => DsCookieBanner(
          message: 'x',
          messageWidget: const SizedBox(),
          onAcceptAll: () {},
          onRejectNonEssential: () {},
          onManagePreferences: () {},
        ),
        throwsAssertionError,
      );
      expect(
        () => DsCookieBanner(
          onAcceptAll: () {},
          onRejectNonEssential: () {},
          onManagePreferences: () {},
        ),
        throwsAssertionError,
      );
    });

    testWidgets('does not overflow at 320dp', (tester) async {
      await pumpDs(
        tester,
        DsCookieBanner(
          message: 'We use cookies to keep your account secure, to remember '
              'your settings and to understand how the product is used.',
          onAcceptAll: () {},
          onRejectNonEssential: () {},
          onManagePreferences: () {},
        ),
        surfaceSize: const Size(320, 640),
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
          DsCookieBanner(
            message: 'We use cookies.',
            onAcceptAll: () {},
            onRejectNonEssential: () {},
            onManagePreferences: () {},
          ),
          theme: entry.value,
        );
        expect(tester.takeException(), isNull, reason: entry.key);
        expect(find.text('We use cookies.'), findsOneWidget,
            reason: entry.key);
      }
    });

    testWidgets('does not overflow on a wide desktop', (tester) async {
      await pumpDs(
        tester,
        DsCookieBanner(
          message: 'We use cookies.',
          onAcceptAll: () {},
          onRejectNonEssential: () {},
          onManagePreferences: () {},
        ),
        surfaceSize: const Size(1920, 600),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
