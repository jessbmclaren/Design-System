import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// A record's history: what happened, when, and who did it.
void main() {
  const entries = <DsTimelineEntry>[
    DsTimelineEntry(
      title: 'Status changed to Active',
      meta: '24 Jul 2026 · Jess McLaren',
    ),
    DsTimelineEntry(
      title: 'Tank capacity changed',
      meta: '18 Jul 2026 · Sam Nkosi',
      detail: '80 litres → 90 litres',
    ),
    DsTimelineEntry(title: 'Vehicle created', meta: '03 Jul 2026 · Sam Nkosi'),
  ];

  testWidgets('every entry states what happened, when, and who', (
    tester,
  ) async {
    await pumpDs(tester, const SizedBox(width: 520, child: DsTimeline(entries: entries)));
    for (final DsTimelineEntry e in entries) {
      expect(find.text(e.title), findsOneWidget);
      if (e.meta != null) expect(find.text(e.meta!), findsOneWidget);
    }
    expect(find.text('80 litres → 90 litres'), findsOneWidget);
  });

  testWidgets('an entry reads as one phrase, not three separate stops', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpDs(tester, const SizedBox(width: 520, child: DsTimeline(entries: entries)));
    expect(
      find.bySemanticsLabel(
        RegExp('Vehicle created.*03 Jul 2026', dotAll: true),
      ),
      findsOneWidget,
    );
    handle.dispose();
  });

  testWidgets('the rule stops at the last entry — a history must not imply '
      'more below the fold', (tester) async {
    // Someone deciding whether a record was tampered with needs to know they
    // have reached the end of it. A line running past the final marker is the
    // one thing this component must never say.
    await pumpDs(
      tester,
      const SizedBox(width: 520, child: DsTimeline(entries: entries)),
    );
    // Three entries, two connectors.
    expect(
      find.descendant(
        of: find.byType(DsTimeline),
        matching: find.byType(Expanded),
      ),
      findsNWidgets(2 + entries.length),
      reason: 'one connector between each pair, and one content column per '
          'entry',
    );
  });

  testWidgets('a single entry renders no rule at all', (tester) async {
    await pumpDs(
      tester,
      const SizedBox(
        width: 520,
        child: DsTimeline(
          entries: <DsTimelineEntry>[DsTimelineEntry(title: 'Vehicle created')],
        ),
      ),
    );
    expect(find.text('Vehicle created'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('no entries renders nothing rather than an empty rule — an '
      'empty state is the caller\'s to write', (tester) async {
    await pumpDs(tester, const DsTimeline(entries: <DsTimelineEntry>[]));
    expect(
      tester.getSize(find.byType(DsTimeline)),
      Size.zero,
    );
  });

  testWidgets('it survives a phone width and a long entry title', (
    tester,
  ) async {
    await pumpDs(
      tester,
      const SizedBox(
        width: 320,
        child: DsTimeline(
          entries: <DsTimelineEntry>[
            DsTimelineEntry(
              title: 'Vehicle type changed to Heavy Commercial Vehicle '
                  '(≤8 ton)',
              meta: '18 Jul 2026 · Sam Nkosi',
            ),
            DsTimelineEntry(title: 'Vehicle created'),
          ],
        ),
      ),
      surfaceSize: const Size(360, 720),
    );
    expect(tester.takeException(), isNull);
  });
}
