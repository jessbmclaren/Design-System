import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A specimen sheet for the editorial skin: the pieces that carry a look,
/// rendered together so the skin can be judged as a whole rather than one
/// component at a time.
void main() {
  for (final (String name, ThemeData theme) in <(String, ThemeData)>[
    ('editorial-light', DsTheme.light(tokens: DsSkins.editorialLight())),
    ('editorial-dark', DsTheme.dark(tokens: DsSkins.editorialDark())),
  ]) {
    testWidgets('golden · skin $name', (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(900, 760);

      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme,
          home: Builder(
            builder: (BuildContext context) {
              final DsTokens tokens = DsTokens.of(context);
              return Scaffold(
                backgroundColor: tokens.colorBackground,
                body: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('Contents',
                          style: tokens.headingXs
                              .toTextStyle(color: tokens.colorSecondaryText)),
                      const SizedBox(height: 12),
                      Text('The season in numbers',
                          style: tokens.headingXl
                              .toTextStyle(color: tokens.colorText)),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: 520,
                        child: Text(
                          'Every account, every movement, set in one column so '
                          'the figures read like a page rather than a screen.',
                          style: tokens.bodyMd
                              .toTextStyle(color: tokens.colorSecondaryText),
                        ),
                      ),
                      const SizedBox(height: 28),
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
                          DsBadge(label: 'Live', variant: DsBadgeVariant.success),
                          SizedBox(width: 8),
                          DsBadge(label: 'Ends soon',
                              variant: DsBadgeVariant.warning),
                          SizedBox(width: 8),
                          DsBadge(label: 'Closed', variant: DsBadgeVariant.danger),
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
                        ],
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: 420,
                        child: DsTextField(
                          label: 'Email',
                          hintText: 'you@example.com',
                        ),
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
        matchesGoldenFile('goldens/skin__$name.png'),
      );
    });
  }
}
