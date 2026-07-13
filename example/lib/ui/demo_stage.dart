import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import 'docs_style.dart';

/// A preview viewport offered by the demo and playground stages, so a reader
/// can see how a pattern responds from a small phone up to desktop. Shared by
/// the static [DeviceFrame] and the interactive playground so both wear the
/// same control.
enum DemoViewport {
  phone('Phone', LucideIcons.smartphone, 320),
  tablet('Tablet', LucideIcons.tablet, 768),
  desktop('Desktop', LucideIcons.monitor, null);

  const DemoViewport(this.label, this.icon, this.width);

  /// Human-readable name, also the assistive-tech label.
  final String label;

  /// The glyph shown in the segmented control.
  final IconData icon;

  /// The logical width to constrain the preview to, or `null` to fill the
  /// stage (desktop).
  final double? width;
}

/// The 320dp small-phone width every component is built to work at. A stage
/// never lays a demo out narrower than this; below it, the demo scrolls.
const double _minStageWidth = 320;

/// A header row for a demo or playground panel: a [title] on the left and an
/// optional trailing control on the right. The trailing control is built
/// through [trailingBuilder] so it can go icon-only when the row is tight, and
/// it drops below the title on a very narrow reading column rather than
/// crowding it.
class DemoSectionHeader extends StatelessWidget {
  const DemoSectionHeader({super.key, required this.title, this.trailingBuilder});

  /// The section label, e.g. "Playground" or "Live example".
  final String title;

  /// Builds the trailing control. `compact` is true when the row is too tight
  /// for a roomy control, so the builder can render an icon-only variant.
  final Widget Function(bool compact)? trailingBuilder;

  @override
  Widget build(BuildContext context) {
    final docs = DocsColors.of(context);
    // Announced as a single section-heading node (so screen-reader users can
    // jump between demos), and ellipsised rather than clipped when the row is
    // tight.
    final label = MergeSemantics(
      child: Semantics(
        header: true,
        child: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: DocsType.headline(docs.textPrimary),
        ),
      ),
    );
    if (trailingBuilder == null) return label;

    // Fold the user's text scale into the breakpoints: as the labels grow, the
    // control collapses to icon-only (and then stacks) at a proportionally
    // wider row, so a large text size never crowds or clips the title.
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        // Icon-only once the row can no longer hold three labelled segments
        // beside the title without crowding.
        final trailing = trailingBuilder!(w < 520 * scale);
        // Stack the control under the title on a phone-width reading column.
        if (w < 380 * scale) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [label, const SizedBox(height: 12), trailing],
          );
        }
        return Row(children: [Flexible(child: label), const Spacer(), trailing]);
      },
    );
  }
}

/// The framed stage a live demo renders inside: a white surface card that
/// constrains its [child] to the chosen [viewport] width, centres it when it
/// fits and scrolls it horizontally when the demoed width is wider than the
/// stage rather than overflowing. A [minHeight] gives the stage presence so a
/// small component does not float in a shallow band.
class DemoStageCard extends StatelessWidget {
  const DemoStageCard({
    super.key,
    required this.viewport,
    required this.child,
    this.minHeight = 0,
  });

  final DemoViewport viewport;
  final Widget child;

  /// A floor for the stage height so short demos still read as a deliberate
  /// stage rather than a thin strip.
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final docs = DocsColors.of(context);
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: minHeight),
      decoration: BoxDecoration(
        color: docs.surface,
        borderRadius: BorderRadius.circular(DocsRadii.lg),
        border: Border.all(color: docs.separator),
        boxShadow: DocsShadows.card,
      ),
      padding: const EdgeInsets.all(28),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final available = constraints.maxWidth;
          final w = viewport.width;

          // Desktop fills the stage — but never lays a demo out below the
          // 320dp small-phone width every component is built for. On a stage
          // narrower than that floor (a phone-width reading column), render at
          // 320 and scroll rather than squeeze the demo until it overflows.
          if (w == null) {
            if (available >= _minStageWidth) return Center(child: child);
            return _centredScroll(available, _minStageWidth);
          }

          // A fixed phone/tablet viewport: cap the demo at that width, centre it
          // in the stage, and scroll only when the demo itself is wider than the
          // stage. So a button stays button-sized and fully visible, while a
          // full-width form reflows to the viewport and scrolls.
          return _centredScroll(available, w);
        },
      ),
    );
  }

  /// Frames the demo at [viewportWidth], centred in the stage, and scrolls
  /// horizontally only when the laid-out demo is wider than the [available]
  /// stage. The `minWidth: available` on the inner box means a narrow demo
  /// centres and stays fully visible, while a demo that fills the viewport
  /// grows past the stage and scrolls instead of overflowing.
  Widget _centredScroll(double available, double viewportWidth) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: available),
        child: Center(
          child: _ConstrainedViewport(width: viewportWidth, child: child),
        ),
      ),
    );
  }
}

