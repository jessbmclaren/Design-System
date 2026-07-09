import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Selection controls page: a consent checkbox, a
/// mutually-exclusive radio group for the plan tier, and a switch for an
/// immediate setting. Every control is interactive and updates local state.
class SelectionControlsDemo extends StatefulWidget {
  const SelectionControlsDemo({super.key});

  @override
  State<SelectionControlsDemo> createState() => _SelectionControlsDemoState();
}

class _SelectionControlsDemoState extends State<SelectionControlsDemo> {
  // Initialise to a meaningful state so a single captured frame reads well:
  // consent given, a default plan selected, updates turned on.
  bool _agreed = true;
  String _plan = 'growth';
  bool _emailUpdates = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Independent option / consent.
        DsCheckbox(
          value: _agreed,
          label: 'I agree to the terms of service',
          onChanged: (v) => setState(() => _agreed = v),
        ),
        const SizedBox(height: 20),

        // Mutually exclusive choice — one shared groupValue.
        Text('Plan', style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        DsRadio<String>(
          value: 'starter',
          groupValue: _plan,
          label: 'Starter',
          onChanged: (v) => setState(() => _plan = v!),
        ),
        DsRadio<String>(
          value: 'growth',
          groupValue: _plan,
          label: 'Growth',
          onChanged: (v) => setState(() => _plan = v!),
        ),
        DsRadio<String>(
          value: 'scale',
          groupValue: _plan,
          label: 'Scale',
          onChanged: (v) => setState(() => _plan = v!),
        ),
        const SizedBox(height: 20),

        // Immediate setting — no Save step.
        DsSwitch(
          value: _emailUpdates,
          label: 'Email me updates',
          onChanged: (v) => setState(() => _emailUpdates = v),
        ),
      ],
    );
  }
}
