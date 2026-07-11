import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../../tokens/ds_icons.dart';
import 'package:flutter/services.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';
import '../../tokens/ds_typography.dart';
import '../atoms/ds_badge.dart';
import '../atoms/ds_icon.dart';

/// A single node in a [DsTreeView].
///
/// A node binds a stable [id] to a visible [label] and, optionally, a leading
/// [icon], a secondary [subtitle], a trailing [badgeCount] (for example a record
/// or child count) and a list of [children]. Nesting [children] produces the
/// group → subgroup → child hierarchy the tree renders, so a node is both a
/// row and, when it [hasChildren], an expandable branch.
///
/// The type is immutable and holds no view state: expansion and selection live
/// in the [DsTreeView], keyed by [id]. Ids must be unique across the whole tree
/// because they key expansion, selection and drag-to-reparent.
@immutable
class DsTreeNode {
  /// Creates a tree node.
  ///
  /// Only [id] and [label] are required. Provide [children] to make the node an
  /// expandable branch; a leaf simply omits them.
  const DsTreeNode({
    required this.id,
    required this.label,
    this.icon,
    this.subtitle,
    this.badgeCount,
    this.children = const <DsTreeNode>[],
  });

  /// The stable identifier used to key expansion, selection and reparenting.
  /// Must be unique across the whole tree.
  final String id;

  /// The primary text shown for the row. Truncated with an ellipsis when it is
  /// too long for the available width.
  final String label;

  /// An optional leading glyph rendered before the [label].
  final IconData? icon;

  /// Optional secondary text shown beneath the [label].
  final String? subtitle;

  /// An optional count rendered as a trailing [DsBadge], for example the
  /// number of records or children the node holds.
  final int? badgeCount;

  /// The child nodes nested beneath this one, in display order.
  final List<DsTreeNode> children;

  /// Whether this node has any [children] and can therefore be expanded.
  bool get hasChildren => children.isNotEmpty;
}

/// A reparent reported by [DsTreeView.onMoveNode].
///
/// [nodeId] is the dragged node; [newParentId] is the node it was dropped onto,
/// or `null` when it was dropped to the root of the tree.
typedef DsTreeReparent = ({String nodeId, String? newParentId});

/// Builds an optional trailing widget for a node, for example a "…" [DsMenu].
///
/// Returning `null` leaves the node with just its [DsTreeNode.badgeCount] (or an
/// empty trailing area). See [DsTreeView.trailingBuilder].
typedef DsTreeTrailingBuilder = Widget? Function(
  BuildContext context,
  DsTreeNode node,
);

/// A hierarchical group tree for organising records into groups, subgroups and
/// children: the Design System's sidebar-style group navigator.
///
/// [DsTreeView] renders [nodes] as a vertical, indentation-guided outline. Each
/// row carries a disclosure chevron (only when the node [DsTreeNode.hasChildren]),
/// an optional leading [DsTreeNode.icon], the [DsTreeNode.label] with an optional
/// [DsTreeNode.subtitle], and a trailing area holding the [DsTreeNode.badgeCount]
/// as a [DsBadge] and/or the [trailingBuilder] widget. Depth is shown with
/// [indent] logical pixels per level and subtle vertical guide lines. Every
/// colour, radius, spacing and type style is read from [DsTokens], so the tree
/// re-brands automatically with the active white-label theme.
///
/// ## Expansion & selection
///
/// Tapping a row's chevron expands or collapses that branch; tapping the row body
/// selects the node. Both are supported *controlled* and *uncontrolled*:
///
/// * **Expansion** is controlled when [expandedIds] is non-null (changes are
///   reported through [onExpandedChanged] and the parent passes the next set
///   back). When [expandedIds] is null the tree holds expansion internally,
///   seeded from [initiallyExpandsAll].
/// * **Selection** is controlled when [selectedId] is non-null (taps are reported
///   through [onSelect]); otherwise the tree remembers the last selected id
///   itself while still calling [onSelect].
///
/// ## Drag-to-reparent
///
/// When [onMoveNode] is provided rows become draggable ([LongPressDraggable]) and
/// every row accepts drops ([DragTarget]). Dropping a node onto a row reports a
/// [DsTreeReparent] with that row as `newParentId`; dropping to empty space
/// reports a `null` parent (move to the root). Dropping a node onto itself or one
/// of its own descendants would create a cycle and is never reported. Reparenting
/// is *controlled*: the tree never mutates [nodes].
///
/// ## Responsiveness
///
/// Rows never overflow. The label ellipsizes and the trailing badge stays
/// visible, and indentation is capped against the available width so even deeply
/// nested rows fit a 320dp phone. Give the tree a bounded height inside a scroll
/// view to page through a long outline; otherwise it shrink-wraps its content.
///
/// ## Accessibility & screenshots
///
/// Each row is a focusable semantics button that announces its label, its
/// expanded / collapsed state (when it has children) and its selected state.
/// Reaching a row by Tab and pressing Enter or Space selects it; the left and
/// right arrow keys collapse and expand a branch. The widget runs no timers or
/// indefinite animations, so it renders a stable frame that is safe to capture in
/// golden tests and screenshots.
class DsTreeView extends StatefulWidget {
  /// Creates a tree view.
  const DsTreeView({
    super.key,
    required this.nodes,
    this.selectedId,
    this.onSelect,
    this.expandedIds,
    this.onExpandedChanged,
    this.initiallyExpandsAll = true,
    this.onMoveNode,
    this.trailingBuilder,
    this.indent = 20,
  });

