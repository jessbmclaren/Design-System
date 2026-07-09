import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

Alignment _thumbAlignment(WidgetTester tester) {
  final align = tester.widget<AnimatedAlign>(
    find.descendant(
      of: find.byType(DsSwitch),
      matching: find.byType(AnimatedAlign),
    ),
  );
  return align.alignment as Alignment;
}

void main() {
  group('DsSwitch', () {
    testWidgets('renders its label', (tester) async {
      await pumpDs(
        tester,
        DsSwitch(value: false, label: 'Email notifications', onChanged: (_) {}),
      );

      expect(find.text('Email notifications'), findsOneWidget);
    });

    testWidgets('reflects the toggled-on state', (tester) async {
      await pumpDs(
        tester,
        DsSwitch(value: true, label: 'Wifi', onChanged: (_) {}),
      );

      expect(_thumbAlignment(tester), Alignment.centerRight);
    });

    testWidgets('tapping toggles and reports the inverted value',
        (tester) async {
      bool? reported;
      await pumpDs(
        tester,
        DsSwitch(
          value: false,
          label: 'Dark mode',
          onChanged: (next) => reported = next,
        ),
      );

      await tester.tap(find.byType(DsSwitch));
      await tester.pump(const Duration(milliseconds: 200));

      expect(reported, isTrue);
    });

    testWidgets('updates its thumb position when driven by a parent',
        (tester) async {
      await pumpDs(tester, const _SwitchHost(initial: false));

      expect(_thumbAlignment(tester), Alignment.centerLeft);

      await tester.tap(find.byType(DsSwitch));
      await tester.pump(const Duration(milliseconds: 200));

      expect(_thumbAlignment(tester), Alignment.centerRight);
    });

    testWidgets('is disabled and inert when onChanged is null', (tester) async {
      await pumpDs(
        tester,
        const DsSwitch(value: false, label: 'Locked', onChanged: null),
      );

      final inkWell = tester.widget<InkWell>(
        find.descendant(
          of: find.byType(DsSwitch),
          matching: find.byType(InkWell),
        ),
      );
      expect(inkWell.onTap, isNull);
      expect(_thumbAlignment(tester), Alignment.centerLeft);
    });

    testWidgets('does not overflow at 320x640', (tester) async {
      await pumpDs(
        tester,
        DsSwitch(
          value: true,
          label: 'A rather long switch label that should wrap gracefully '
              'instead of overflowing the narrow phone viewport',
          onChanged: (_) {},
        ),
        surfaceSize: const Size(320, 640),
      );

      expect(tester.takeException(), isNull);
    });
  });
}

class _SwitchHost extends StatefulWidget {
  const _SwitchHost({required this.initial});

  final bool initial;

  @override
  State<_SwitchHost> createState() => _SwitchHostState();
}

class _SwitchHostState extends State<_SwitchHost> {
  late bool _value = widget.initial;

  @override
  Widget build(BuildContext context) {
    return DsSwitch(
      value: _value,
      label: 'Sync',
      onChanged: (next) => setState(() => _value = next),
    );
  }
}
