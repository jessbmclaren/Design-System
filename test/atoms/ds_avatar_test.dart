import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  testWidgets('renders initials derived from name', (tester) async {
    await pumpDs(tester, const DsAvatar(name: 'Ada Lovelace'));

    expect(find.text('AL'), findsOneWidget);
  });

  testWidgets('falls back to a person glyph when no name or icon', (
    tester,
  ) async {
    await pumpDs(tester, const DsAvatar());

    expect(find.byIcon(DsIcons.user), findsOneWidget);
  });

  testWidgets('renders a supplied icon when there is no name', (tester) async {
    await pumpDs(tester, const DsAvatar(icon: Icons.star));

    expect(find.byIcon(Icons.star), findsOneWidget);
    expect(find.byIcon(DsIcons.user), findsNothing);
  });

  testWidgets('exposes the name as an accessible image label', (tester) async {
    await pumpDs(tester, const DsAvatar(name: 'Grace Hopper'));

    expect(
      tester.getSemantics(find.byType(DsAvatar)),
      matchesSemantics(label: 'Grace Hopper', isImage: true),
    );
  });

  testWidgets('renders without overflow at small and large sizes', (
    tester,
  ) async {
    await pumpDs(
      tester,
      const DsAvatar(name: 'Ada Lovelace', size: 96),
      surfaceSize: const Size(320, 900),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);

    await pumpDs(
      tester,
      const DsAvatar(name: 'Ada Lovelace', size: 96),
      surfaceSize: const Size(1200, 900),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
