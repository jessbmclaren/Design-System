import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';
import '../../tokens/ds_spacing.dart';
import '../atoms/ds_button.dart';
import '../atoms/ds_icon.dart';
import '../molecules/ds_select.dart';
import 'ds_data_grid.dart';

/// An Airtable-class multi-sort builder for a [DsDataGrid]'s [columns].
///
/// The builder edits an ordered list of [DsGridSort]s where the list order is
/// the sort precedence: the first entry is the primary sort, the second breaks
/// ties, and so on. Each row is a `[field] [ascending/descending toggle]
/// [move up] [move down] [remove]` control set, with an "Add sort" action
/// beneath. Reordering with the move buttons rewrites precedence.
///
/// The widget is fully controlled: every edit reports a brand-new
/// `List<DsGridSort>` through [onChanged]. Only [DsGridColumn.sortable] columns
/// are offered, and each column can appear at most once. All colours, spacing,
/// radii and typography come from [DsTokens], so it re-brands with the active
/// theme.
///
/// ## Responsiveness & accessibility
///
/// Below [compactBreakpoint] each sort stacks its field above its controls so it
/// never overflows a 320dp phone; at or above it they lay out on one row. Every
/// control is a labelled, focusable target and the widget runs no timers or
/// animations, so it renders a stable frame for tests and screenshots.
class DsSortBuilder extends StatelessWidget {
  /// Creates a multi-sort builder.
  const DsSortBuilder({
    super.key,
    required this.columns,
    required this.value,
    required this.onChanged,
    this.compactBreakpoint = 600,
  });

  /// The columns a sort may target. Only [DsGridColumn.sortable] columns are
  /// offered in the field picker.
  final List<DsGridColumn> columns;

  /// The current ordered list of sorts. The widget is controlled: it renders
  /// this value and reports edits through [onChanged]. List order is precedence.
  final List<DsGridSort> value;

  /// Called with a new ordered `List<DsGridSort>` whenever the user edits,
  /// reorders, adds or removes a sort.
  final ValueChanged<List<DsGridSort>> onChanged;

  /// The width, in logical pixels, below which each sort stacks its controls
  /// vertically instead of laying them out on one row.
  final double compactBreakpoint;

  List<DsGridColumn> get _sortableColumns =>
      columns.where((c) => c.sortable).toList(growable: false);

  DsGridColumn? _columnFor(String key) {
    for (final column in columns) {
      if (column.key == key) return column;
    }
    return null;
  }

  /// The first sortable column not already used by a sort, or the first sortable
  /// column when they are all used (so "Add sort" always works).
  DsGridColumn? _nextUnusedColumn() {
    final used = value.map((sort) => sort.columnKey).toSet();
    final sortable = _sortableColumns;
    for (final column in sortable) {
      if (!used.contains(column.key)) return column;
    }
    return sortable.isNotEmpty ? sortable.first : null;
  }

  void _add() {
    final column = _nextUnusedColumn();
    if (column == null) return;
    onChanged([...value, DsGridSort(columnKey: column.key)]);
  }

  void _removeAt(int index) {
    final next = List<DsGridSort>.of(value)..removeAt(index);
    onChanged(next);
  }

  void _setColumn(int index, String key) {
    final next = List<DsGridSort>.of(value);
    next[index] = DsGridSort(columnKey: key, ascending: value[index].ascending);
    onChanged(next);
  }

  void _setAscending(int index, bool ascending) {
    final next = List<DsGridSort>.of(value);
    next[index] =
        DsGridSort(columnKey: value[index].columnKey, ascending: ascending);
    onChanged(next);
  }

