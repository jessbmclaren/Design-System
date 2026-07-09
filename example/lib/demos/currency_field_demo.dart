import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Currency field page: a small pricing panel with a healthy,
/// pre-filled amount that reports its parsed value live, next to a second field
/// parked in its error state so a single captured frame shows both the valid
/// and validation appearances at once.
class CurrencyFieldDemo extends StatefulWidget {
  const CurrencyFieldDemo({super.key});

  @override
  State<CurrencyFieldDemo> createState() => _CurrencyFieldDemoState();
}

class _CurrencyFieldDemoState extends State<CurrencyFieldDemo> {
  // Initialise to a meaningful, pre-filled amount so the demo reads as a form
  // mid-use rather than an empty field.
  num? _amount = 49;

  String get _parsedLabel =>
      _amount == null ? 'No amount entered' : 'Parsed value: $_amount';

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          DsCurrencyField(
            label: 'Monthly price',
            symbol: r'$',
            value: _amount,
            hintText: '0.00',
            helperText: 'Charged per seat, billed monthly.',
            onChanged: (amount) => setState(() => _amount = amount),
          ),
          const SizedBox(height: 8),
          Text(_parsedLabel),
          const SizedBox(height: 20),
          const DsCurrencyField(
            label: 'Setup fee',
            symbol: r'$',
            value: 0,
            errorText: 'A one-time setup fee is required.',
          ),
        ],
      ),
    );
  }
}
