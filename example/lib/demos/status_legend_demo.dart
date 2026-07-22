import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Status legend page: the driver-roster status vocabulary
/// explained entry by entry. Static and screenshot safe.
class StatusLegendDemo extends StatelessWidget {
  const StatusLegendDemo({super.key});

  @override
  Widget build(BuildContext context) {
    // The widest badge pill ("Temporarily unavailable") does not shrink, so on
    // the very narrowest layouts the demo pans the legend instead of
    // overflowing.
    return LayoutBuilder(
      builder: (context, constraints) {
        const minWidth = 480.0;
        if (constraints.maxWidth >= minWidth) return _legend();
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(width: minWidth, child: _legend()),
        );
      },
    );
  }

  Widget _legend() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: DsStatusLegend(
        title: 'Statuses explained',
        entries: const [
          DsStatusLegendEntry(
            label: 'Ready',
            description: 'Fully compliant and available to take trips.',
            variant: DsBadgeVariant.success,
          ),
          DsStatusLegendEntry(
            label: 'Needs attention',
            description: 'A document is missing or about to expire.',
            variant: DsBadgeVariant.warning,
          ),
          DsStatusLegendEntry(
            label: 'Temporarily unavailable',
            description: 'Off the road for now, for example on leave.',
          ),
          DsStatusLegendEntry(
            label: 'Off duty',
            description: 'Outside working hours and not taking trips.',
          ),
          DsStatusLegendEntry(
            label: 'Deactivated',
            description: 'Removed from the roster and cannot be assigned.',
            variant: DsBadgeVariant.danger,
          ),
        ],
      ),
    );
  }
}