class _ConstrainedViewport extends StatelessWidget {
  const _ConstrainedViewport({required this.width, required this.child});

  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // Cap the demo at the viewport width and report that width to MediaQuery so
    // width-responsive demos resolve their breakpoints against the frame. A cap
    // (not a fixed size) keeps a fixed-width control at its natural size while a
    // width-filling demo still expands to the viewport.
    return MediaQuery(
      data: media.copyWith(size: Size(width, media.size.height)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width),
        child: child,
      ),
    );
  }
}

/// A segmented control for picking a [DemoViewport]: a rounded track whose
/// active segment lifts onto a raised surface, cross-fading as the selection
/// moves between segments. Shows an icon and label when there is room, and
/// collapses to icon-only (with a tooltip and an assistive-tech label) when
/// [compact].
class DemoViewportControl extends StatelessWidget {
  const DemoViewportControl({
    super.key,
    required this.value,
    required this.onChanged,
    this.compact = false,
  });

  final DemoViewport value;
  final ValueChanged<DemoViewport> onChanged;
  final bool compact;

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
          for (final v in DemoViewport.values)
            _Segment(
              viewport: v,
              selected: v == value,
              compact: compact,
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
    required this.viewport,
    required this.selected,
    required this.compact,
    required this.onTap,
    required this.docs,
  });

  final DemoViewport viewport;
  final bool selected;
  final bool compact;
  final VoidCallback onTap;
  final DocsColors docs;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // The selected segment lifts onto a surface that reads as raised in both
    // modes: white on the light track, and a grey lighter than the dark track
    // (docs.surface is darker than the dark track, so it would recede). The
    // raised fill, not colour, marks the selection.
    final thumbColor = isDark ? docs.fillStrong : docs.surface;

    final icon = Icon(viewport.icon, size: 15, color: docs.textPrimary);
    final labelStyle = DocsType.footnote(docs.textPrimary)
        .copyWith(fontWeight: selected ? FontWeight.w600 : FontWeight.w500);

    final content = AnimatedContainer(
      duration: DsMotion.durationOf(context, DsMotion.base),
      curve: DsMotion.curveOf(context, DsMotion.standard),
      // A 48dp-tall, ≥48dp-wide interactive segment meets the touch-target
      // minimum; the glyph and label sit centred within it.
      constraints: BoxConstraints(minHeight: 48, minWidth: compact ? 48 : 0),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 14),
      decoration: BoxDecoration(
        color: selected ? thumbColor : Colors.transparent,
        borderRadius: BorderRadius.circular(DocsRadii.xs),
        boxShadow: selected ? DocsShadows.thumb : DocsShadows.none,
      ),
      child: compact
          ? icon
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(width: 7),
                Text(viewport.label, style: labelStyle),
              ],
            ),
    );

    // One assistive-tech node: a selectable button labelled by the viewport,
    // with the visual glyph/label and the tooltip both kept out of the
    // semantics tree so the label is announced exactly once. Built on InkWell
    // so it is keyboard-focusable and activates on Enter and Space.
    return MergeSemantics(
      child: Semantics(
        selected: selected,
        label: '${viewport.label} preview',
        child: Tooltip(
          message: viewport.label,
          excludeFromSemantics: true,
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(DocsRadii.xs),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              child: ExcludeSemantics(child: content),
            ),
          ),
        ),
      ),
    );
  }
}
