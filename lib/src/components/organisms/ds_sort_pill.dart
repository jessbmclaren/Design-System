import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icons.dart';
import '../atoms/ds_icon.dart';
import 'ds_data_grid.dart';
import 'ds_sort_builder.dart';

/// A toolbar pill summarising a table's sorts and opening the sort builder.
///
/// [DsSortPill] is the compact trigger that sits above a [DsDataGrid], beside
/// a `DsFilterBar`: it reads "Sorted by Amount +1" (the primary rule's column
/// and how many tie-breaks follow), or just "Sort" while nothing is sorted.
/// Tapping it opens a [DsSortBuilder] in an anchored popover, so the rules
/// are edited in place and every change reports through [onChanged] as a new
/// precedence-ordered list — which plugs straight into a `DsGridView`'s
/// `sorts`.
///
/// The pill is controlled and stateless about its rules: it renders [sorts]
/// and never stores an edit. A null [onChanged] disables it. The popover
/// closes on an outside tap or Escape, and the trigger announces its
/// expanded state to assistive technology.
///
/// ```dart
/// DsSortPill(
///   columns: columns,
///   sorts: view.sorts,
///   onChanged: (next) => setState(
///     () => view = view.copyWith(sorts: next, sort: next.firstOrNull),
///   ),
/// )
/// ```
class DsSortPill extends StatefulWidget {
  /// Creates a sort summary pill.
  const DsSortPill({
    super.key,
    required this.columns,
    required this.sorts,
    required this.onChanged,
    this.emptyLabel = 'Sort',
  });

  /// The columns a sort may target, used to resolve rule labels and offered
  /// by the builder's field picker.
  final List<DsGridColumn> columns;

  /// The current precedence-ordered sorts. The first rule names the pill.
  final List<DsGridSort> sorts;

  /// Called with a new ordered list whenever the rules change in the
  /// builder. Null disables the pill.
  final ValueChanged<List<DsGridSort>>? onChanged;

  /// The pill label while [sorts] is empty.
  final String emptyLabel;

  @override
  State<DsSortPill> createState() => _DsSortPillState();
}

class _DsSortPillState extends State<DsSortPill> {
  OverlayEntry? _popover;

  bool get _open => _popover != null;

  @override
  void dispose() {
    _popover?.remove();
    _popover = null;
    super.dispose();
  }

  @override
  void didUpdateWidget(DsSortPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The open panel re-renders the latest rules on every parent rebuild.
    _popover?.markNeedsBuild();
  }

  void _close() {
    _popover?.remove();
    setState(() => _popover = null);
  }

  void _openPopover() {
    if (widget.onChanged == null) return;
    final OverlayState overlay = Overlay.of(context);
    final RenderBox? pillBox = context.findRenderObject() as RenderBox?;
    final RenderBox? overlayBox =
        overlay.context.findRenderObject() as RenderBox?;
    if (pillBox == null || overlayBox == null) return;
    final Offset origin =
        pillBox.localToGlobal(Offset.zero, ancestor: overlayBox);
    final Size pillSize = pillBox.size;
    final Size overlaySize = overlayBox.size;
    final DsTokens tokens = DsTokens.of(context);

    final double margin = tokens.spacingUnit;
    final double width =
        math.min(440, overlaySize.width - margin * 2);
    final double left = origin.dx
        .clamp(margin, math.max(margin, overlaySize.width - width - margin));
    final double top = origin.dy + pillSize.height + tokens.spacingUnit / 2;
    final double maxHeight =
        math.max(160, overlaySize.height - top - margin);

    final OverlayEntry entry = OverlayEntry(
      builder: (BuildContext context) => Stack(
        children: <Widget>[
          // The barrier: an outside tap closes the popover.
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _close,
            ),
          ),
          Positioned(
            left: left,
            top: math.min(top, overlaySize.height - margin),
            width: width,
            child: CallbackShortcuts(
              bindings: <ShortcutActivator, VoidCallback>{
                const SingleActivator(LogicalKeyboardKey.escape): _close,
              },
              child: FocusScope(
                child: Material(
                  type: MaterialType.transparency,
                  child: Container(
                    constraints: BoxConstraints(maxHeight: maxHeight),
                    decoration: BoxDecoration(
                      color: tokens.formBackgroundColor,
                      borderRadius:
                          BorderRadius.circular(tokens.overlayBorderRadius),
                      border: Border.all(color: tokens.colorBorder),
                      boxShadow: tokens.shadowMedium,
                    ),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(tokens.overlayBorderRadius),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(tokens.spacingUnit * 1.5),
                        child: DsSortBuilder(
                          columns: widget.columns,
                          value: widget.sorts,
                          onChanged: widget.onChanged ?? (_) {},
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    overlay.insert(entry);
    setState(() => _popover = entry);
  }

  void _toggle() {
    if (_open) {
      _close();
    } else {
      _openPopover();
    }
  }

  /// The title of the column behind [sort], falling back to its key.
  String _labelFor(DsGridSort sort) {
    for (final column in widget.columns) {
      if (column.key == sort.columnKey) return column.title;
    }
    return sort.columnKey;
  }

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);
    final bool enabled = widget.onChanged != null;
    final bool hasSorts = widget.sorts.isNotEmpty;
    final String summary = hasSorts
        ? 'Sorted by ${_labelFor(widget.sorts.first)}'
            '${widget.sorts.length > 1 ? ' +${widget.sorts.length - 1}' : ''}'
        : widget.emptyLabel;

    final Color ink = enabled
        ? tokens.colorText
        : tokens.colorText.withValues(alpha: tokens.stateDisabledOpacity);

    return Semantics(
      button: true,
      enabled: enabled,
      expanded: _open,
      label: summary,
      child: FocusableActionDetector(
        enabled: enabled,
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _toggle();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? _toggle : null,
          child: ExcludeSemantics(
            child: Container(
              constraints: BoxConstraints(minHeight: tokens.spacingUnit * 4.5),
              padding:
                  EdgeInsets.symmetric(horizontal: tokens.spacingUnit * 1.5),
              decoration: BoxDecoration(
                color: hasSorts
                    ? tokens.offsetBackgroundColor
                    : tokens.formBackgroundColor,
                borderRadius: BorderRadius.circular(tokens.buttonBorderRadius),
                border: Border.all(
                  color: hasSorts
                      ? tokens.offsetBackgroundColor
                      : tokens.colorBorder,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  DsIcon(
                    icon: DsIcons.sort,
                    size: tokens.iconSizeSm,
                    color: enabled
                        ? tokens.colorSecondaryText
                        : tokens.colorSecondaryText
                            .withValues(alpha: tokens.stateDisabledOpacity),
                  ),
                  SizedBox(width: tokens.spacingUnit),
                  Flexible(
                    child: Text(
                      summary,
                      style: tokens.labelMd.toTextStyle(color: ink),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
