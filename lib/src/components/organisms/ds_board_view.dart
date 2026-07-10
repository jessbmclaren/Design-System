import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_elevation.dart';
import '../../tokens/ds_icon_size.dart';
import '../../tokens/ds_spacing.dart';
import '../../tokens/ds_typography.dart';
import '../atoms/ds_avatar.dart';
import '../atoms/ds_badge.dart';
import '../atoms/ds_icon.dart';
import '../molecules/ds_menu.dart';
import 'ds_data_grid.dart';

/// A flagship board (kanban) view for the Design System.
///
/// [DsBoardView] arranges typed [rows] into vertical **lanes** grouped by a
/// single status / select column identified by [groupByKey]. It reuses the data
/// grid's shared vocabulary — [DsGridColumn], [DsGridRow], [DsCellType] and
/// [DsGridOption] — so a table and a board can be driven from exactly the same
/// data. Every colour, radius, padding and type style is read from [DsTokens],
/// so the board re-brands automatically with the active white-label theme.
///
/// ## Lanes
///
/// One lane is rendered for each [DsGridOption] declared by the group column, in
/// option order, followed by a trailing "[ungroupedLabel]" lane that collects
/// rows whose group value is null, empty, or not one of the declared options.
/// Each lane shows a header — the option's label as a [DsBadge] (honouring its
/// [DsGridOption.variant] or [DsGridOption.color]) plus a live card count — above
/// a list of record cards.
///
/// ## Cards
///
/// Each card shows the record's primary text (the first [DsCellType.text]
/// column, or the first column) prominently, then a few secondary fields drawn
/// with the same atoms the grid uses: a [DsBadge] for a status / select value, a
/// [DsAvatar] and name for a user, and formatted currency, number, date, rating
/// and progress values. Supply [cardBuilder] to replace the card body entirely;
/// the board still wraps it so it stays draggable, tappable and movable.
/// [onCardTap] fires when a card is tapped.
///
/// ## Moving cards
///
/// The board is a **controlled** component: it never mutates [rows]. A move is
/// reported through [onRowMoved] as a `(rowId, toGroup)` record, where `toGroup`
/// is the destination option's [DsGridOption.value] — or `null` for the
/// ungrouped lane — and the parent is expected to apply the change and pass
/// updated [rows] back.
///
/// Two ways to move a card are always offered so the board is operable without a
/// pointer:
///
/// * **Drag and drop** — press and hold a card, then drag it onto another lane.
///   Built on [LongPressDraggable] / [DragTarget] so it never steals the lane's
///   scroll gesture and runs no timer or animation at rest.
/// * **A "Move to…" menu** — every card carries a [DsMenu] affordance listing
///   the other lanes, reachable and operable by keyboard and screen reader.
///
/// ## Responsiveness
///
/// The board measures the available width with a [LayoutBuilder]:
///
/// * **At or above [compactBreakpoint]** lanes sit side by side, each
///   [laneWidth] wide, in a horizontal scroll; lane headers stay fixed while
///   each lane's cards scroll vertically (when the board is given a bounded
///   height).
/// * **Below [compactBreakpoint]** (e.g. a 320dp phone) lanes stack vertically,
///   each spanning the full width and collapsible via its header, and the whole
///   board scrolls vertically. This never overflows on a narrow screen.
///
/// When given a bounded height the board scrolls within it; when its height is
/// unbounded it shrink-wraps to its content.
///
/// ## Accessibility & screenshots
///
/// Lanes and cards carry container semantics with descriptive labels, the move
/// affordance is a labelled button reachable by keyboard, and the widget runs no
/// timers or indefinite animations — so it renders a stable frame that is safe
/// to capture in golden tests and screenshots.
class DsBoardView extends StatefulWidget {
  /// Creates a board (kanban) view.
  ///
  /// [columns], [rows] and [groupByKey] are required. [groupByKey] must match a
  /// column's [DsGridColumn.key]; that column's [DsGridColumn.options] define
  /// the lanes.
  const DsBoardView({
    super.key,
    required this.columns,
    required this.rows,
    required this.groupByKey,
    this.onRowMoved,
    this.onCardTap,
    this.cardBuilder,
    this.laneWidth = 280,
    this.ungroupedLabel = 'Ungrouped',
    this.compactBreakpoint = 600,
    this.maxCardFields = 4,
  });

  /// The full column set, used both to render card fields and to resolve the
  /// group column's [DsGridColumn.options] into lanes.
  final List<DsGridColumn> columns;