  void _move(int index, int delta) {
    final target = index + delta;
    if (target < 0 || target >= value.length) return;
    final next = List<DsGridSort>.of(value);
    final moved = next.removeAt(index);
    next.insert(target, moved);
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final compact = maxWidth < compactBreakpoint;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.formBackgroundColor,
            border: Border.all(color: tokens.colorBorder),
            borderRadius: BorderRadius.circular(tokens.formBorderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(DsSpacing.md),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (value.isEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'No sorts',
                      style: tokens.bodyMd
                          .toTextStyle(color: tokens.colorSecondaryText),
                    ),
                  )
                else
                  for (var i = 0; i < value.length; i++) ...[
                    if (i > 0) const SizedBox(height: DsSpacing.sm),
                    _buildSortRow(tokens, i, value[i], compact),
                  ],
                const SizedBox(height: DsSpacing.md),
                Align(
                  alignment: Alignment.centerLeft,
                  child: DsButton(
                    label: 'Add sort',
                    variant: DsButtonVariant.secondary,
                    icon: Icons.add,
                    onPressed: _add,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortRow(
    DsTokens tokens,
    int index,
    DsGridSort sort,
    bool compact,
  ) {
    final column = _columnFor(sort.columnKey);
    // Columns already used by OTHER sort rows are excluded so a column can be
    // sorted on at most once (the row's own column stays selectable).
    final usedByOthers = <String>{
      for (var i = 0; i < value.length; i++)
        if (i != index) value[i].columnKey,
    };
    final field = DsSelect<String>(
      value: column != null && column.sortable ? sort.columnKey : null,
      hintText: 'Field',
      options: [
        for (final option in _sortableColumns)
          if (option.key == sort.columnKey ||
              !usedByOthers.contains(option.key))
            DsSelectOption<String>(value: option.key, label: option.title),
      ],
      onChanged: (key) {
        if (key != null) _setColumn(index, key);
      },
    );

    final direction = _DirectionToggle(
      ascending: sort.ascending,
      onChanged: (ascending) => _setAscending(index, ascending),
    );

    final controls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _IconAction(
          icon: Icons.keyboard_arrow_up,
          tooltip: 'Move sort earlier',
          onTap: index == 0 ? null : () => _move(index, -1),
        ),
        _IconAction(
          icon: Icons.keyboard_arrow_down,
          tooltip: 'Move sort later',
          onTap: index == value.length - 1 ? null : () => _move(index, 1),
        ),
        _IconAction(
          icon: Icons.close,
          tooltip: 'Remove sort',
          onTap: () => _removeAt(index),
        ),
      ],
    );

    if (compact) {
      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: tokens.colorBorder),
          borderRadius: BorderRadius.circular(tokens.formBorderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DsSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              field,
              const SizedBox(height: DsSpacing.sm),
              Wrap(
                spacing: DsSpacing.sm,
                runSpacing: DsSpacing.sm,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [direction, controls],
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 5, child: field),
        const SizedBox(width: DsSpacing.sm),
        direction,
        const SizedBox(width: DsSpacing.sm),
        controls,
      ],
    );
  }
}

/// A compact two-segment ascending/descending control for a single sort.
class _DirectionToggle extends StatelessWidget {
  const _DirectionToggle({required this.ascending, required this.onChanged});

  final bool ascending;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final radius = BorderRadius.circular(tokens.formBorderRadius);
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: tokens.colorBorder),
        borderRadius: radius,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _segment(
              tokens,
              label: 'Asc',
              icon: Icons.arrow_upward,
              semanticsLabel: 'Sort ascending',
              selected: ascending,
              onTap: () => onChanged(true),
            ),
            _segment(
              tokens,
              label: 'Desc',
              icon: Icons.arrow_downward,
              semanticsLabel: 'Sort descending',
              selected: !ascending,
              onTap: () => onChanged(false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _segment(
    DsTokens tokens, {
    required String label,
    required IconData icon,
    required String semanticsLabel,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final foreground = selected ? Colors.white : tokens.colorSecondaryText;
    return Semantics(
      button: true,
      selected: selected,
      label: semanticsLabel,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          child: Container(
            color: selected ? tokens.formAccentColor : null,
            constraints: const BoxConstraints(minHeight: 40),
            padding: const EdgeInsets.symmetric(horizontal: DsSpacing.sm),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DsIcon(icon: icon, size: DsIconSize.xs, color: foreground),
                const SizedBox(width: DsSpacing.xs),
                Text(
                  label,
                  style: tokens.labelMd.toTextStyle(color: foreground),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A small icon-only affordance (reorder / remove) with a >=48dp target, a
/// tooltip and a semantics button label. A null [onTap] disables it.
class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final enabled = onTap != null;
    final color =
        enabled ? tokens.colorSecondaryText : tokens.colorBorder;
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: tooltip,
        child: Material(
          type: MaterialType.transparency,
          child: InkResponse(
            onTap: onTap,
            radius: 24,
            child: SizedBox(
              width: 40,
              height: 48,
              child: Center(
                child: DsIcon(icon: icon, size: DsIconSize.md, color: color),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
