import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Radio group page: a single-select list of `DsRadio` rows
/// laid out with `DsRadioGroup`. The options are shown in full so the choice is
/// made without opening a menu.
///
/// Choosing a row records the value via `setState`; the "Continue" button
/// validates that a choice was made, surfacing the group's `errorText` when it
/// was not. The demo starts with nothing selected so the empty-then-error path
/// is visible on the first interaction.
class RadioGroupDemo extends StatefulWidget {
  const RadioGroupDemo({super.key});

  @override
  State<RadioGroupDemo> createState() => _RadioGroupDemoState();
}

class _RadioGroupDemoState extends State<RadioGroupDemo> {
  static const _options = <DsRadioOption<String>>[
    DsRadioOption(value: 'owner', label: 'Founder / owner'),
    DsRadioOption(value: 'admin', label: 'Administrator'),
    DsRadioOption(value: 'ops', label: 'Operations'),
    DsRadioOption(value: 'finance', label: 'Finance'),
    DsRadioOption(value: 'other', label: 'Other'),
  ];

  String? _role;
  bool _showError = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: DsRadioGroup<String>(
            label: 'What is your role?',
            options: _options,
            value: _role,
            errorText: _showError && _role == null
                ? 'Please select your role'
                : null,
            onChanged: (next) => setState(() {
              _role = next;
              _showError = false;
            }),
          ),
        ),
        const SizedBox(height: 16),
        DsButton(
          label: 'Continue',
          onPressed: () => setState(() => _showError = _role == null),
        ),
      ],
    );
  }
}
