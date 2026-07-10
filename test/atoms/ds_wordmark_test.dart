import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

String _plain(WidgetTester tester) => tester
    .widgetList<RichText>(find.byType(RichText))
    .map((r) => r.text.toPlainText())
    .firstWhere((t) => t.contains('acme'));

void main() {
  group('DsWordmark', () {
    testWidgets('renders the primary and accent parts as one mark',
        (tester) async {
      await pumpDs(tester, const DsWordmark(primary: 'acme', accent: 'id'));
      expect(_plain(tester), 'acmeid');
    });

    testWidgets('renders without an accent', (tester) async {
      await pumpDs(tester, const DsWordmark(primary: 'acme'));
      expect(_plain(tester), 'acme');
    });
  });
}
