import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  final now = DateTime(2026, 7, 22);

  testWidgets('renders the formatted date and its relative hint',
      (tester) async {
    await pumpDs(tester, DsExpiryDate(date: DateTime(2027, 8, 12), now: now));

    expect(find.text('12 Aug 2027'), findsOneWidget);
    expect(find.text('in 13 months'), findsOneWidget);
  });

  testWidgets('counts in days when the date is under a month away',
      (tester) async {
    await pumpDs(tester, DsExpiryDate(date: DateTime(2026, 8, 8), now: now));

    expect(find.text('in 17 days'), findsOneWidget);
  });

  testWidgets('counts in months between a month and eighteen months out',
      (tester) async {
    await pumpDs(tester, DsExpiryDate(date: DateTime(2026, 9, 21), now: now));

    expect(find.text('in 2 months'), findsOneWidget);
  });

  testWidgets('counts in years beyond eighteen months', (tester) async {
    await pumpDs(tester, DsExpiryDate(date: DateTime(2028, 7, 22), now: now));

    expect(find.text('in 2 years'), findsOneWidget);
  });

  testWidgets('says today when the date is the reference day', (tester) async {
    await pumpDs(tester, DsExpiryDate(date: DateTime(2026, 7, 22), now: now));

    expect(find.text('today'), findsOneWidget);
  });

  testWidgets('says expired ago once the date has passed', (tester) async {
    await pumpDs(tester, DsExpiryDate(date: DateTime(2026, 7, 19), now: now));

    expect(find.text('expired 3 days ago'), findsOneWidget);
  });

  testWidgets('the hint turns the danger colour inside the urgent window',
      (tester) async {
    await pumpDs(tester, DsExpiryDate(date: DateTime(2026, 8, 8), now: now));

    final tokens = DsTokens.of(tester.element(find.byType(DsExpiryDate)));
    final hint = tester.widget<Text>(find.text('in 17 days'));
    expect(hint.style?.color, tokens.colorDanger);
  });

  testWidgets('the hint keeps the secondary colour when the date is far out',
      (tester) async {
    await pumpDs(tester, DsExpiryDate(date: DateTime(2027, 8, 12), now: now));

    final tokens = DsTokens.of(tester.element(find.byType(DsExpiryDate)));
    final hint = tester.widget<Text>(find.text('in 13 months'));
    expect(hint.style?.color, tokens.colorSecondaryText);
  });

  testWidgets('an expired date renders its hint in the danger colour',
      (tester) async {
    await pumpDs(tester, DsExpiryDate(date: DateTime(2026, 7, 19), now: now));

    final tokens = DsTokens.of(tester.element(find.byType(DsExpiryDate)));
    final hint = tester.widget<Text>(find.text('expired 3 days ago'));
    expect(hint.style?.color, tokens.colorDanger);
  });

  testWidgets('a wider urgentWithin makes a far-out date urgent',
      (tester) async {
    await pumpDs(
      tester,
      DsExpiryDate(
        date: DateTime(2027, 8, 12),
        now: now,
        urgentWithin: const Duration(days: 400),
      ),
    );

    final tokens = DsTokens.of(tester.element(find.byType(DsExpiryDate)));
    final hint = tester.widget<Text>(find.text('in 13 months'));
    expect(hint.style?.color, tokens.colorDanger);
  });

  testWidgets('renders without overflow on a small phone', (tester) async {
    await pumpDs(
      tester,
      DsExpiryDate(date: DateTime(2027, 8, 12), now: now),
      surfaceSize: const Size(320, 640),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders without overflow on a large desktop', (tester) async {
    await pumpDs(
      tester,
      DsExpiryDate(date: DateTime(2027, 8, 12), now: now),
      surfaceSize: const Size(1440, 900),
    );

    expect(tester.takeException(), isNull);
  });

  test('formatDate renders day, abbreviated month and year', () {
    expect(DsExpiryDate.formatDate(DateTime(2027, 8, 12)), '12 Aug 2027');
    expect(DsExpiryDate.formatDate(DateTime(2026, 1, 1)), '1 Jan 2026');
  });

  test('relativeLabel uses the singular for one day either side', () {
    expect(DsExpiryDate.relativeLabel(DateTime(2026, 7, 23), now), 'in 1 day');
    expect(
      DsExpiryDate.relativeLabel(DateTime(2026, 7, 21), now),
      'expired 1 day ago',
    );
  });

  test('relativeLabel switches from days to months at thirty days', () {
    expect(
      DsExpiryDate.relativeLabel(DateTime(2026, 8, 20), now),
      'in 29 days',
    );
    expect(
      DsExpiryDate.relativeLabel(DateTime(2026, 8, 21), now),
      'in 1 month',
    );
  });
}