  /// The root nodes of the tree, in display order.
  final List<DsTreeNode> nodes;

  /// The id of the selected node, when selection is controlled. When null the
  /// tree remembers the last tapped node internally.
  final String? selectedId;

  /// Called with a node's id when its row is selected.
  final ValueChanged<String>? onSelect;

  /// The set of expanded node ids, when expansion is controlled. When null the
  /// tree holds expansion internally, seeded from [initiallyExpandsAll].
  final Set<String>? expandedIds;

  /// Called with the next set of expanded ids whenever a branch is toggled.
  final ValueChanged<Set<String>>? onExpandedChanged;

  /// Whether every branch starts expanded when expansion is uncontrolled
  /// ([expandedIds] is null). Ignored when expansion is controlled.
  final bool initiallyExpandsAll;

  /// Called when a node is dropped onto a new parent. When non-null, rows become
  /// draggable and accept drops. The tree is a controlled reparenting component:
  /// it reports the move but never mutates [nodes].
  final ValueChanged<DsTreeReparent>? onMoveNode;

  /// Builds an optional trailing widget per node, shown after the badge, for
  /// example a "…" [DsMenu].
  final DsTreeTrailingBuilder? trailingBuilder;

  /// The horizontal indentation added per depth level, in logical pixels.
  final double indent;

  @override
  State<DsTreeView> createState() => _DsTreeViewState();
}

class _DsTreeViewState extends State<DsTreeView> {
  /// Internal expansion, used only when [DsTreeView.expandedIds] is null.
  late Set<String> _internalExpanded;

  /// Internal selection, used only when [DsTreeView.selectedId] is null.
  String? _internalSelectedId;

  /// A flat lookup of every node by id, rebuilt each build so the drag-and-drop
  /// callbacks can walk the tree to reject cycles.
  final Map<String, DsTreeNode> _byId = <String, DsTreeNode>{};

  /// Maps each node id to its parent's id (absent for a root node), used to
  /// suppress no-op reparents onto a node's current parent.
  final Map<String, String> _parentOf = <String, String>{};

  @override
  void initState() {
    super.initState();
    _internalExpanded = widget.expandedIds == null
        ? _seedExpanded()
        : <String>{};
    _internalSelectedId = widget.selectedId;
  }

  Set<String> _seedExpanded() {
    final set = <String>{};
    if (!widget.initiallyExpandsAll) return set;
    void walk(List<DsTreeNode> nodes) {
      for (final node in nodes) {
        if (node.hasChildren) {
          set.add(node.id);
          walk(node.children);
        }
      }
    }

    walk(widget.nodes);
    return set;
  }

  // --- Expansion ------------------------------------------------------------

  bool _isExpanded(String id) => widget.expandedIds != null
      ? widget.expandedIds!.contains(id)
      : _internalExpanded.contains(id);

  void _toggleExpanded(String id) {
    final currently = _isExpanded(id);
    final next = Set<String>.of(widget.expandedIds ?? _internalExpanded);
    if (currently) {
      next.remove(id);
    } else {
      next.add(id);
    }
    widget.onExpandedChanged?.call(next);
    if (widget.expandedIds == null) {
      setState(() => _internalExpanded = next);
    }
  }

