import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  const entries = [
    DsStatusLegendEntry(
      label: 'Ready',
      description: 'The licence is active and up to date.',
      variant: DsBadgeVariant.success,
    ),
    DsStatusLegendEntry(
      label: 'Needs attention',
      description: 'Something is missing or expiring soon.',
      variant: DsBadgeVariant.warning,
    ),
    DsStatusLegendEntry(
      label: 'Expired',
      description: 'The licence has lapsed and must be renewed.',
      variant: DsBadgeVariant.danger,
    ),
  ];

  testWidgets('renders the title above the entries', (tester) async {
    await pumpDs(
      tester,
      DsStatusLegend(title: 'Statuses explained', entries: entries),
    );

    expect(find.text('Statuses explained'), findsOneWidget);
  });

  testWidgets('renders every entry label and description', (tester) async {
    await pumpDs(tester, DsStatusLegend(entries: entries));

    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('The licence is active and up to date.'), findsOneWidget);
    expect(find.text('Needs attention'), findsOneWidget);
    expect(find.text('Something is missing or expiring soon.'), findsOneWidget);
    expect(find.text('Expired'), findsOneWidget);
    expect(
      find.text('The licence has lapsed and must be renewed.'),
      findsOneWidget,
    );
  });

  testWidgets('renders each status as a badge', (tester) async {
    await pumpDs(tester, DsStatusLegend(entries: entries));

    expect(find.widgetWithText(DsBadge, 'Ready'), findsOneWidget);
    expect(find.widgetWithText(DsBadge, 'Needs attention'), findsOneWidget);
    expect(find.widgetWithText(DsBadge, 'Expired'), findsOneWidget);
  });

  testWidgets('renders without overflow on a small phone', (tester) async {
    await pumpDs(
      tester,
      DsStatusLegend(title: 'Statuses explained', entries: entries),
      surfaceSize: const Size(320, 640),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders without overflow on a large desktop', (tester) async {
    await pumpDs(
      tester,
      DsStatusLegend(title: 'Statuses explained', entries: entries),
      surfaceSize: const Size(1440, 900),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'a long status name gives way instead of overflowing a padded '
      '320dp screen', (tester) async {
    await pumpDs(
      tester,
      SizedBox(
        width: 288,
        child: DsStatusLegend(
          title: 'Statuses explained',
          entries: const [
            DsStatusLegendEntry(
              label: 'Temporarily unavailable',
              description:
                  'Driver is unavailable for assignments for a period of time.',
            ),
          ],
        ),
      ),
      surfaceSize: const Size(320, 640),
    );

    expect(tester.takeException(), isNull);
  });
}
