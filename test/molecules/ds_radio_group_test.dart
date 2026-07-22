import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

const List<DsRadioOption<String>> _options = <DsRadioOption<String>>[
  DsRadioOption<String>(value: 'owner', label: 'Founder / owner'),
  DsRadioOption<String>(value: 'ops', label: 'Operations'),
  DsRadioOption<String>(value: 'finance', label: 'Finance'),
];

void main() {
  group('DsRadioGroup', () {
    testWidgets('renders every option and the optional label', (tester) async {
      await pumpDs(
        tester,
        DsRadioGroup<String>(
          label: 'What is your role?',
          options: _options,
          value: null,
          onChanged: (_) {},
        ),
      );

      expect(find.text('What is your role?'), findsOneWidget);
      for (final option in _options) {
        expect(find.text(option.label), findsOneWidget);
      }
    });

    testWidgets('tapping a row reports that value', (tester) async {
      String? chosen;
      await pumpDs(
        tester,
        DsRadioGroup<String>(
          options: _options,
          value: null,
          onChanged: (value) => chosen = value,
        ),
      );

      await tester.tap(find.text('Operations'));
      await tester.pump();
      expect(chosen, 'ops');
    });

    testWidgets('the selected row is checked in the semantics tree', (
      tester,
    ) async {
      await pumpDs(
        tester,
        DsRadioGroup<String>(
          options: _options,
          value: 'finance',
          onChanged: (_) {},
        ),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Finance')),
        matchesSemantics(
          label: 'Finance',
          isChecked: true,
          hasCheckedState: true,
          hasEnabledState: true,
          isEnabled: true,
          isInMutuallyExclusiveGroup: true,
        ),
      );
    });

    testWidgets('errorText renders beneath the list', (tester) async {
      await pumpDs(
        tester,
        DsRadioGroup<String>(
          options: _options,
          value: null,
          onChanged: (_) {},
          errorText: 'Please select your role',
        ),
      );

      expect(find.text('Please select your role'), findsOneWidget);
    });

    testWidgets('a null onChanged leaves every row inert', (tester) async {
      await pumpDs(
        tester,
        const DsRadioGroup<String>(
          options: _options,
          value: 'finance',
          onChanged: null,
        ),
      );

      // Disabled: still a radio in the group, but not enabled and offering no
      // tap action.
      expect(
        tester.getSemantics(find.bySemanticsLabel('Operations')),
        matchesSemantics(
          label: 'Operations',
          hasCheckedState: true,
          hasEnabledState: true,
          isInMutuallyExclusiveGroup: true,
        ),
      );
    });
  });
}
