// Screenshot generator for the LCV demo dashboard (not an assertion suite).
//
// Renders the demo-dashboard page (the surface behind "Launch demo") in the
// dark theme and writes a PNG next to this file:
//
//   flutter test test/screenshots/lcv_demo_dashboard.dart --update-goldens
//
// Composed entirely from existing Design System components, seeded with sample
// fleet data so it reads like a real demo, not lorem.
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

  testWidgets('lcv demo dashboard · dark', (tester) async {
    const dpr = 2.0;
    const width = 1320.0;
    const height = 1240.0;
    tester.view.devicePixelRatio = dpr;
    tester.view.physicalSize = const Size(width * dpr, height * dpr);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final boundaryKey = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: DsTheme.dark(),
        home: Material(
          type: MaterialType.transparency,
          child: RepaintBoundary(
            key: boundaryKey,
            child: const SizedBox(
              width: width,
              height: height,
              child: LcvDemoDashboard(),
            ),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 350));

    await expectLater(
      find.byKey(boundaryKey),
      matchesGoldenFile('lcv_demo_dashboard.png'),
    );
  });
}

/// The demo dashboard the visitor lands on after tapping "Launch demo".
class LcvDemoDashboard extends StatelessWidget {
  const LcvDemoDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final t = DsTokens.of(context);
    return Container(
      color: t.colorBackground,
      child: Column(
        children: const [
          _TopBar(),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Sidebar(),
                Expanded(child: _Main()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    final t = DsTokens.of(context);
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: t.colorBackground,
        border: Border(bottom: BorderSide(color: t.colorBorder)),
      ),
      padding: EdgeInsets.symmetric(horizontal: t.spacingUnit * 3),
      child: Row(
        children: [
          DsBox(
            width: 340,
            background: t.colorSurfaceMuted,
            borderRadius: t.borderRadius,
            padding: EdgeInsets.symmetric(
              horizontal: t.spacingUnit * 1.5,
              vertical: t.spacingUnit,
            ),
            child: Text(
              'Search vehicles, drivers, transactions…',
              style:
                  t.bodySm.toTextStyle(color: t.formPlaceholderTextColor),
            ),
          ),
          const Spacer(),
          DsIconButton(
            icon: DsIcons.notifications,
            semanticLabel: 'Notifications',
            onPressed: () {},
          ),
          SizedBox(width: t.spacingUnit),
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: t.buttonPrimaryColorBackground,
              shape: BoxShape.circle,
            ),
            child: Text('J',
                style: t.labelMd.toTextStyle(color: t.buttonPrimaryColorText)),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar();

  @override
  Widget build(BuildContext context) {
    final t = DsTokens.of(context);
    const items = <(IconData, String, bool)>[
      (DsIcons.dashboard, 'Home', true),
      (DsIcons.shipping, 'Vehicles', false),
      (DsIcons.user, 'Drivers', false),
      (DsIcons.hierarchy, 'Groups', false),
      (DsIcons.file, 'Policies', false),
      (DsIcons.receipt, 'Cards', false),
      (DsIcons.activity, 'Transactions', false),
      (DsIcons.security, 'Fraud prevention', false),
      (DsIcons.report, 'Savings', false),
      (DsIcons.team, 'Team', false),
    ];
    return Container(
      width: 232,
      color: t.colorSurfaceMuted,
      padding: EdgeInsets.symmetric(
        vertical: t.spacingUnit * 2,
        horizontal: t.spacingUnit,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(t.spacingUnit),
            child: Row(
              children: [
                Icon(DsIcons.shipping,
                    size: 22, color: t.buttonPrimaryColorBackground),
                const SizedBox(width: 10),
                Text('LCV', style: t.headingSm.toTextStyle(color: t.colorText)),
                const SizedBox(width: 8),
                const DsBadge(label: 'Demo', variant: DsBadgeVariant.neutral),
              ],
            ),
          ),
          SizedBox(height: t.spacingUnit),
          for (final (icon, label, active) in items)
            _NavItem(icon: icon, label: label, active: active),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final t = DsTokens.of(context);
    final color = active ? t.colorText : t.colorSecondaryText;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: DsBox(
        background: active ? t.offsetBackgroundColor : null,
        borderRadius: t.borderRadius,
        padding: EdgeInsets.symmetric(
          horizontal: t.spacingUnit,
          vertical: t.spacingUnit * 1.25,
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 18,
                color: active ? t.buttonPrimaryColorBackground : color),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.bodyMd.toTextStyle(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Main extends StatelessWidget {
  const _Main();

  @override
  Widget build(BuildContext context) {
    final t = DsTokens.of(context);
    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(t.spacingUnit * 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DsBox(
                  padding: EdgeInsets.symmetric(
                    horizontal: t.spacingUnit * 2,
                    vertical: t.spacingUnit * 1.5,
                  ),
                  background: t.colorSurfaceMuted,
                  borderRadius: t.borderRadius,
                  child: Row(
                    children: [
                      Icon(DsIcons.info, size: 18, color: t.colorSecondaryText),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Explore the LCV demo — sample fleet data. '
                          'Open an account to add your own vehicles and drivers.',
                          style: t.bodySm
                              .toTextStyle(color: t.colorSecondaryText),
                        ),
                      ),
                      const SizedBox(width: 16),
                      DsButton(label: 'Open account', onPressed: () {}),
                    ],
                  ),
                ),
                SizedBox(height: t.spacingUnit * 2),
                Row(
                  children: [
                    Text('Welcome, Jane',
                        style: t.headingXl.toTextStyle(color: t.colorText)),
                    const Spacer(),
                    const DsBadge(
                        label: 'Demo data', variant: DsBadgeVariant.neutral),
                  ],
                ),
                SizedBox(height: t.spacingUnit * 2),
                DsButtonGroup(
                  children: [
                    DsButton(
                        label: 'Add vehicle',
                        icon: DsIcons.add,
                        onPressed: () {}),
                    DsButton(
                        label: 'Add driver',
                        variant: DsButtonVariant.secondary,
                        icon: DsIcons.user,
                        onPressed: () {}),
                    DsButton(
                        label: 'Top up',
                        variant: DsButtonVariant.secondary,
                        onPressed: () {}),
                    DsButton(
                        label: 'Export',
                        variant: DsButtonVariant.tertiary,
                        icon: DsIcons.download,
                        onPressed: () {}),
                  ],
                ),
                SizedBox(height: t.spacingUnit * 3),
                _kpiRow(t),
                SizedBox(height: t.spacingUnit * 3),
                _chartsRow(t),
                SizedBox(height: t.spacingUnit * 3),
                Text('Recent fuel transactions',
                    style: t.headingSm.toTextStyle(color: t.colorText)),
                SizedBox(height: t.spacingUnit * 1.5),
                _transactions(),
                const SizedBox(height: 240),
              ],
            ),
          ),
        ),
        Positioned(
          right: t.spacingUnit * 3,
          bottom: t.spacingUnit * 3,
          width: 344,
          child: _setupGuide(),
        ),
      ],
    );
  }
}

Widget _kpiCard(
  DsTokens t, {
  required String label,
  required String value,
  required Widget below,
}) {
  return DsBox(
    height: 148,
    padding: EdgeInsets.all(t.spacingUnit * 2),
    background: t.formBackgroundColor,
    borderColor: t.colorBorder,
    borderRadius: t.borderRadius,
    shadow: t.shadowLow,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: t.labelSm.toTextStyle(color: t.colorSecondaryText)),
        SizedBox(height: t.spacingUnit),
        Text(value, style: t.headingLg.toTextStyle(color: t.colorText)),
        const Spacer(),
        below,
      ],
    ),
  );
}

