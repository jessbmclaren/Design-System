import 'package:flutter/material.dart';

import 'docs_style.dart';

/// A preview frame that renders a live demo at a chosen viewport width, so
/// readers can see how a pattern responds from a small phone up to desktop.
class DeviceFrame extends StatefulWidget {
  const DeviceFrame({super.key, required this.child});

  /// The live demo to render.
  final Widget child;

  @override
  State<DeviceFrame> createState() => _DeviceFrameState();
}

enum _Viewport {
  phone('Phone', 320),
  tablet('Tablet', 768),
  desktop('Desktop', null);

  const _Viewport(this.label, this.width);
  final String label;
  final double? width;
}

class _DeviceFrameState extends State<DeviceFrame> {
  _Viewport _viewport = _Viewport.desktop;

  @override
  Widget build(BuildContext context) {
    final docs = DocsColors.of(context);

    final control = _SegmentedControl(
      value: _viewport,
      onChanged: (v) => setState(() => _viewport = v),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final label =
                Text('Live example', style: DocsType.headline(docs.textPrimary));
            // Stack the control under the label when the row is too tight for
            // both (a 320dp reading column).
            if (constraints.maxWidth < 380) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  label,
                  const SizedBox(height: 10),
                  control,
                ],
              );
            }
            return Row(children: [label, const Spacer(), control]);
          },
        ),
        const SizedBox(height: 14),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: docs.surface,
            borderRadius: BorderRadius.circular(DocsRadii.lg),
            border: Border.all(color: docs.separator),
            boxShadow: DocsShadows.card,
          ),
          padding: const EdgeInsets.all(28),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final content = _ConstrainedViewport(
                width: _viewport.width,
                child: widget.child,
              );
              final w = _viewport.width;
              // Centre a fixed-width preview when it fits; scroll it when the
              // demoed width is wider than the stage rather than overflowing.
              if (w == null || w <= constraints.maxWidth) {
                return Center(child: content);
              }
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: content,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ConstrainedViewport extends StatelessWidget {
  const _ConstrainedViewport({required this.width, required this.child});

  final double? width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (width == null) {
      return child;
    }
    final media = MediaQuery.of(context);
    // Constrain the width AND report that width to MediaQuery so components
    // that read the window size resolve their breakpoints against the frame.
    return SizedBox(
      width: width,
      child: MediaQuery(
        data: media.copyWith(size: Size(width!, media.size.height)),
        child: child,
      ),
    );
  }
}

/// An Apple-style segmented control: a rounded track with a single sliding
/// pill under the active segment.
class _SegmentedControl extends StatelessWidget {
  const _SegmentedControl({required this.value, required this.onChanged});

  final _Viewport value;
  final ValueChanged<_Viewport> onChanged;

  @override
  Widget build(BuildContext context) {
    final docs = DocsColors.of(context);
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: docs.fill,
        borderRadius: BorderRadius.circular(DocsRadii.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final v in _Viewport.values)
            _Segment(
              label: v.label,
              selected: v == value,
              onTap: () => onChanged(v),
              docs: docs,
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.docs,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final DocsColors docs;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? docs.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(DocsRadii.xs),
          boxShadow: selected ? DocsShadows.thumb : DocsShadows.none,
        ),
        // Both labels use primary ink (the white thumb, not colour, marks the
        // selection) so the unselected label clears contrast on the track.
        child: Text(
          label,
          style: DocsType.footnote(docs.textPrimary)
              .copyWith(fontWeight: selected ? FontWeight.w600 : FontWeight.w500),
        ),
      ),
    );
  }
}
