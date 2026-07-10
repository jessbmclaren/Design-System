import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Progress bar page.
///
/// Three static [DsProgressBar]s at empty, partial and full fill, each
/// captioned with the step count it reflects, plus one animated bar that
/// eases its fill in when the demo mounts. The static bars keep the captured
/// frame deterministic.
class ProgressBarDemo extends StatelessWidget {
  const ProgressBarDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final captionStyle =
        tokens.labelSm.toTextStyle(color: tokens.colorSecondaryText);

    Widget labelled(String caption, double value) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(caption, style: captionStyle),
          const SizedBox(height: 8),
          // The caption above already states the progress, so the bar is
          // dropped from semantics rather than announced twice.
          DsProgressBar(value: value, excludeSemantics: true),
        ],
      );
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          labelled('0 of 6 tasks complete', 0),
          const SizedBox(height: 20),
          labelled('4 of 6 tasks complete', 4 / 6),
          const SizedBox(height: 20),
          labelled('6 of 6 tasks complete', 1),
          const SizedBox(height: 28),
          Text('Animated fill', style: captionStyle),
          const SizedBox(height: 8),
          // No adjacent count here, so the bar names its own work and eases
          // towards its value through the motion tokens.
          const DsProgressBar(
            value: 0.7,
            animate: true,
            semanticLabel: 'Data import',
          ),
        ],
      ),
    );
  }
}
