import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

const List<DsDialCode> _countries = <DsDialCode>[
  DsDialCode(code: 'ZA', dialCode: '+27', hintExample: '00 000 0000'),
  DsDialCode(code: 'GB', dialCode: '+44', hintExample: '0000 000000'),
];

void main() {
  testWidgets('renders the prefix, the hint and one accessible name', (
    tester,
  ) async {
    await pumpDs(
      tester,
      DsPhoneField(
        label: 'Phone',
        countries: _countries,
        value: const DsPhoneValue(code: 'ZA', number: ''),
        onChanged: (_) {},
      ),
      surfaceSize: const Size(500, 400),
    );

    expect(find.text('ZA +27'), findsOneWidget);
    expect(find.text('00 000 0000'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Phone')), findsAtLeastNWidgets(1));
  });

  testWidgets('typing reports the number with the chosen country', (
    tester,
  ) async {
    DsPhoneValue? reported;
    await pumpDs(
      tester,
      DsPhoneField(
        label: 'Phone',
        countries: _countries,
        value: const DsPhoneValue(code: 'ZA', number: ''),
        onChanged: (DsPhoneValue value) => reported = value,
      ),
      surfaceSize: const Size(500, 400),
    );

    await tester.enterText(find.byType(TextField), '82 123 4567');
    await tester.pump();
    expect(reported, const DsPhoneValue(code: 'ZA', number: '82 123 4567'));
  });

  testWidgets('the field rejects letters', (tester) async {
    DsPhoneValue? reported;
    await pumpDs(
      tester,
      DsPhoneField(
        countries: _countries,
        value: const DsPhoneValue(code: 'ZA', number: ''),
        onChanged: (DsPhoneValue value) => reported = value,
      ),
      surfaceSize: const Size(500, 400),
    );

    await tester.enterText(find.byType(TextField), '82abc123');
    await tester.pump();
    expect(reported!.number, '82123');
  });

  testWidgets('changing the country keeps the number', (tester) async {
    DsPhoneValue value = const DsPhoneValue(code: 'ZA', number: '821234567');
    await pumpDs(
      tester,
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => DsPhoneField(
          countries: _countries,
          value: value,
          onChanged: (DsPhoneValue next) => setState(() => value = next),
        ),
      ),
      surfaceSize: const Size(500, 400),
    );

    await tester.tap(find.text('ZA +27'));
    await tester.pumpAndSettle(const Duration(milliseconds: 50));
    await tester.tap(find.text('GB +44').last);
    await tester.pumpAndSettle(const Duration(milliseconds: 50));

    expect(value, const DsPhoneValue(code: 'GB', number: '821234567'));
  });

  testWidgets('a null onChanged disables the control', (tester) async {
    await pumpDs(
      tester,
      const DsPhoneField(
        label: 'Phone',
        countries: _countries,
        value: DsPhoneValue(code: 'ZA', number: ''),
        onChanged: null,
      ),
      surfaceSize: const Size(500, 400),
    );

    expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
  });

  testWidgets('an unmatched country code falls back to the first', (
    tester,
  ) async {
    await pumpDs(
      tester,
      DsPhoneField(
        countries: _countries,
        value: const DsPhoneValue(code: 'XX', number: ''),
        onChanged: (_) {},
      ),
      surfaceSize: const Size(500, 400),
    );
    expect(find.text('ZA +27'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('holds 320dp and every theme, and 1.3x text', (tester) async {
    for (final ThemeData theme in <ThemeData>[
      DsTheme.light(),
      DsTheme.dark(),
      DsTheme.light(tokens: DsSkins.engenLight()),
    ]) {
      await pumpDs(
        tester,
        DsPhoneField(
          label: 'Phone',
          countries: _countries,
          value: const DsPhoneValue(code: 'ZA', number: '821234567'),
          helperText: 'We only use this to reach you about your account.',
          onChanged: (_) {},
        ),
        surfaceSize: const Size(320, 600),
        theme: theme,
      );
      expect(tester.takeException(), isNull);
    }

    await pumpDs(
      tester,
      DsPhoneField(
        label: 'Phone',
        countries: _countries,
        value: const DsPhoneValue(code: 'ZA', number: '821234567'),
        onChanged: (_) {},
      ),
      surfaceSize: const Size(320, 600),
      textScale: 1.3,
    );
    expect(tester.takeException(), isNull);
  });
}
