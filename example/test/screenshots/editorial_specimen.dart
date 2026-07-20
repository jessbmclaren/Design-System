// Editorial skin specimen generator (not an assertion suite).
//
// Writes a specimen sheet so the skin can be judged as a page rather than a
// component at a time, with the real fonts loaded:
//
//   flutter test test/screenshots/editorial_specimen.dart --update-goldens
//
// It is NOT named `*_test.dart`, so `flutter test` never discovers it.
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
    'editorial-light': DsTheme.light(tokens: DsSkins.editorialLight()),
    'editorial-dark': DsTheme.dark(tokens: DsSkins.editorialDark()),
    'neutral-light': DsTheme.light(),
  }.entries) {
    testWidgets('specimen ${entry.key}', (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.devicePixelRatio = 2.0;
      tester.view.physicalSize = const Size(1000 * 2, 900 * 2);

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: entry.value,
          home: Builder(
            builder: (BuildContext context) {
              final DsTokens t = DsTokens.of(context);
              return Scaffold(
                backgroundColor: t.colorBackground,
                body: Padding(
                  padding: const EdgeInsets.all(48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Statements',
                        style: t.headingXs
                            .toTextStyle(color: t.colorSecondaryText),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'The season in numbers',
                        style: t.headingXl.toTextStyle(color: t.colorText),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: 560,
                        child: Text(
                          'Every account and every movement, set in one '
                          'column so the figures read like a page rather '
                          'than a screen.',
                          style: t.bodyMd
                              .toTextStyle(color: t.colorSecondaryText),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: <Widget>[
                          DsButton(label: 'Subscribe', onPressed: () {}),
                          const SizedBox(width: 12),
                          DsButton(
                            label: 'Read more',
                            variant: DsButtonVariant.secondary,
                            onPressed: () {},
                          ),
                          const SizedBox(width: 12),
                          DsButton(
                            label: 'Archive',
                            variant: DsButtonVariant.tertiary,
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      const Row(
                        children: <Widget>[
                          DsBadge(label: 'New'),
                          SizedBox(width: 8),
                          DsBadge(
                              label: 'Live', variant: DsBadgeVariant.success),
                          SizedBox(width: 8),
                          DsBadge(
                              label: 'Ends soon',
                              variant: DsBadgeVariant.warning),
                          SizedBox(width: 8),
                          DsBadge(
                              label: 'Closed', variant: DsBadgeVariant.danger),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: DsStatTile(
                              label: 'Subscribers',
                              value: '128,400',
                              caption: 'up 12 this month',
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DsStatTile(
                              label: 'Renewals',
                              value: '96,210',
                              selected: true,
                              onTap: () {},
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(child: SizedBox()),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const SizedBox(
                            width: 380,
                            child: DsTextField(
                              label: 'Email',
                              hintText: 'you@example.com',
                            ),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            child: DsChipGroup<String>(
                              options: const <DsChipOption<String>>[
                                DsChipOption<String>(
                                    value: 'w', label: 'Womenswear'),
                                DsChipOption<String>(
                                    value: 'm', label: 'Menswear'),
                                DsChipOption<String>(
                                    value: 'b', label: 'Beauty'),
                              ],
                              selected: const <String>{'w'},
                              onChanged: (_) {},
                            ),
                          ),
                        ],
                      ),
                    ],
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
