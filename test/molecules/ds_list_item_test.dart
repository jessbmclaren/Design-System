import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsListItem', () {
    testWidgets('renders title, subtitle and leading', (tester) async {
      await pumpDs(
        tester,
        const DsListItem(
          leading: Icon(Icons.person),
          title: 'Jane Doe',
          subtitle: 'Administrator',
        ),
      );

      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('Administrator'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('omits subtitle when not provided', (tester) async {
      await pumpDs(tester, const DsListItem(title: 'Solo'));

      expect(find.text('Solo'), findsOneWidget);
      expect(find.text('Administrator'), findsNothing);
    });

    testWidgets('shows a chevron and fires onTap when tappable',
        (tester) async {
      var tapped = false;
      await pumpDs(
        tester,
        DsListItem(
          title: 'Settings',
          onTap: () => tapped = true,
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);

      await tester.tap(find.text('Settings'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('is static with no chevron when onTap is null',
        (tester) async {
      await pumpDs(tester, const DsListItem(title: 'Read only'));

      expect(find.byIcon(Icons.chevron_right), findsNothing);
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('custom trailing replaces the chevron', (tester) async {
      await pumpDs(
        tester,
        DsListItem(
          title: 'With trailing',
          trailing: const Icon(Icons.star),
          onTap: () {},
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });

    testWidgets('long title ellipsizes without overflow at 320dp',
        (tester) async {
      await pumpDs(
        tester,
        const DsListItem(
          title:
              'An extremely long list item title that would overflow a narrow phone screen if it did not ellipsize gracefully',
          subtitle:
              'And a similarly verbose subtitle that also needs to be clipped',
        ),
        surfaceSize: const Size(320, 640),
      );

      expect(tester.takeException(), isNull);
      final titleText = tester.widget<Text>(
        find.textContaining('An extremely long list item title'),
      );
      expect(titleText.overflow, TextOverflow.ellipsis);
      expect(titleText.maxLines, 1);
    });
  });
}
