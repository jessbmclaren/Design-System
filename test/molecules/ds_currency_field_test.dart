import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  testWidgets('renders label, symbol and formatted value', (tester) async {
    await pumpDs(
      tester,
      const DsCurrencyField(
        symbol: r'$',
        label: 'Amount',
        value: 12,
      ),
    );

    expect(find.text('Amount'), findsOneWidget);
    expect(find.text(r'$'), findsOneWidget);
    // Whole numbers render without a trailing `.0`.
    expect(find.text('12'), findsOneWidget);
  });

  testWidgets('renders decimal value verbatim', (tester) async {
    await pumpDs(
      tester,
      const DsCurrencyField(
        symbol: r'$',
        value: 12.5,
      ),
    );

    expect(find.text('12.5'), findsOneWidget);
  });

  testWidgets('fires onChanged with the parsed number', (tester) async {
    num? captured;
    await pumpDs(
      tester,
      DsCurrencyField(
        symbol: r'$',
        label: 'Amount',
        onChanged: (value) => captured = value,
      ),
    );

    await tester.enterText(find.byType(TextFormField), '42.75');
    await tester.pump();

    expect(captured, 42.75);
  });

  testWidgets('shows error text and suppresses helper text', (tester) async {
    await pumpDs(
      tester,
      const DsCurrencyField(
        symbol: r'$',
        label: 'Amount',
        helperText: 'Charged monthly',
        errorText: 'Amount is required',
      ),
    );

    expect(find.text('Amount is required'), findsOneWidget);
    expect(find.text('Charged monthly'), findsNothing);
  });

  testWidgets('renders without overflow on a small phone', (tester) async {
    await pumpDs(
      tester,
      const DsCurrencyField(
        symbol: r'R',
        label: 'Amount',
        value: 1999.99,
        helperText: 'Charged monthly',
      ),
      surfaceSize: const Size(320, 900),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders without overflow on a large desktop', (tester) async {
    await pumpDs(
      tester,
      const DsCurrencyField(
        symbol: r'R',
        label: 'Amount',
        value: 1999.99,
        helperText: 'Charged monthly',
      ),
      surfaceSize: const Size(1200, 900),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
