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

/// The framed stage a live demo renders inside: a surface card sized to the
/// chosen [viewport] and centred on the page, so switching Phone / Tablet /
/// Desktop visibly resizes the preview — a phone renders in a narrow card, a
/// desktop fills the stage. The demo keeps its natural size inside the card (a
/// fixed-width control stays centred; a width-filling demo expands to the
/// card), and the card scrolls horizontally when the device is wider than the
/// available stage rather than overflowing. A [minHeight] gives the card
/// presence so a small demo does not float in a shallow band.
class DemoStageCard extends StatelessWidget {
  const DemoStageCard({
    super.key,
    required this.viewport,
    required this.child,
    this.minHeight = 0,
  });

  final DemoViewport viewport;
  final Widget child;

  /// A floor for the card height so short demos still read as a deliberate
  /// stage rather than a thin strip.
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final docs = DocsColors.of(context);
    final media = MediaQuery.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.maxWidth;
        final w = viewport.width;

        // The card wraps a device-width "screen" plus its padding matte, so the
        // demo's usable width IS the device width (a demo built for 320dp gets a
        // full 320, not 320 minus padding). Desktop fills the stage down to the
        // 320dp floor; Phone and Tablet size the screen to the device and report
        // that width to MediaQuery so responsive demos resolve against it.
        const chrome = 58.0; // padding (28 × 2) + hairline border (1 × 2)
        final double cardWidth;
        Widget content = child;
        if (w == null) {
          cardWidth =
              available - chrome >= _minStageWidth ? available : _minStageWidth + chrome;
        } else {
          cardWidth = w + chrome;
          content = MediaQuery(
            data: media.copyWith(size: Size(w, media.size.height)),
            child: child,
          );
        }

        final card = Container(
          width: cardWidth,
          constraints: BoxConstraints(minHeight: minHeight),
          decoration: BoxDecoration(
            color: docs.surface,
            borderRadius: BorderRadius.circular(DocsRadii.lg),
            border: Border.all(color: docs.separator),
            boxShadow: DocsShadows.card,
          ),
          padding: const EdgeInsets.all(28),
          // Natural size inside the card: a width-filling demo expands to it, a
          // fixed-width control stays centred rather than stretching.
          child: Center(child: content),
        );

        // Centre the device-width card on the stage; scroll it when the device
        // is wider than the available width rather than overflowing.
        if (cardWidth <= available) {
          return Align(alignment: Alignment.topCenter, child: card);
        }
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: card,
        );
      },
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
