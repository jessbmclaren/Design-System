import 'package:flutter/material.dart';
import '../../tokens/ds_icons.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';
import '../../util/ds_motion.dart';

/// A single collapsible section within a [DsAccordion].
///
/// Each item pairs a [title] (rendered in the label/medium type ramp) with a
/// [child] body that is revealed when the section is expanded. Provide an
/// optional [leading] widget — such as an icon — to appear before the title.
///
/// Set [initiallyExpanded] to open the section on first build. When the parent
/// [DsAccordion] is single-open (`allowMultiple: false`) and more than one item
/// requests to start expanded, only the first such item opens.
@immutable
class DsAccordionItem {
  /// Creates a section for a [DsAccordion].
  const DsAccordionItem({
    required this.title,
    required this.child,
    this.leading,
    this.initiallyExpanded = false,
  });

  /// The header text. Ellipsizes to a single line so a header never overflows
  /// on narrow screens.
  final String title;

  /// The body revealed when the section is expanded.
  final Widget child;

  /// An optional widget shown before the [title], such as an icon.
  final Widget? leading;

  /// Whether this section starts expanded. Defaults to `false`.
  final bool initiallyExpanded;
}

/// A vertical stack of collapsible [DsAccordionItem] sections.
///
/// Each section shows a tappable header — an optional leading widget, the
/// title, and a trailing chevron that rotates 180° when open — with a body that
/// animates open and closed. A 1px border separates sections and rounds the
/// whole container to the theme's form radius.
///
/// By default the accordion is *single-open*: opening a section closes any
/// other. Set [allowMultiple] to `true` to let sections open independently.
///
/// The widget starts no timers or indefinite animations, so it is safe to
/// render directly in a screenshot or golden test. All colours and radii are
/// read from [DsTokens]; animation durations honour the platform's reduced
/// motion preference via [DsMotion].
///
/// ```dart
/// DsAccordion(
///   allowMultiple: false,
///   items: const [
///     DsAccordionItem(
///       title: 'Shipping',
///       leading: Icon(DsIcons.shipping),
///       child: Text('Ships within two business days.'),
///     ),
///     DsAccordionItem(
///       title: 'Returns',
///       child: Text('30-day return window.'),
///     ),
///   ],
/// )
/// ```
class DsAccordion extends StatefulWidget {
  /// Creates a collapsible accordion from [items].
  const DsAccordion({
    super.key,
    required this.items,
    this.allowMultiple = false,
  });

  /// The sections to render, top to bottom.
  final List<DsAccordionItem> items;

  /// Whether multiple sections may be open at once.
  ///
  /// When `false` (the default) opening a section closes any other, so at most
  /// one body is visible. When `true` sections toggle independently.
  final bool allowMultiple;

  @override
  State<DsAccordion> createState() => _DsAccordionState();
}

class _DsAccordionState extends State<DsAccordion> {
  /// The set of currently-expanded item indices.
  late Set<int> _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = _resolveInitialExpansion();
  }

  @override
  void didUpdateWidget(DsAccordion oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the item count shrank, drop any now-out-of-range indices, and enforce
    // single-open if the mode flipped.
    if (widget.items.length != oldWidget.items.length ||
        widget.allowMultiple != oldWidget.allowMultiple) {
      final next = _expanded.where((i) => i < widget.items.length).toSet();
      if (!widget.allowMultiple && next.length > 1) {
        final first = next.reduce((a, b) => a < b ? a : b);
        _expanded = {first};
      } else {
        _expanded = next;
      }
    }
  }

  Set<int> _resolveInitialExpansion() {
    final open = <int>{};
    for (var i = 0; i < widget.items.length; i++) {
      if (widget.items[i].initiallyExpanded) {
        open.add(i);
        if (!widget.allowMultiple) break;
      }
    }
    return open;
  }

  void _toggle(int index) {
    setState(() {
      if (_expanded.contains(index)) {
        _expanded.remove(index);
      } else {
        if (!widget.allowMultiple) {
          _expanded.clear();
        }
        _expanded.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final radius = BorderRadius.circular(tokens.formBorderRadius);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.formBackgroundColor,
        border: Border.all(color: tokens.colorBorder),
        borderRadius: radius,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < widget.items.length; i++)
              _DsAccordionSection(
                key: ValueKey<int>(i),
                item: widget.items[i],
                expanded: _expanded.contains(i),
                showTopBorder: i != 0,
                onToggle: () => _toggle(i),
              ),
          ],
        ),
      ),
    );
  }
}

/// One header-plus-body section. Private: the public surface is [DsAccordion].
class _DsAccordionSection extends StatelessWidget {
  const _DsAccordionSection({
    super.key,
    required this.item,
    required this.expanded,
    required this.showTopBorder,
    required this.onToggle,
  });

  final DsAccordionItem item;
  final bool expanded;
  final bool showTopBorder;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final motion = DsMotion.durationOf(context, const Duration(milliseconds: 200));
    final curve = DsMotion.curveOf(context, Curves.easeInOut);

    final titleStyle = tokens.labelMd.toTextStyle(color: tokens.colorText).copyWith(
          fontWeight: DsTypography.semiBold,
        );

    final header = Semantics(
      button: true,
      expanded: expanded,
      label: item.title,
      child: InkWell(
        onTap: onToggle,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: DsSpacing.lg,
              vertical: DsSpacing.md,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (item.leading != null) ...[
                  IconTheme.merge(
                    data: IconThemeData(
                      color: tokens.colorSecondaryText,
                      size: DsIconSize.sm,
                    ),
                    child: item.leading!,
                  ),
                  const SizedBox(width: DsSpacing.md),
                ],
                Expanded(
                  child: Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: titleStyle,
                  ),
                ),
                const SizedBox(width: DsSpacing.md),
                ExcludeSemantics(
                  child: AnimatedRotation(
                    turns: expanded ? 0.5 : 0,
                    duration: motion,
                    curve: curve,
                    child: Icon(
                      DsIcons.expandMore,
                      size: DsIconSize.md,
                      color: tokens.colorSecondaryText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // AnimatedSize over a conditionally-built child: when collapsed the body is
    // not in the widget/semantics tree at all (assistive tech doesn't read
    // hidden content), while the height still animates.
    final body = AnimatedSize(
      duration: motion,
      curve: curve,
      alignment: Alignment.topCenter,
      child: expanded
          ? Padding(
              padding: const EdgeInsets.fromLTRB(
                DsSpacing.lg,
                0,
                DsSpacing.lg,
                DsSpacing.lg,
              ),
              child: DefaultTextStyle.merge(
                style:
                    tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText),
                child: SizedBox(width: double.infinity, child: item.child),
              ),
            )
          : const SizedBox(width: double.infinity, height: 0),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: showTopBorder
            ? Border(top: BorderSide(color: tokens.colorBorder))
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          body,
        ],
      ),
    );
  }
}
