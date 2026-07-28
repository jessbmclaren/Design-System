import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Check menu page: a column picker whose two identity
/// columns are locked, so the selection can never empty, alongside a plain
/// multi-choice picker. Deterministic — both menus are closed on first build
/// and nothing animates on its own.
class CheckMenuDemo extends StatefulWidget {
  const CheckMenuDemo({super.key});

  @override
  State<CheckMenuDemo> createState() => _CheckMenuDemoState();
}

class _CheckMenuDemoState extends State<CheckMenuDemo> {
  static const _columns = <DsCheckOption>[
    DsCheckOption(value: 'status', label: 'Status', enabled: false),
    DsCheckOption(value: 'name', label: 'Application', enabled: false),
    DsCheckOption(value: 'owner', label: 'Owner'),
    DsCheckOption(value: 'spend', label: 'Spend'),
    DsCheckOption(value: 'requests', label: 'Requests'),
    DsCheckOption(value: 'errors', label: 'Errors'),
    DsCheckOption(value: 'uptime', label: 'Uptime'),
  ];

  static const _regions = <DsCheckOption>[
    DsCheckOption(value: 'af', label: 'Africa'),
    DsCheckOption(value: 'eu', label: 'Europe'),
    DsCheckOption(value: 'na', label: 'North America'),
    DsCheckOption(value: 'ap', label: 'Asia Pacific'),
  ];

  Set<String> _visible = <String>{
    'status',
    'name',
    'owner',
    'spend',
    'requests',
  };
  Set<String> _selectedRegions = <String>{'af', 'eu'};

  String _summary(Set<String> values, List<DsCheckOption> options) {
    final List<String> labels = <String>[
      for (final DsCheckOption option in options)
        if (values.contains(option.value)) option.label,
    ];
    return labels.isEmpty ? 'None' : labels.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);

    Widget block({
      required String heading,
      required Widget menu,
      required String summary,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            heading,
            style: tokens.labelMd.toTextStyle(color: tokens.colorText),
          ),
          const SizedBox(height: DsSpacing.sm),
          Align(alignment: Alignment.centerLeft, child: menu),
          const SizedBox(height: DsSpacing.sm),
          Text(
            summary,
            style: tokens.bodySm.toTextStyle(
              color: tokens.colorSecondaryText,
            ),
          ),
        ],
      );
    }

    return Wrap(
      spacing: DsSpacing.xl,
      runSpacing: DsSpacing.xl,
      children: <Widget>[
        block(
          heading: 'Column picker',
          menu: DsCheckMenu(
            trigger: const DsButton(
              label: 'Columns',
              variant: DsButtonVariant.secondary,
              icon: DsIcons.tune,
            ),
            options: _columns,
            selected: _visible,
            onChanged: (Set<String> next) => setState(() => _visible = next),
          ),
          summary: 'Showing: ${_summary(_visible, _columns)}',
        ),
        block(
          heading: 'Without a select-all row',
          menu: DsCheckMenu(
            trigger: const DsButton(
              label: 'Regions',
              variant: DsButtonVariant.secondary,
            ),
            options: _regions,
            selected: _selectedRegions,
            showSelectAll: false,
            onChanged: (Set<String> next) =>
                setState(() => _selectedRegions = next),
          ),
          summary: 'Selected: ${_summary(_selectedRegions, _regions)}',
        ),
      ],
    );
  }
}
