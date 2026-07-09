import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  testWidgets('renders its label text', (tester) async {
    await pumpDs(tester, const DsLink(label: 'View details'));

    expect(find.text('View details'), findsOneWidget);
  });

  testWidgets('fires onPressed when tapped', (tester) async {
    var tapped = 0;
    await pumpDs(
      tester,
      DsLink(label: 'Open', onPressed: () => tapped++),
    );

    await tester.tap(find.byType(DsLink));
    await tester.pump();

    expect(tapped, 1);
  });

  testWidgets('is disabled when onPressed is null', (tester) async {
    await pumpDs(tester, const DsLink(label: 'Disabled'));

    final inkWell = tester.widget<InkWell>(find.byType(InkWell));
    expect(inkWell.onTap, isNull);
  });

  testWidgets('external appends an open-in-new glyph', (tester) async {
    await pumpDs(
      tester,
      DsLink(label: 'Docs', onPressed: () {}, external: true),
    );

    expect(find.byIcon(Icons.open_in_new), findsOneWidget);
  });

  testWidgets('renders a custom trailing icon', (tester) async {
    await pumpDs(
      tester,
      DsLink(
        label: 'More',
        onPressed: () {},
        trailingIcon: Icons.chevron_right,
      ),
    );

    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('secondary variant renders its label', (tester) async {
    await pumpDs(
      tester,
      DsLink(
        label: 'Secondary',
        onPressed: () {},
        variant: DsLinkVariant.secondary,
      ),
    );

    expect(find.text('Secondary'), findsOneWidget);
  });

  testWidgets('renders without overflow from small phone to desktop',
      (tester) async {
    await pumpDs(
      tester,
      DsLink(
        label: 'A fairly long hyperlink label that may need to ellipsize',
        onPressed: () {},
        external: true,
        trailingIcon: Icons.chevron_right,
      ),
      surfaceSize: const Size(320, 900),
    );
    expect(tester.takeException(), isNull);

    await pumpDs(
      tester,
      DsLink(
        label: 'A fairly long hyperlink label that may need to ellipsize',
        onPressed: () {},
        external: true,
        trailingIcon: Icons.chevron_right,
      ),
      surfaceSize: const Size(1200, 900),
    );
    expect(tester.takeException(), isNull);
  });
}