  /// The rows of data to place into lanes.
  final List<DsGridRow> rows;

  /// The [DsGridColumn.key] of the status / single-select column the board is
  /// grouped by.
  final String groupByKey;

  /// Called when a card is moved to another lane, with the moved row's id and
  /// the destination group (an option's [DsGridOption.value], or `null` for the
  /// ungrouped lane). Using `null` — rather than a sentinel string — keeps the
  /// ungrouped lane distinct from an option that legitimately has an empty
  /// value. The board is controlled: it does not mutate [rows] itself.
  final ValueChanged<({String rowId, String? toGroup})>? onRowMoved;

  /// Called when a card is tapped. A null callback leaves cards non-interactive
  /// (but still draggable and movable via the "Move to…" menu).
  final void Function(DsGridRow row)? onCardTap;

  /// An optional builder that replaces the default card body. The board still
  /// wraps the result so it stays draggable, tappable and movable.
  final Widget Function(DsGridRow row)? cardBuilder;

  /// The width of each lane, in logical pixels, in the side-by-side layout.
  final double laneWidth;

  /// The label of the trailing lane that collects rows with no matching group
  /// value.
  final String ungroupedLabel;

  /// The width, in logical pixels, below which lanes stack vertically instead of
  /// sitting side by side.
  final double compactBreakpoint;

  /// The maximum number of secondary fields shown on a default card, keeping it
  /// compact.
  final int maxCardFields;

  @override
  State<DsBoardView> createState() => _DsBoardViewState();
}

class _DsBoardViewState extends State<DsBoardView> {
  static const double _cardRadius = 10;
  static const double _laneRadius = 12;
  static const double _emptyLaneHeight = 64;
  static const double _menuTrigger = 36;

  /// Lane keys currently collapsed in the stacked (narrow) layout.
  final Set<String> _collapsed = <String>{};

  /// The lanes resolved for the current build.
  late List<_BoardLane> _lanes;

  /// Maps each row id to the index of the lane it currently sits in.
  late Map<String, int> _rowLane;

  final ScrollController _boardHController = ScrollController();
  final ScrollController _boardVController = ScrollController();

  @override
  void dispose() {
    _boardHController.dispose();
    _boardVController.dispose();
    super.dispose();
  }

  // --- Lane resolution ------------------------------------------------------

  DsGridColumn? _groupColumn() {
    for (final column in widget.columns) {
      if (column.key == widget.groupByKey) return column;
    }
    return null;
  }

  DsGridColumn _primaryColumn() {
    for (final column in widget.columns) {
      if (column.type == DsCellType.text) return column;
    }
    return widget.columns.isNotEmpty
        ? widget.columns.first
        : const DsGridColumn(key: '__none__', title: '');
  }

  void _resolveLanes() {
    final group = _groupColumn();
    final options = group?.options ?? const <DsGridOption>[];

    final buckets = <String, List<DsGridRow>>{
      for (final option in options) option.value: <DsGridRow>[],
    };
    final ungrouped = <DsGridRow>[];

    for (final row in widget.rows) {
      final value = row.cells[widget.groupByKey];
      final key = value is String ? value : value?.toString();
      if (key != null && key.isNotEmpty && buckets.containsKey(key)) {
        buckets[key]!.add(row);
      } else {
        ungrouped.add(row);
      }
    }

    final lanes = <_BoardLane>[];
    var index = 0;
    for (final option in options) {
      lanes.add(
        _BoardLane(
          index: index,
          key: 'opt:${option.value}',
          groupValue: option.value,
          label: option.effectiveLabel,
          variant: option.variant,
          color: option.color,
          isUngrouped: false,
          rows: buckets[option.value]!,
        ),
      );
      index++;
    }
    lanes.add(
      _BoardLane(
        index: index,
        key: '__ungrouped__',
        groupValue: null,
        label: widget.ungroupedLabel,
        variant: DsBadgeVariant.neutral,
        color: null,
        isUngrouped: true,
        rows: ungrouped,
      ),
    );

    _lanes = lanes;
    _rowLane = <String, int>{
      for (final lane in lanes)
        for (final row in lane.rows) row.id: lane.index,
    };
  }

  void _emitMove(String rowId, _BoardLane target) {
    widget.onRowMoved?.call((rowId: rowId, toGroup: target.groupValue));
  }

  void _toggleCollapsed(String laneKey) {
    setState(() {
      if (!_collapsed.remove(laneKey)) _collapsed.add(laneKey);
    });
  }

