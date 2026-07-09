import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsRadio', () {
    testWidgets('renders its label', (tester) async {
      await pumpDs(
        tester,
        const DsRadio<String>(
          value: 'a',
          groupValue: null,
          onChanged: null,
          label: 'Basic plan',
        ),
      );

      expect(find.text('Basic plan'), findsOneWidget);
    });

    testWidgets('reports selected state when value == groupValue',
        (tester) async {
      await pumpDs(
        tester,
        const DsRadio<String>(
          value: 'a',
          groupValue: 'a',
          onChanged: null,
          label: 'Selected',
        ),
      );

      expect(
        tester.getSemantics(find.byType(DsRadio<String>)),
        isSemantics(isChecked: true),
      );
    });

    testWidgets('is unchecked when value != groupValue', (tester) async {
      await pumpDs(
        tester,
        const DsRadio<String>(
          value: 'a',
          groupValue: 'b',
          onChanged: null,
          label: 'Not selected',
        ),
      );

      expect(
        tester.getSemantics(find.byType(DsRadio<String>)),
        isSemantics(isChecked: false),
      );
    });

    testWidgets('tapping an unselected radio calls onChanged with its value',
        (tester) async {
      String? selected;
      await pumpDs(
        tester,
        DsRadio<String>(
          value: 'a',
          groupValue: 'b',
          label: 'Option A',
          onChanged: (value) => selected = value,
        ),
      );

      await tester.tap(find.byType(DsRadio<String>));
      await tester.pump();

      expect(selected, 'a');
    });

    testWidgets('null onChanged suppresses interaction', (tester) async {
      await pumpDs(
        tester,
        const DsRadio<String>(
          value: 'a',
          groupValue: 'b',
          onChanged: null,
          label: 'Disabled',
        ),
      );

      expect(find.byType(InkWell), findsNothing);
      expect(
        tester.getSemantics(find.byType(DsRadio<String>)),
        isSemantics(isEnabled: false, hasEnabledState: true),
      );
    });

    testWidgets('error state renders the danger label colour', (tester) async {
      await pumpDs(
        tester,
        DsRadio<String>(
          value: 'a',
          groupValue: 'b',
          isError: true,
          label: 'Invalid',
          onChanged: (_) {},
        ),
      );

      final tokens = DsTokens.of(
        tester.element(find.text('Invalid')),
      );
      final text = tester.widget<Text>(find.text('Invalid'));
      expect(text.style?.color, tokens.colorDanger);
    });

    testWidgets('does not overflow at a 320x640 surface', (tester) async {
      await pumpDs(
        tester,
        DsRadio<String>(
          value: 'a',
          groupValue: 'a',
          label: 'A reasonably long radio option label that should wrap',
          onChanged: (_) {},
        ),
        surfaceSize: const Size(320, 640),
      );

      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  });
}
