import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Check list page: the bare checklist body, framed by the
/// caller. One inline block with an action row and a locked option, one
/// without an action row. Deterministic — no timers, no randomness.
class CheckListDemo extends StatefulWidget {
  const CheckListDemo({super.key});

  @override
  State<CheckListDemo> createState() => _CheckListDemoState();
}

class _CheckListDemoState extends State<CheckListDemo> {
  static const _columns = <DsCheckOption>[
    DsCheckOption(value: 'name', label: 'Application', enabled: false),
    DsCheckOption(value: 'owner', label: 'Owner'),
    DsCheckOption(value: 'spend', label: 'Spend'),
    DsCheckOption(value: 'requests', label: 'Requests'),
    DsCheckOption(value: 'errors', label: 'Errors'),
  ];

  static const _alerts = <DsCheckOption>[
    DsCheckOption(value: 'down', label: 'Service unreachable'),
    DsCheckOption(value: 'slow', label: 'Latency above target'),
    DsCheckOption(value: 'spend', label: 'Spend over budget'),
  ];

  Set<String> _visible = <String>{'name', 'owner', 'spend'};
  Set<String> _subscribed = <String>{'down'};

  void _selectAllColumns() {
    setState(() {
      _visible = <String>{
        for (final DsCheckOption option in _columns) option.value,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);

    Widget framed({required String heading, required Widget child}) {
      return SizedBox(
        width: 280,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              heading,
              style: tokens.labelMd.toTextStyle(color: tokens.colorText),
            ),
            const SizedBox(height: DsSpacing.sm),
            // The list draws no surface of its own; the host frames it.
            DecoratedBox(
              decoration: BoxDecoration(
                color: tokens.formBackgroundColor,
                borderRadius: BorderRadius.circular(tokens.overlayBorderRadius),
                border: Border.all(color: tokens.colorBorder),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  tokens.overlayBorderRadius,
                ),
                child: child,
              ),
            ),
          ],
        ),
      );
    }

    return Wrap(
      spacing: DsSpacing.xl,
      runSpacing: DsSpacing.xl,
      children: <Widget>[
        framed(
          heading: 'With an action row',
          child: DsCheckList(
            options: _columns,
            selected: _visible,
            onChanged: (Set<String> next) => setState(() => _visible = next),
            actionLabel: 'Select all',
            onAction: _selectAllColumns,
          ),
        ),
        framed(
          heading: 'Without one',
          child: DsCheckList(
            options: _alerts,
            selected: _subscribed,
            onChanged: (Set<String> next) =>
                setState(() => _subscribed = next),
          ),
        ),
      ],
    );
  }
}