  // --- Build ----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final double? maxHeight =
            constraints.maxHeight.isFinite ? constraints.maxHeight : null;

        _resolveLanes();

        final narrow = maxWidth < widget.compactBreakpoint;
        return narrow
            ? _buildStacked(tokens, maxHeight)
            : _buildSideBySide(tokens, maxHeight);
      },
    );
  }

  // --- Side-by-side (wide) --------------------------------------------------

  Widget _buildSideBySide(DsTokens tokens, double? maxHeight) {
    final children = <Widget>[];
    for (var i = 0; i < _lanes.length; i++) {
      if (i > 0) children.add(const SizedBox(width: DsSpacing.md));
      children.add(_wideLane(tokens, _lanes[i], maxHeight));
    }

    final row = Padding(
      padding: const EdgeInsets.all(DsSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );

    final scroll = Scrollbar(
      controller: _boardHController,
      child: SingleChildScrollView(
        controller: _boardHController,
        scrollDirection: Axis.horizontal,
        child: row,
      ),
    );

    final board = Semantics(
      container: true,
      label: 'Board with ${_lanes.length} lanes',
      child: scroll,
    );

    if (maxHeight == null) return board;
    return SizedBox(height: maxHeight, child: board);
  }

  Widget _wideLane(DsTokens tokens, _BoardLane lane, double? maxHeight) {
    final header = _laneHeader(tokens, lane, narrow: false);
    final cards = _cardList(tokens, lane);

    final Widget body = maxHeight == null
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              const SizedBox(height: DsSpacing.sm),
              Flexible(child: cards),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              header,
              const SizedBox(height: DsSpacing.sm),
              Expanded(
                child: SingleChildScrollView(child: cards),
              ),
            ],
          );

    final lane0 = SizedBox(
      width: widget.laneWidth,
      height: maxHeight,
      child: _laneDropTarget(
        tokens,
        lane,
        Padding(
          padding: const EdgeInsets.all(DsSpacing.sm),
          child: body,
        ),
      ),
    );
    return lane0;
  }

  // --- Stacked (narrow) -----------------------------------------------------

  Widget _buildStacked(DsTokens tokens, double? maxHeight) {
    final children = <Widget>[];
    for (var i = 0; i < _lanes.length; i++) {
      if (i > 0) children.add(const SizedBox(height: DsSpacing.md));
      children.add(_narrowLane(tokens, _lanes[i]));
    }

    final column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );

    final padded = Padding(
      padding: const EdgeInsets.all(DsSpacing.sm),
      child: column,
    );

    final board = Semantics(
      container: true,
      label: 'Board with ${_lanes.length} lanes',
      child: padded,
    );

    if (maxHeight == null) return board;
    return SizedBox(
      height: maxHeight,
      child: Scrollbar(
        controller: _boardVController,
        child: SingleChildScrollView(
          controller: _boardVController,
          child: board,
        ),
      ),
    );
  }

  Widget _narrowLane(DsTokens tokens, _BoardLane lane) {
    final collapsed = _collapsed.contains(lane.key);
    return _laneDropTarget(
      tokens,
      lane,
      Padding(
        padding: const EdgeInsets.all(DsSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _laneHeader(tokens, lane, narrow: true, collapsed: collapsed),
            if (!collapsed) ...[
              const SizedBox(height: DsSpacing.sm),
              _cardList(tokens, lane),
            ],
          ],
        ),
      ),
    );
  }

  // --- Lane chrome ----------------------------------------------------------

  /// Wraps a lane's [content] in its surface and a [DragTarget] so cards can be
  /// dropped onto it. The target rejects drops from the lane a card already sits
  /// in.
  Widget _laneDropTarget(DsTokens tokens, _BoardLane lane, Widget content) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (details) =>
          (_rowLane[details.data] ?? -1) != lane.index,
      onAcceptWithDetails: (details) => _emitMove(details.data, lane),
      builder: (context, candidate, rejected) {
        final active = candidate.isNotEmpty;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.offsetBackgroundColor,
            borderRadius: BorderRadius.circular(_laneRadius),
            border: Border.all(
              color: active ? tokens.formHighlightColorBorder : tokens.colorBorder,
              width: active ? 2 : 1,
            ),
          ),
          child: content,
        );
      },
    );
  }

  Widget _laneHeader(
    DsTokens tokens,
    _BoardLane lane, {
    required bool narrow,
    bool collapsed = false,
  }) {
    final badge = _laneBadge(tokens, lane);
    final count = Text(
      '${lane.rows.length}',
      style: tokens.labelSm.toTextStyle(color: tokens.colorSecondaryText),
    );

    final row = Row(
      children: [
        Flexible(child: badge),
        const SizedBox(width: DsSpacing.sm),
        count,
        if (narrow) ...[
          const Spacer(),
          Semantics(
            button: true,
            label: collapsed ? 'Expand ${lane.label}' : 'Collapse ${lane.label}',
            child: InkWell(
              onTap: () => _toggleCollapsed(lane.key),
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: const EdgeInsets.all(DsSpacing.xs),
                child: DsIcon(
                  icon: collapsed ? Icons.expand_more : Icons.expand_less,
                  size: DsIconSize.md,
                  color: tokens.colorSecondaryText,
                ),
              ),
            ),
          ),
        ],
      ],
    );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: '${lane.label} lane, ${lane.rows.length} cards',
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DsSpacing.xs,
          vertical: DsSpacing.xs,
        ),
        child: row,
      ),
    );
  }

  Widget _laneBadge(DsTokens tokens, _BoardLane lane) {
    final color = lane.color;
    if (color != null) return _colorPill(tokens, lane.label, color);
    return DsBadge(
      label: lane.label,
      variant: lane.variant ?? DsBadgeVariant.neutral,
    );
  }

  // --- Cards ----------------------------------------------------------------

  Widget _cardList(DsTokens tokens, _BoardLane lane) {
    if (lane.rows.isEmpty) {
      return _emptyLane(tokens);
    }
    final children = <Widget>[];
    for (var i = 0; i < lane.rows.length; i++) {
      if (i > 0) children.add(const SizedBox(height: DsSpacing.sm));
      children.add(_card(tokens, lane, lane.rows[i]));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    );
  }

  Widget _emptyLane(DsTokens tokens) {
    return Container(
      height: _emptyLaneHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: tokens.colorBorder),
      ),
      child: Text(
        'No cards',
        style: tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText),
      ),
    );
  }

  Widget _card(DsTokens tokens, _BoardLane lane, DsGridRow row) {
    final title = _primaryText(row);
    final body = widget.cardBuilder?.call(row) ?? _defaultCardBody(tokens, row);

    final surface = DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.formBackgroundColor,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: tokens.colorBorder),
      ),
      child: Stack(
        children: [
          Padding(padding: const EdgeInsets.all(DsSpacing.md), child: body),
          Positioned(
            top: DsSpacing.xxs,
            right: DsSpacing.xxs,
            child: _moveMenu(tokens, lane, row, title),
          ),
        ],
      ),
    );

    final onTap = widget.onCardTap;
    final interactive = Material(
      type: MaterialType.transparency,
      borderRadius: BorderRadius.circular(_cardRadius),
      clipBehavior: Clip.antiAlias,
      child: onTap == null
          ? surface
          : InkWell(onTap: () => onTap(row), child: surface),
    );

    final semantic = Semantics(
      container: true,
      explicitChildNodes: true,
      label: title,
      child: interactive,
    );

    return LongPressDraggable<String>(
      data: row.id,
      dragAnchorStrategy: childDragAnchorStrategy,
      feedback: _feedback(tokens, surface),
      childWhenDragging: Opacity(opacity: 0.4, child: semantic),
      child: semantic,
    );
  }

  Widget _feedback(DsTokens tokens, Widget surface) {
    return Material(
      type: MaterialType.transparency,
      child: SizedBox(
        width: widget.laneWidth - DsSpacing.md,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_cardRadius),
            boxShadow: DsElevation.medium,
          ),
          child: surface,
        ),
      ),
    );
  }

  Widget _moveMenu(
    DsTokens tokens,
    _BoardLane lane,
    DsGridRow row,
    String title,
  ) {
    final items = <DsMenuItem>[
      for (final other in _lanes)
        if (other.index != lane.index)
          DsMenuItem(
            label: 'Move to ${other.label}',
            icon: Icons.arrow_forward,
            onSelected: () => _emitMove(row.id, other),
          ),
    ];
    return DsMenu(
      trigger: SizedBox(
        width: _menuTrigger,
        height: _menuTrigger,
        child: Center(
          child: DsIcon(
            icon: Icons.more_vert,
            size: DsIconSize.md,
            color: tokens.colorSecondaryText,
            semanticLabel: 'Move $title',
          ),
        ),
      ),
      items: items,
    );
  }

  Widget _defaultCardBody(DsTokens tokens, DsGridRow row) {
    final primaryKey = _primaryColumn().key;
    final fields = <Widget>[];
    for (final column in widget.columns) {
      if (fields.length >= widget.maxCardFields) break;
      if (column.key == primaryKey || column.key == widget.groupByKey) continue;
      final field = _fieldWidget(tokens, column, row.cells[column.key]);
      if (field != null) fields.add(field);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: DsSpacing.xxl),
          child: Text(
            _primaryText(row),
            style: tokens.bodyMd
                .toTextStyle(color: tokens.colorText)
                .copyWith(fontWeight: DsTypography.semiBold),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        for (final field in fields)
          Padding(
            padding: const EdgeInsets.only(top: DsSpacing.sm),
            child: field,
          ),
      ],
    );
  }

  String _primaryText(DsGridRow row) {
    final column = _primaryColumn();
    final value = row.cells[column.key];
    final text = switch (value) {
      final String s => s,
      final num n => _formatNumber(n),
      final DateTime d => _formatDate(d),
      null => '',
      _ => value.toString(),
    };
    return text.isEmpty ? '—' : text;
  }

  // --- Field renderers ------------------------------------------------------

  /// Builds the compact widget shown for a secondary card field, or null when
  /// the value is missing so the field is simply omitted.
  Widget? _fieldWidget(DsTokens tokens, DsGridColumn column, Object? value) {
    Widget label(String text, {Color? color}) => Text(
          text,
          style: tokens.bodySm
              .toTextStyle(color: color ?? tokens.colorSecondaryText),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );

    switch (column.type) {
      case DsCellType.text:
      case DsCellType.link:
        final s = value is String ? value : null;
        return (s == null || s.isEmpty) ? null : label(s, color: tokens.colorText);
      case DsCellType.number:
        final n = value is num ? value : null;
        return n == null ? null : label(_formatNumber(n), color: tokens.colorText);
      case DsCellType.currency:
        final n = value is num ? value : null;
        if (n == null) return null;
        final symbol = column.currencySymbol ?? r'$';
        return label('$symbol${_formatNumber(n, decimals: 2)}',
            color: tokens.colorText);
      case DsCellType.date:
        final d = value is DateTime ? value : null;
        return d == null ? null : label(_formatDate(d));
      case DsCellType.singleSelect:
      case DsCellType.status:
        final s = value is String ? value : null;
        if (s == null || s.isEmpty) return null;
        return Align(
          alignment: Alignment.centerLeft,
          child: _selectBadge(tokens, column, s),
        );
      case DsCellType.multiSelect:
        final list = value is List ? value : null;
        if (list == null || list.isEmpty) return null;
        return Wrap(
          spacing: DsSpacing.xs,
          runSpacing: DsSpacing.xs,
          children: [
            for (final item in list.take(4))
              _selectBadge(tokens, column, item?.toString() ?? ''),
          ],
        );
      case DsCellType.user:
        final s = value is String ? value : null;
        if (s == null || s.isEmpty) return null;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DsAvatar(name: s, size: 20),
            const SizedBox(width: DsSpacing.sm),
            Flexible(child: label(s, color: tokens.colorText)),
          ],
        );
      case DsCellType.checkbox:
        final b = value is bool ? value : null;
        if (b == null) return null;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DsIcon(
              icon: b ? Icons.check_box_outlined : Icons.check_box_outline_blank,
              size: DsIconSize.sm,
              color: b ? tokens.formAccentColor : tokens.colorSecondaryText,
            ),
            const SizedBox(width: DsSpacing.xs),
            Flexible(child: label(column.title)),
          ],
        );
      case DsCellType.rating:
        final n = value is num ? value : null;
        return n == null ? null : _ratingRow(tokens, n);
      case DsCellType.progress:
        final n = value is num ? value : null;
        return n == null ? null : _progressBar(tokens, n);
    }
  }

  Widget _selectBadge(DsTokens tokens, DsGridColumn column, String value) {
    final option = _optionFor(column, value);
    final labelText = option?.effectiveLabel ?? value;
    final color = option?.color;
    if (color != null) return _colorPill(tokens, labelText, color);
    final variant = option?.variant ??
        (column.type == DsCellType.status
            ? _statusVariant(value)
            : DsBadgeVariant.neutral);
    return DsBadge(label: labelText, variant: variant);
  }

  DsGridOption? _optionFor(DsGridColumn column, String value) {
    final options = column.options;
    if (options == null) return null;
    for (final option in options) {
      if (option.value == value) return option;
    }
    return null;
  }

  Widget _ratingRow(DsTokens tokens, num value) {
    final filled = value.clamp(0, 5).round();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++)
          Padding(
            padding: const EdgeInsets.only(right: 1),
            child: DsIcon(
              icon: i < filled ? Icons.star : Icons.star_border,
              size: DsIconSize.sm,
              color: i < filled ? tokens.colorPrimary : tokens.colorBorder,
            ),
          ),
      ],
    );
  }

  Widget _progressBar(DsTokens tokens, num value) {
    final fraction = value.toDouble().clamp(0.0, 1.0);
    final percent = (fraction * 100).round();
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 6,
              child: Stack(
                children: [
                  Positioned.fill(child: ColoredBox(color: tokens.colorBorder)),
                  FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: fraction,
                    child: ColoredBox(color: tokens.buttonPrimaryColorBackground),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: DsSpacing.sm),
        Text(
          '$percent%',
          style: tokens.labelSm.toTextStyle(color: tokens.colorSecondaryText),
        ),
      ],
    );
  }

  /// A tinted pill for a select value carrying an explicit swatch [color],
  /// mirroring the data grid's colour badge.
  Widget _colorPill(DsTokens tokens, String labelText, Color color) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(tokens.badgeBorderRadius),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.badgePaddingX,
          vertical: tokens.badgePaddingY,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: tokens.badgePaddingX),
            Flexible(
              child: Text(
                labelText,
                style: TextStyle(
                  color: tokens.colorText,
                  fontSize: tokens.badgeLabelFontSize,
                  fontWeight: tokens.badgeLabelFontWeight,
                  height: 1.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single resolved lane: its identity, the group value it reports on a move,
/// its header styling and the rows it holds.
@immutable
class _BoardLane {
  const _BoardLane({
    required this.index,
    required this.key,
    required this.groupValue,
    required this.label,
    required this.variant,
    required this.color,
    required this.isUngrouped,
    required this.rows,
  });

  final int index;
  final String key;

  /// The destination reported when a card is moved into this lane: an option's
  /// value, or `null` for the ungrouped lane.
  final String? groupValue;
  final String label;
  final DsBadgeVariant? variant;
  final Color? color;
  final bool isUngrouped;
  final List<DsGridRow> rows;
}

// --- Formatting helpers -----------------------------------------------------

/// Formats [value] with thousands separators and, when [decimals] is given, a
/// fixed number of fractional digits. Implemented without `intl`.
String _formatNumber(num value, {int? decimals}) {
  final negative = value < 0;
  final absolute = value.abs();

  String integerPart;
  String fractionPart;
  if (decimals != null) {
    final fixed = absolute.toStringAsFixed(decimals);
    final dot = fixed.indexOf('.');
    integerPart = dot == -1 ? fixed : fixed.substring(0, dot);
    fractionPart = dot == -1 ? '' : fixed.substring(dot);
  } else if (absolute == absolute.roundToDouble()) {
    integerPart = absolute.toStringAsFixed(0);
    fractionPart = '';
  } else {
    final string = absolute.toString();
    final dot = string.indexOf('.');
    integerPart = dot == -1 ? string : string.substring(0, dot);
    fractionPart = dot == -1 ? '' : string.substring(dot);
  }

  final buffer = StringBuffer();
  final length = integerPart.length;
  for (var i = 0; i < length; i++) {
    if (i > 0 && (length - i) % 3 == 0) buffer.write(',');
    buffer.write(integerPart[i]);
  }
  return '${negative ? '-' : ''}$buffer$fractionPart';
}

String _formatDate(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

/// Maps a common status label to a badge variant. Unknown labels are neutral.
DsBadgeVariant _statusVariant(String value) {
  final normalized = value.trim().toLowerCase();
  const success = {
    'active', 'success', 'succeeded', 'paid', 'complete', 'completed',
    'approved', 'done', 'live', 'enabled', 'on', 'available', 'shipped',
  };
  const warning = {
    'pending', 'warning', 'in progress', 'processing', 'review', 'in review',
    'waiting', 'draft', 'scheduled', 'paused', 'todo', 'to do', 'backlog',
  };
  const danger = {
    'failed', 'error', 'danger', 'declined', 'rejected', 'overdue',
    'cancelled', 'canceled', 'disabled', 'off', 'inactive', 'blocked',
    'expired',
  };
  if (success.contains(normalized)) return DsBadgeVariant.success;
  if (warning.contains(normalized)) return DsBadgeVariant.warning;
  if (danger.contains(normalized)) return DsBadgeVariant.danger;
  return DsBadgeVariant.neutral;
}
