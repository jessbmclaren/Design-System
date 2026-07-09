import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Loading page: the three DsSpinner sizes, each labelled
/// with the scope it suits, plus a DsButton in its pending state to show
/// action-level loading. Spinners animate; no timers are started.
class LoadingDemo extends StatelessWidget {
  const LoadingDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    final captionStyle = TextStyle(
      fontSize: 12,
      color: tokens.badgeNeutralColorText,
    );

    Widget labelled(String label, String scope, DsSpinnerSize size) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 48,
            child: Center(child: DsSpinner(size: size)),
          ),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(scope, style: captionStyle),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 32,
          runSpacing: 24,
          alignment: WrapAlignment.start,
          children: [
            labelled('Small', 'Inline', DsSpinnerSize.small),
            labelled('Medium', 'Section', DsSpinnerSize.medium),
            labelled('Large', 'Full view', DsSpinnerSize.large),
          ],
        ),
        const SizedBox(height: 28),
        Text('Action loading', style: captionStyle),
        const SizedBox(height: 8),
        DsButton(
          label: 'Save',
          pending: true,
          onPressed: () {},
        ),
      ],
    );
  }
}