  void _setExpanded(String id, {required bool expanded}) {
    if (_isExpanded(id) != expanded) _toggleExpanded(id);
  }

  // --- Selection ------------------------------------------------------------

  String? get _effectiveSelectedId => widget.selectedId ?? _internalSelectedId;

  void _select(String id) {
    widget.onSelect?.call(id);
    if (widget.selectedId == null) {
      setState(() => _internalSelectedId = id);
    }
  }

  // --- Reparenting ----------------------------------------------------------

  /// Whether [candidateId] is [ancestorId] itself or sits anywhere within its
  /// subtree: the two cases that would make a reparent create a cycle.
  bool _isSelfOrDescendant(String ancestorId, String candidateId) {
    if (ancestorId == candidateId) return true;
    final ancestor = _byId[ancestorId];
    if (ancestor == null) return false;
    var found = false;
    void walk(DsTreeNode node) {
      for (final child in node.children) {
        if (found) return;
        if (child.id == candidateId) {
          found = true;
          return;
        }
        walk(child);
      }
    }

    walk(ancestor);
    return found;
  }

  /// Whether [dragId] may be reparented under [targetId] without creating a
  /// cycle. A null [targetId] (the root) is always a legal destination.
  bool _canReparent(String dragId, String? targetId) {
    if (targetId == null) return true;
    return !_isSelfOrDescendant(dragId, targetId);
  }

  void _emitMove(String dragId, String? targetId) {
    if (!_canReparent(dragId, targetId)) return;
    // Dropping a node back onto its current parent (or a root node onto the
    // root) changes nothing; report a move only when the parent actually
    // differs, so consumers never take a spurious write from a "put it back".
    if (_parentOf[dragId] == targetId) return;
    widget.onMoveNode?.call((nodeId: dragId, newParentId: targetId));
  }

  // --- Build ----------------------------------------------------------------

  void _indexNodes() {
    _byId.clear();
    _parentOf.clear();
    void walk(List<DsTreeNode> nodes, String? parentId) {
      for (final node in nodes) {
        _byId[node.id] = node;
        if (parentId != null) _parentOf[node.id] = parentId;
        walk(node.children, node.id);
      }
    }

    walk(widget.nodes, null);
  }

