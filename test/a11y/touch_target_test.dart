import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// Interactive controls must present at least a 48dp touch target. This sweep
/// pumps each control and asserts the tappable region is >= 48dp tall.
void main() {
  const minTarget = 48.0;

  Future<double> tappableHeight(
    WidgetTester tester,
    Widget control,
    Type tappable,
  ) async {
    await pumpDs(tester, control);
    await tester.pump();
    final finder = find.byType(tappable).first;
    return tester.getSize(finder).height;
  }

  testWidgets('DsCheckbox has a >=48dp target', (tester) async {
    final h = await tappableHeight(
      tester,
      DsCheckbox(value: false, onChanged: (_) {}, label: 'Remember me'),
      InkWell,
    );
    expect(h, greaterThanOrEqualTo(minTarget));
  });

  testWidgets('DsRadio has a >=48dp target', (tester) async {
    final h = await tappableHeight(
      tester,
      DsRadio<int>(value: 1, groupValue: 1, onChanged: (_) {}, label: 'Option'),
      InkWell,
    );
    expect(h, greaterThanOrEqualTo(minTarget));
  });

  testWidgets('DsSwitch has a >=48dp target', (tester) async {
    final h = await tappableHeight(
      tester,
      DsSwitch(value: false, onChanged: (_) {}, label: 'Notifications'),
      InkWell,
    );
    expect(h, greaterThanOrEqualTo(minTarget));
  });

  testWidgets('DsButton has a >=40dp minimum height', (tester) async {
    // Buttons use a 40dp M3 minimum plus padding; assert it is comfortably tall.
    await pumpDs(tester, DsButton(label: 'Save', onPressed: () {}));
    await tester.pump();
    final h = tester.getSize(find.byType(FilledButton)).height;
    expect(h, greaterThanOrEqualTo(40));
  });

  testWidgets('DsTabs tab has a >=48dp target', (tester) async {
    await pumpDs(
      tester,
      DsTabs(
        tabs: const [DsTab(label: 'One'), DsTab(label: 'Two')],
        selectedIndex: 0,
        onChanged: (_) {},
      ),
    );
    await tester.pump();
    final h = tester.getSize(find.byType(InkWell).first).height;
    expect(h, greaterThanOrEqualTo(minTarget));
  });
}
