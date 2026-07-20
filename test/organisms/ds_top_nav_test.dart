import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

List<DsTopNavLink> _links(void Function(String) onTap) => <DsTopNavLink>[
      DsTopNavLink(label: 'Product', dropdown: true, onTap: () => onTap('product')),
      DsTopNavLink(label: 'Pricing', onTap: () => onTap('pricing')),
      DsTopNavLink(label: 'Docs', onTap: () => onTap('docs')),
    ];

Widget _nav({
  void Function(String)? onTap,
  bool floating = false,
}) {
  return DsTopNav(
    brand: const Text('acme'),
    links: _links(onTap ?? (_) {}),
    secondaryActions: <Widget>[
      DsButton(
        label: 'Log in',
        variant: DsButtonVariant.tertiary,
        onPressed: () {},
      ),
    ],
    primaryAction: DsButton(label: 'Get started', onPressed: () {}),
    floating: floating,
  );
}

void main() {
  testWidgets('a wide bar shows the links and both actions inline', (
    tester,
  ) async {
    await pumpDs(tester, _nav(), surfaceSize: const Size(1200, 400));

    expect(find.text('Product'), findsOneWidget);
    expect(find.text('Pricing'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
    expect(find.byIcon(DsIcons.menu), findsNothing);
  });

  testWidgets('a medium bar folds the links into the menu, keeping actions', (
    tester,
  ) async {
    await pumpDs(tester, _nav(), surfaceSize: const Size(760, 400));

    expect(find.text('Pricing'), findsNothing);
    expect(find.text('Get started'), findsOneWidget);
    expect(find.byIcon(DsIcons.menu), findsOneWidget);
  });

  testWidgets('a phone bar folds everything into the menu, never dropping it', (
    tester,
  ) async {
    await pumpDs(tester, _nav(), surfaceSize: const Size(360, 640));

    expect(find.text('Pricing'), findsNothing);
    expect(find.text('Get started'), findsNothing);

    await tester.tap(find.byTooltip('Open menu'));
    await tester.pumpAndSettle(const Duration(milliseconds: 400));

    // Everything that left the bar is reachable in the sheet.
    expect(find.text('Product'), findsOneWidget);
    expect(find.text('Pricing'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Get started'), findsOneWidget);
  });

  testWidgets('choosing from the sheet closes it and reports the link', (
    tester,
  ) async {
    String? chosen;
    await pumpDs(
      tester,
      _nav(onTap: (String route) => chosen = route),
      surfaceSize: const Size(360, 640),
    );

    await tester.tap(find.byTooltip('Open menu'));
    await tester.pumpAndSettle(const Duration(milliseconds: 400));
    await tester.tap(find.text('Pricing'));
    await tester.pumpAndSettle(const Duration(milliseconds: 400));

    expect(chosen, 'pricing');
    expect(find.text('Pricing'), findsNothing);
  });

  testWidgets('the links navigate inline on a wide bar', (tester) async {
    String? chosen;
    await pumpDs(
      tester,
      _nav(onTap: (String route) => chosen = route),
      surfaceSize: const Size(1200, 400),
    );

    await tester.tap(find.text('Docs'));
    await tester.pump();
    expect(chosen, 'docs');
  });

  testWidgets('holds every width from 320dp to 1920dp, in every theme', (
    tester,
  ) async {
    for (final ThemeData theme in <ThemeData>[
      DsTheme.light(),
      DsTheme.dark(),
      DsTheme.light(tokens: DsSkins.engenLight()),
    ]) {
      for (final double width in <double>[320, 600, 900, 1440, 1920]) {
        await pumpDs(
          tester,
          _nav(floating: width > 600),
          surfaceSize: Size(width, 640),
          theme: theme,
        );
        expect(tester.takeException(), isNull,
            reason: 'at ${width.toInt()}dp');
      }
    }
  });

  testWidgets('survives 1.3x text scale at 320dp', (tester) async {
    await pumpDs(
      tester,
      _nav(),
      surfaceSize: const Size(320, 640),
      textScale: 1.3,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the floating bar lifts only when asked', (tester) async {
    await pumpDs(
      tester,
      const DsFloatingBar(floating: false, child: SizedBox(height: 60)),
    );
    BoxDecoration decorationOf() => tester
        .widget<AnimatedContainer>(find.byType(AnimatedContainer))
        .decoration! as BoxDecoration;
    expect(decorationOf().boxShadow, isEmpty);

    await pumpDs(
      tester,
      const DsFloatingBar(floating: true, child: SizedBox(height: 60)),
    );
    await tester.pump(const Duration(milliseconds: 200));
    expect(decorationOf().boxShadow, isNotEmpty);
  });
}