Widget _kpiRow(DsTokens t) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: _kpiCard(
          t,
          label: 'FLEET BALANCE',
          value: 'R 482,150.20',
          below: Row(
            children: [
              Text('▲ 4.2%',
                  style: t.bodySm.toTextStyle(color: t.colorSuccess)),
              const Spacer(),
              DsSparkline(
                values: const [42, 48, 45, 51, 49, 58, 63],
                filled: true,
                width: 120,
                height: 34,
                color: t.colorSuccess,
              ),
            ],
          ),
        ),
      ),
      SizedBox(width: t.spacingUnit * 2),
      Expanded(
        child: _kpiCard(
          t,
          label: 'FUEL SPEND · JULY',
          value: 'R 63,778.37',
          below: Text('18,240 L across 24 vehicles',
              style: t.bodySm.toTextStyle(color: t.colorSecondaryText)),
        ),
      ),
      SizedBox(width: t.spacingUnit * 2),
      Expanded(
        child: _kpiCard(
          t,
          label: 'ACTIVE VEHICLES',
          value: '24 / 26',
          below: const DsBadge(label: '2 idle', variant: DsBadgeVariant.warning),
        ),
      ),
    ],
  );
}

Widget _chartsRow(DsTokens t) {
  Widget panel({required Widget child}) => DsBox(
        padding: EdgeInsets.all(t.spacingUnit * 2),
        background: t.formBackgroundColor,
        borderColor: t.colorBorder,
        borderRadius: t.borderRadius,
        shadow: t.shadowLow,
        child: child,
      );

  return SizedBox(
    height: 320,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          flex: 3,
          child: panel(
            child: const DsLineChart(
              title: 'Fuel spend — last 6 weeks (R000)',
              xLabels: ['W1', 'W2', 'W3', 'W4', 'W5', 'W6'],
              series: [
                DsLineSeries(name: 'Spend', values: [52, 58, 61, 57, 64, 64]),
              ],
              height: 210,
            ),
          ),
        ),
        SizedBox(width: t.spacingUnit * 2),
        Expanded(
          flex: 2,
          child: panel(
            child: const DsMeterChart(
              title: 'Spend by fuel brand',
              segments: [
                DsMeterSegment(label: 'Engen', value: 45),
                DsMeterSegment(label: 'Shell', value: 30),
                DsMeterSegment(label: 'Sasol', value: 18),
                DsMeterSegment(label: 'BP', value: 12),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _transactions() {
  return const DsDataTable(
    columns: [
      DsColumn(label: 'Date'),
      DsColumn(label: 'Vehicle'),
      DsColumn(label: 'Driver'),
      DsColumn(label: 'Fuel stop'),
      DsColumn(label: 'Amount', numeric: true),
    ],
    rows: [
      DsDataRow(cells: [
        '15 Jul',
        'GP 42-DX',
        'Thabo Nkosi',
        'Engen Sandton',
        'R 1,204.16'
      ]),
      DsDataRow(cells: [
        '15 Jul',
        'WC 08-TR',
        'Lerato Dlamini',
        'Shell Century City',
        'R 878.40'
      ]),
      DsDataRow(cells: [
        '14 Jul',
        'GP 77-AR',
        'Sipho Khumalo',
        'Sasol Midrand',
        'R 640.53'
      ]),
      DsDataRow(cells: [
        '14 Jul',
        'KZN 19-ML',
        'Naledi Botha',
        'BP Umhlanga',
        'R 512.10'
      ]),
      DsDataRow(cells: [
        '13 Jul',
        'GP 42-DX',
        'Thabo Nkosi',
        'Engen N1 North',
        'R 995.80'
      ]),
    ],
  );
}

Widget _setupGuide() {
  return DsSetupGuide(
    title: 'Get started with LCV',
    tasks: [
      DsSetupTask(
          label: 'Invite teammates', done: true, animateCrossOff: true),
      DsSetupTask(label: 'Add vehicles', onTap: () {}),
      DsSetupTask(label: 'Add drivers', onTap: () {}),
      DsSetupTask(label: 'Create groups', onTap: () {}),
      DsSetupTask(label: 'Add policies', onTap: () {}),
      const DsSetupTask(
        label: 'View fraud prevention',
        locked: true,
        lockedMessage: 'Add a policy to switch on fraud prevention',
      ),
      const DsSetupTask(
        label: 'View savings',
        locked: true,
        lockedMessage: 'Add vehicles to see your savings',
      ),
    ],
  );
}
