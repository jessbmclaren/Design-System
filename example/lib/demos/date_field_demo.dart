import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Date field page: two bounded date fields that update via
/// setState. The first initialises to a selected date so a single captured
/// frame is meaningful; the second stays empty to show the placeholder hint.
class DateFieldDemo extends StatefulWidget {
  const DateFieldDemo({super.key});

  @override
  State<DateFieldDemo> createState() => _DateFieldDemoState();
}

class _DateFieldDemoState extends State<DateFieldDemo> {
  // Seed with a meaningful value so the screenshot shows a filled field.
  DateTime? _startDate = DateTime(2026, 8, 1);
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        DsDateField(
          label: 'Start date',
          value: _startDate,
          hintText: 'Select a date',
          helperText: 'Billing begins on this date.',
          firstDate: DateTime(2026),
          lastDate: DateTime(2027, 12, 31),
          onChanged: (date) => setState(() => _startDate = date),
        ),
        const SizedBox(height: 16),
        DsDateField(
          label: 'End date',
          value: _endDate,
          hintText: 'Select a date',
          helperText: 'Leave empty to renew automatically.',
          firstDate: DateTime(2026),
          lastDate: DateTime(2027, 12, 31),
          onChanged: (date) => setState(() => _endDate = date),
        ),
      ],
    );
  }
}
