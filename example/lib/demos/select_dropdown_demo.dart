import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Select page: a working "Business type" dropdown driven by
/// setState, alongside a second select that shows the inline error state.
class SelectDropdownDemo extends StatefulWidget {
  const SelectDropdownDemo({super.key});

  @override
  State<SelectDropdownDemo> createState() => _SelectDropdownDemoState();
}

class _SelectDropdownDemoState extends State<SelectDropdownDemo> {
  // Initialise to a meaningful choice so a single captured frame reads clearly.
  String? _businessType = 'company';

  // Left unset to demonstrate the empty + error state.
  String? _residency;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        DsSelect<String>(
          label: 'Business type',
          hintText: 'Select a business type',
          value: _businessType,
          onChanged: (v) => setState(() => _businessType = v),
          options: const [
            DsSelectOption(value: 'sole_trader', label: 'Sole trader'),
            DsSelectOption(value: 'company', label: 'Company'),
            DsSelectOption(value: 'partnership', label: 'Partnership'),
            DsSelectOption(value: 'trust', label: 'Trust'),
          ],
        ),
        const SizedBox(height: 20),
        DsSelect<String>(
          label: 'Tax residency',
          hintText: 'Select a country',
          value: _residency,
          errorText:
              _residency == null ? 'Select a country to continue' : null,
          onChanged: (v) => setState(() => _residency = v),
          options: const [
            DsSelectOption(value: 'au', label: 'Australia'),
            DsSelectOption(value: 'nz', label: 'New Zealand'),
            DsSelectOption(value: 'sg', label: 'Singapore'),
          ],
        ),
      ],
    );
  }
}