  void _flatten(List<DsTreeNode> nodes, int depth, List<_VisibleRow> out) {
    for (final node in nodes) {
      out.add(_VisibleRow(node, depth));
      if (node.hasChildren && _isExpanded(node.id)) {
        _flatten(node.children, depth + 1, out);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    _indexNodes();

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        final rows = <_VisibleRow>[];
        _flatten(widget.nodes, 0, rows);

        final tree = Semantics(
          container: true,
          explicitChildNodes: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (final row in rows) _buildRow(context, tokens, row, maxWidth),
            ],
          ),
        );

        if (widget.onMoveNode == null) return tree;

        // The root drop target: a drop that lands in empty space (not over any
        // row) reparents the dragged node to the root. Row targets sit on top of
        // it, so a drop over a row is captured there instead.
        return DragTarget<String>(
          onWillAcceptWithDetails: (_) => true,
          onAcceptWithDetails: (details) => _emitMove(details.data, null),
          builder: (context, candidate, rejected) => tree,
        );
      },
    );
  }

  Widget _buildRow(
    BuildContext context,
    DsTokens tokens,
    _VisibleRow visible,
    double maxWidth,
  ) {
    final node = visible.node;
    final rowWidget = _DsTreeRow(
      key: ValueKey<String>('ds-tree-row-${node.id}'),
      tokens: tokens,
      node: node,
      depth: visible.depth,
      indent: widget.indent,
      maxWidth: maxWidth,
      expanded: _isExpanded(node.id),
      selected: _effectiveSelectedId == node.id,
      trailing: _buildTrailing(context, tokens, node),
      onSelect: () => _select(node.id),
      onToggle: node.hasChildren ? () => _toggleExpanded(node.id) : null,
      onSetExpanded: node.hasChildren
          ? (value) => _setExpanded(node.id, expanded: value)
          : null,
    );

    if (widget.onMoveNode == null) return rowWidget;

    return DragTarget<String>(
      // Always capture so a drop over a row never falls through to the root
      // target; the cycle guard is enforced in [_emitMove] instead, which keeps
      // a self / descendant drop from being reported at all.
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) => _emitMove(details.data, node.id),
      builder: (context, candidate, rejected) {
        final draggingId = candidate.isNotEmpty ? candidate.first : null;
        final active = draggingId != null &&
            draggingId != node.id &&
            _canReparent(draggingId, node.id);
        final target = active
            ? DecoratedBox(
                decoration: BoxDecoration(
                  color: tokens.offsetBackgroundColor,
                  borderRadius: BorderRadius.circular(tokens.formBorderRadius),
                  border: Border.all(color: tokens.formHighlightColorBorder),
                ),
                child: rowWidget,
              )
            : rowWidget;
        return LongPressDraggable<String>(
          data: node.id,
          dragAnchorStrategy: childDragAnchorStrategy,
          feedback: _dragFeedback(tokens, node),
          childWhenDragging: Opacity(opacity: 0.4, child: rowWidget),
          child: target,
        );
      },
    );
  }

  Widget? _buildTrailing(
    BuildContext context,
    DsTokens tokens,
    DsTreeNode node,
  ) {
    final custom = widget.trailingBuilder?.call(context, node);
    final badge =
        node.badgeCount != null ? DsBadge(label: '${node.badgeCount}') : null;
    if (badge == null && custom == null) return null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ?badge,
        if (badge != null && custom != null)
          SizedBox(width: tokens.spacingUnit),
        ?custom,
      ],
    );
  }

  Widget _dragFeedback(DsTokens tokens, DsTreeNode node) {
    return Material(
      type: MaterialType.transparency,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 280),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.formBackgroundColor,
            borderRadius: BorderRadius.circular(tokens.formBorderRadius),
            border: Border.all(color: tokens.colorBorder),
            boxShadow: tokens.shadowMedium,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: tokens.spacingUnit * 1.5,
              vertical: tokens.spacingUnit,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (node.icon != null) ...[
                  DsIcon(
                    icon: node.icon!,
                    size: DsIconSize.sm,
                    color: tokens.colorSecondaryText,
                  ),
                  SizedBox(width: tokens.spacingUnit),
                ],
                Flexible(
                  child: Text(
                    node.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tokens.bodySm.toTextStyle(color: tokens.colorText),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A node paired with the depth at which it is rendered.
@immutable
class _VisibleRow {
  const _VisibleRow(this.node, this.depth);

  final DsTreeNode node;
  final int depth;
}

/// Intent to expand (true) or collapse (false) the focused branch by keyboard.
class _SetExpandedIntent extends Intent {
  const _SetExpandedIntent({required this.expanded});

  final bool expanded;
}

/// A single interactive tree row: indentation guides, disclosure chevron,
/// optional icon, label + subtitle and a trailing area.
class _DsTreeRow extends StatefulWidget {
  const _DsTreeRow({
    super.key,
    required this.tokens,
    required this.node,
    required this.depth,
    required this.indent,
    required this.maxWidth,
    required this.expanded,
    required this.selected,
    required this.trailing,
    required this.onSelect,
    required this.onToggle,
    required this.onSetExpanded,
  });

  final DsTokens tokens;
  final DsTreeNode node;
  final int depth;
  final double indent;
  final double maxWidth;
  final bool expanded;
  final bool selected;
  final Widget? trailing;
  final VoidCallback onSelect;
  final VoidCallback? onToggle;
  final ValueChanged<bool>? onSetExpanded;

  bool get hasChildren => node.hasChildren;

  @override
  State<_DsTreeRow> createState() => _DsTreeRowState();
}

class _DsTreeRowState extends State<_DsTreeRow> {
  /// The fixed square that holds the disclosure chevron (or its empty slot).
  static const double _chevronSlot = 24;

  /// Room reserved for the chevron, trailing area and paddings when capping
  /// indentation, so the label always keeps some width on a narrow screen.
  static const double _rowReserve = 120;

  bool _focused = false;
  bool _hovered = false;

  double get _perLevel {
    if (widget.depth == 0) return widget.indent;
    final maxIndent = math.max(0.0, widget.maxWidth - _rowReserve);
    return math.min(widget.indent, maxIndent / widget.depth);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = widget.tokens;
    final node = widget.node;
    final perLevel = _perLevel;
    // The leading gutter before the first indent step / chevron.
    final leadingPad = tokens.spacingUnit;
    final indentWidth = leadingPad + widget.depth * perLevel;

    final chevron = SizedBox(
      width: _chevronSlot,
      height: _chevronSlot,
      child: widget.hasChildren
          ? Material(
              type: MaterialType.transparency,
              child: InkWell(
                canRequestFocus: false,
                borderRadius: BorderRadius.circular(tokens.formBorderRadius),
                onTap: widget.onToggle,
                child: Center(
                  child: DsIcon(
                    icon: widget.expanded
                        ? DsIcons.expandMore
                        : DsIcons.chevronRight,
                    size: DsIconSize.sm,
                    color: tokens.colorSecondaryText,
                  ),
                ),
              ),
            )
          : null,
    );

    final labelColumn = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          node.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: tokens.bodySm.toTextStyle(color: tokens.colorText).copyWith(
                fontWeight: widget.selected ? DsTypography.medium : null,
              ),
        ),
        if (node.subtitle != null) ...[
          SizedBox(height: tokens.spacingUnit / 4),
          Text(
            node.subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tokens.labelSm.toTextStyle(color: tokens.colorSecondaryText),
          ),
        ],
      ],
    );

    final body = Row(
      children: <Widget>[
        if (node.icon != null) ...[
          DsIcon(
            icon: node.icon!,
            size: DsIconSize.sm,
            color: widget.selected
                ? tokens.colorText
                : tokens.colorSecondaryText,
          ),
          SizedBox(width: tokens.spacingUnit),
        ],
        Expanded(child: labelColumn),
      ],
    );

    final content = Row(
      children: <Widget>[
        SizedBox(width: indentWidth),
        chevron,
        SizedBox(width: tokens.spacingUnit / 2),
        Expanded(
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              canRequestFocus: false,
              onTap: widget.onSelect,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: tokens.spacingUnit + tokens.spacingUnit / 4,
                ),
                child: body,
              ),
            ),
          ),
        ),
        if (widget.trailing != null) ...[
          SizedBox(width: tokens.spacingUnit),
          widget.trailing!,
        ],
        SizedBox(width: tokens.spacingUnit),
      ],
    );

    final decorated = Container(
      margin: EdgeInsets.symmetric(
        horizontal: tokens.spacingUnit / 2,
        vertical: 1,
      ),
      decoration: BoxDecoration(
        color: widget.selected ? tokens.offsetBackgroundColor : null,
        borderRadius: BorderRadius.circular(tokens.formBorderRadius),
        border: Border.all(
          color: _focused
              ? tokens.formHighlightColorBorder
              : const Color(0x00000000),
        ),
      ),
      child: CustomPaint(
        painter: _GuidesPainter(
          depth: widget.depth,
          perLevel: perLevel,
          leadingPad: leadingPad,
          color: tokens.colorBorder,
        ),
        child: content,
      ),
    );

    final shortcuts = widget.hasChildren
        ? const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.arrowRight):
                _SetExpandedIntent(expanded: true),
            SingleActivator(LogicalKeyboardKey.arrowLeft):
                _SetExpandedIntent(expanded: false),
          }
        : const <ShortcutActivator, Intent>{};

    return Semantics(
      container: true,
      button: true,
      selected: widget.selected,
      expanded: widget.hasChildren ? widget.expanded : null,
      label: node.label,
      onTap: widget.onSelect,
      excludeSemantics: true,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        shortcuts: shortcuts,
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onSelect();
              return null;
            },
          ),
          _SetExpandedIntent: CallbackAction<_SetExpandedIntent>(
            onInvoke: (intent) {
              widget.onSetExpanded?.call(intent.expanded);
              return null;
            },
          ),
        },
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        onShowHoverHighlight: (value) => setState(() => _hovered = value),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: (_hovered && !widget.selected)
                ? tokens.offsetBackgroundColor.withValues(alpha: 0.5)
                : null,
          ),
          child: decorated,
        ),
      ),
    );
  }
}

/// Paints the subtle vertical guide lines that mark a row's depth, one per
/// indentation step, spanning the row's full height so they read as continuous
/// lines down stacked rows.
class _GuidesPainter extends CustomPainter {
  const _GuidesPainter({
    required this.depth,
    required this.perLevel,
    required this.leadingPad,
    required this.color,
  });

  final int depth;
  final double perLevel;
  final double leadingPad;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (depth == 0 || perLevel <= 0) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (var i = 0; i < depth; i++) {
      final x = leadingPad + (i + 0.5) * perLevel;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_GuidesPainter old) =>
      old.depth != depth ||
      old.perLevel != perLevel ||
      old.leadingPad != leadingPad ||
      old.color != color;
}
