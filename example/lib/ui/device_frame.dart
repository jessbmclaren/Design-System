import 'package:flutter/material.dart';

import 'demo_stage.dart';

/// A preview frame that renders a live demo at a chosen viewport width, so
/// readers can see how a pattern responds from a small phone up to desktop.
///
/// The viewport control and the framed stage are shared with the interactive
/// playground (see [DemoViewportControl] and [DemoStageCard]) so every live
/// example wears the same switch.
class DeviceFrame extends StatefulWidget {
  const DeviceFrame({super.key, required this.child});

  /// The live demo to render.
  final Widget child;

  @override
  State<DeviceFrame> createState() => _DeviceFrameState();
}

class _DeviceFrameState extends State<DeviceFrame> {
  DemoViewport _viewport = DemoViewport.desktop;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DemoSectionHeader(
          title: 'Live example',
          trailingBuilder: (compact) => DemoViewportControl(
            value: _viewport,
            onChanged: (v) => setState(() => _viewport = v),
            compact: compact,
          ),
        ),
        const SizedBox(height: 14),
        DemoStageCard(viewport: _viewport, minHeight: 200, child: widget.child),
      ],
    );
  }
}
