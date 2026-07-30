// Engen Mobile skin specimen generator (not an assertion suite).
//
// Writes a phone-sized specimen sheet so the touch skin can be judged as a
// screen rather than a component at a time, with the real fonts loaded:
//
//   flutter test test/screenshots/engen_mobile_specimen.dart --update-goldens
//
// It is NOT named `*_test.dart`, so `flutter test` never discovers it.
//
// The skin itself clears `fontFamily` so a phone sets in its own system face,
// and the test harness has no system face to fall back on, which would render
// every run as a filled box. The specimen therefore stands Inter in for the
// device font: judge the colour, shape and scale here, not the letterforms.
import 'dart:convert';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _loadFonts() async {
  final manifest = json.decode(
    await rootBundle.loadString('FontManifest.json'),
  ) as List<dynamic>;
  for (final entry in manifest) {
    final family = entry['family'] as String;
    final loader = FontLoader(family);
    for (final font in entry['fonts'] as List<dynamic>) {
      loader.addFont(rootBundle.load(font['asset'] as String));
    }
    await loader.load();
  }
}

void main() {
  setUpAll(_loadFonts);

  for (final entry in <String, ThemeData>{
    'engen-mobile-light': DsTheme.light(
        tokens: DsSkins.engenMobileLight().copyWith(fontFamily: 'Inter')),
    'engen-mobile-dark': DsTheme.dark(
        tokens: DsSkins.engenMobileDark().copyWith(fontFamily: 'Inter')),
  }.entries) {
    testWidgets('specimen ${entry.key}', (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.devicePixelRatio = 2.0;
      // A 390dp phone, the width the design was drawn at.
      tester.view.physicalSize = const Size(390 * 2, 900 * 2);

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: entry.value,
          home: Builder(
            builder: (BuildContext context) {
              final DsTokens t = DsTokens.of(context);
              return Scaffold(
                backgroundColor: t.colorBackground,
                body: SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'This month',
                          style:
                              t.labelSm.toTextStyle(color: t.colorSecondaryText),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Fuel spend',
                          style: t.headingXl.toTextStyle(color: t.colorText),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'R 48 210',
                          style: t.stepTitle.toTextStyle(color: t.colorPrimary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Across 34 vehicles and 12 sites, settled nightly.',
                          style:
                              t.bodyMd.toTextStyle(color: t.colorSecondaryText),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Updated 3 minutes ago',
                          style: t.bodySm.toTextStyle(color: t.colorTextMuted),
                        ),
                        const SizedBox(height: 20),
                        DsButton(
                          label: 'Approve all',
                          fullWidth: true,
                          onPressed: () {},
                        ),
                        const SizedBox(height: 10),
                        DsButton(
                          label: 'Review exceptions',
                          variant: DsButtonVariant.secondary,
                          fullWidth: true,
                          onPressed: () {},
                        ),
                        const SizedBox(height: 10),
                        DsButton(
                          label: 'Stop card',
                          variant: DsButtonVariant.danger,
                          fullWidth: true,
                          onPressed: () {},
                        ),
                        const SizedBox(height: 20),
                        const Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: <Widget>[
                            DsBadge(label: 'Draft'),
                            DsBadge(
                                label: 'Settled',
                                variant: DsBadgeVariant.success),
                            DsBadge(
                                label: 'Review',
                                variant: DsBadgeVariant.warning),
                            DsBadge(
                                label: 'Declined',
                                variant: DsBadgeVariant.danger),
                            DsBadge(
                                label: 'New', variant: DsBadgeVariant.info),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: DsStatTile(
                                label: 'Litres',
                                value: '18 402',
                                caption: 'up 4%',
                                onTap: () {},
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DsStatTile(
                                label: 'Sites',
                                value: '12',
                                selected: true,
                                onTap: () {},
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const DsTextField(
                          label: 'Registration',
                          hintText: 'CA 123-456',
                        ),
                        const SizedBox(height: 20),
                        DsChipGroup<String>(
                          options: const <DsChipOption<String>>[
                            DsChipOption<String>(value: 'd', label: 'Diesel'),
                            DsChipOption<String>(value: 'p', label: 'Petrol'),
                            DsChipOption<String>(value: 'e', label: 'Electric'),
                          ],
                          selected: const <String>{'d'},
                          onChanged: (_) {},
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 350));

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('specimen_${entry.key}.png'),
      );
    });
  }
}
