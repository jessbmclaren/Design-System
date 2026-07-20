import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

const List<DsChipOption<String>> _options = <DsChipOption<String>>[
  DsChipOption<String>(value: 'mon', label: 'Monday'),
  DsChipOption<String>(value: 'tue', label: 'Tuesday'),
  DsChipOption<String>(value: 'wed', label: 'Wednesday'),
];

void main() {
  group('DsChoiceChip', () {
    testWidgets('is a checkbox reporting its state and name', (tester) async {
      await pumpDs(
        tester,
        DsChoiceChip(label: 'Monday', selected: true, onSelected: (_) {}),
      );

      expect(
        tester.getSemantics(find.bySemanticsLabel('Monday')),
        matchesSemantics(
          label: 'Monday',
          isChecked: true,
          hasCheckedState: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          isFocusable: true,
          hasFocusAction: true,
        ),
      );
    });

    testWidgets('toggling reports the opposite state', (tester) async {
      bool? next;
      await pumpDs(
        tester,
        DsChoiceChip(
          label: 'Monday',
          selected: false,
          onSelected: (bool value) => next = value,
        ),
      );

      await tester.tap(find.text('Monday'));
      await tester.pump();
      expect(next, isTrue);
    });

    testWidgets('activates from the keyboard', (tester) async {
      bool? next;
      await pumpDs(
        tester,
        DsChoiceChip(
          label: 'Monday',
          selected: true,
          onSelected: (bool value) => next = value,
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(next, isFalse);
    });

    testWidgets('the remove affordance has its own name and fires', (
      tester,
    ) async {
      bool removed = false;
      await pumpDs(
        tester,
        DsChoiceChip(
          label: 'Monday',
          onSelected: (_) {},
          onRemoved: () => removed = true,
        ),
      );

      await tester.tap(find.bySemanticsLabel('Remove Monday'));
      await tester.pump();
      expect(removed, isTrue);
    });

    testWidgets('a disabled chip leaves the focus order', (tester) async {
      await pumpDs(
        tester,
        Column(
          children: <Widget>[
            const DsChoiceChip(label: 'Monday', enabled: false),
            TextButton(onPressed: () {}, child: const Text('After')),
          ],
        ),
      );

      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      expect(Focus.of(tester.element(find.text('After'))).hasFocus, isTrue);
    });

    testWidgets('holds a 48dp target', (tester) async {
      await pumpDs(
        tester,
        DsChoiceChip(label: 'Monday', onSelected: (_) {}),
      );
      expect(
        tester.getSize(find.bySemanticsLabel('Monday')).height,
        greaterThanOrEqualTo(48),
      );
    });
  });

  group('DsChipGroup', () {
    testWidgets('renders every option and marks the chosen ones', (
      tester,
    ) async {
      await pumpDs(
        tester,
        DsChipGroup<String>(
          options: _options,
          selected: const <String>{'tue'},
          onChanged: (_) {},
        ),
        surfaceSize: const Size(500, 400),
      );

      expect(find.text('Monday'), findsOneWidget);
      expect(find.text('Wednesday'), findsOneWidget);
      expect(
        tester.getSemantics(find.bySemanticsLabel('Tuesday')),
        matchesSemantics(
          label: 'Tuesday',
          isChecked: true,
          hasCheckedState: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
          isFocusable: true,
          hasFocusAction: true,
        ),
      );
    });

    testWidgets('toggling reports a new set without mutating the old', (
      tester,
    ) async {
      const Set<String> original = <String>{'tue'};
      Set<String>? reported;
      await pumpDs(
        tester,
        DsChipGroup<String>(
          options: _options,
          selected: original,
          onChanged: (Set<String> next) => reported = next,
        ),
        surfaceSize: const Size(500, 400),
      );

      await tester.tap(find.text('Monday'));
      await tester.pump();
      expect(reported, <String>{'tue', 'mon'});
      expect(original, <String>{'tue'});

      await tester.tap(find.text('Tuesday'));
      await tester.pump();
      expect(reported, isEmpty);
    });

    testWidgets('shows an error beneath the chips', (tester) async {
      await pumpDs(
        tester,
        DsChipGroup<String>(
          options: _options,
          selected: const <String>{},
          onChanged: (_) {},
          errorText: 'Choose at least one day',
        ),
        surfaceSize: const Size(500, 400),
      );
      expect(find.text('Choose at least one day'), findsOneWidget);
    });

    testWidgets('a null onChanged leaves every chip inert', (tester) async {
      await pumpDs(
        tester,
        const DsChipGroup<String>(
          options: _options,
          selected: <String>{'tue'},
          onChanged: null,
        ),
        surfaceSize: const Size(500, 400),
      );
      await tester.tap(find.text('Monday'), warnIfMissed: false);
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('wraps at 320dp in every theme, and at 1.3x text', (
      tester,
    ) async {
      for (final ThemeData theme in <ThemeData>[
        DsTheme.light(),
        DsTheme.dark(),
        DsTheme.light(tokens: DsSkins.engenLight()),
      ]) {
        await pumpDs(
          tester,
          DsChipGroup<String>(
            options: _options,
            selected: const <String>{'mon'},
            onChanged: (_) {},
            errorText: 'Choose at least one day',
          ),
          surfaceSize: const Size(320, 600),
          theme: theme,
        );
        expect(tester.takeException(), isNull);
      }

      await pumpDs(
        tester,
        DsChipGroup<String>(
          options: _options,
          selected: const <String>{'mon'},
          onChanged: (_) {},
        ),
        surfaceSize: const Size(320, 600),
        textScale: 1.3,
      );
      expect(tester.takeException(), isNull);
    });
  });
}
