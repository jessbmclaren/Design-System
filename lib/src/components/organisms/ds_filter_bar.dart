import 'package:flutter/material.dart';
import '../../tokens/ds_icons.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';
import '../atoms/ds_button.dart';
import '../atoms/ds_chip.dart';
import '../atoms/ds_icon.dart';
import '../atoms/ds_segmented_control.dart';
import '../atoms/ds_switch.dart';
import '../molecules/ds_date_field.dart';
import '../molecules/ds_select.dart';
import '../molecules/ds_text_field.dart';
import 'ds_data_grid.dart';

/// How the individual conditions of a [DsFilter] are combined.
///
/// * [and]: a row must satisfy *every* condition (intersection).
/// * [or]: a row must satisfy *at least one* condition (union).
enum DsFilterConjunction {
  /// All conditions must match.
  and,

  /// Any condition may match.
  or,
}

/// A comparison offered by a filter condition.
///
/// Not every operator is valid for every [DsCellType]; call
/// [dsOperatorsForType] to obtain the operators that apply to a column, and read
/// [DsFilterOperatorLabel.label] for a human-readable name.
enum DsFilterOperator {
  /// Equal to the value (`is`).
  is_,

  /// Not equal to the value (`is not`).
  isNot,

  /// Text/user/link contains the substring, or a multi-select includes the
  /// option.
  contains,

  /// The negation of [contains].
  doesNotContain,

  /// The cell has no value (null, empty text or empty list).
  isEmpty,

  /// The cell has a value.
  isNotEmpty,

  /// The single-select value is one of a set of options.
  isAnyOf,

  /// The single-select value is none of a set of options.
  isNoneOf,

  /// The number is strictly greater than the value.
  greaterThan,

  /// The number is strictly less than the value.
  lessThan,

  /// The date is the value's day or earlier.
  onOrBefore,

  /// The date is the value's day or later.
  onOrAfter,

  /// The date is strictly before the value's day.
  before,

  /// The date is strictly after the value's day.
  after,
}

/// A human-readable label for each [DsFilterOperator], used in the operator
/// picker and when describing a condition.
extension DsFilterOperatorLabel on DsFilterOperator {
  /// The label shown for this operator.
  String get label => switch (this) {
        DsFilterOperator.is_ => 'is',
        DsFilterOperator.isNot => 'is not',
        DsFilterOperator.contains => 'contains',
        DsFilterOperator.doesNotContain => 'does not contain',
        DsFilterOperator.isEmpty => 'is empty',
        DsFilterOperator.isNotEmpty => 'is not empty',
        DsFilterOperator.isAnyOf => 'is any of',
        DsFilterOperator.isNoneOf => 'is none of',
        DsFilterOperator.greaterThan => '>',
        DsFilterOperator.lessThan => '<',
        DsFilterOperator.onOrBefore => 'is on or before',
        DsFilterOperator.onOrAfter => 'is on or after',
        DsFilterOperator.before => 'is before',
        DsFilterOperator.after => 'is after',
      };
}

/// The operators that are valid for a column of the given [type].
///
/// The returned list is the exact menu offered by [DsFilterBar] for that
/// column, in display order, and its first entry is a sensible default operator.
List<DsFilterOperator> dsOperatorsForType(DsCellType type) {
  switch (type) {
    case DsCellType.text:
      return const [
        DsFilterOperator.is_,
        DsFilterOperator.isNot,
        DsFilterOperator.contains,
        DsFilterOperator.doesNotContain,
        DsFilterOperator.isEmpty,
        DsFilterOperator.isNotEmpty,
      ];
    case DsCellType.number:
    case DsCellType.currency:
    case DsCellType.rating:
    case DsCellType.progress:
      return const [
        DsFilterOperator.is_,
        DsFilterOperator.isNot,
        DsFilterOperator.greaterThan,
        DsFilterOperator.lessThan,
        DsFilterOperator.isEmpty,
        DsFilterOperator.isNotEmpty,
      ];
    case DsCellType.date:
      return const [
        DsFilterOperator.is_,
        DsFilterOperator.before,
        DsFilterOperator.after,
        DsFilterOperator.onOrBefore,
        DsFilterOperator.onOrAfter,
        DsFilterOperator.isEmpty,
        DsFilterOperator.isNotEmpty,
      ];
    case DsCellType.singleSelect:
    case DsCellType.status:
      return const [
        DsFilterOperator.is_,
        DsFilterOperator.isNot,
        DsFilterOperator.isAnyOf,
        DsFilterOperator.isNoneOf,
        DsFilterOperator.isEmpty,
        DsFilterOperator.isNotEmpty,
      ];
    case DsCellType.multiSelect:
      return const [
        DsFilterOperator.contains,
        DsFilterOperator.doesNotContain,
        DsFilterOperator.isEmpty,
        DsFilterOperator.isNotEmpty,
      ];
    case DsCellType.checkbox:
      return const [DsFilterOperator.is_];
    case DsCellType.user:
    case DsCellType.link:
      return const [
        DsFilterOperator.is_,
        DsFilterOperator.isNot,
        DsFilterOperator.contains,
        DsFilterOperator.isEmpty,
        DsFilterOperator.isNotEmpty,
      ];
  }
}

/// A single row of a [DsFilter]: compare the column [columnKey] against [value]
/// with [operator].
///
/// [value] is interpreted per the column's [DsCellType] and the chosen
/// [operator]: a `String` for text and single-select, a `num` for numeric
/// comparisons, a `DateTime` for dates, a `bool` for checkboxes and a
/// `List<String>` for [DsFilterOperator.isAnyOf] / [DsFilterOperator.isNoneOf].
/// A `null` value (or an empty one) marks the condition incomplete, and
/// [DsFilter.matches] ignores it.
@immutable
class DsFilterCondition {
  /// Creates a filter condition.
  const DsFilterCondition({
    required this.columnKey,
    required this.operator,
    this.value,
  });

  /// The [DsGridColumn.key] this condition tests.
  final String columnKey;

  /// The comparison applied to the column's value.
  final DsFilterOperator operator;

  /// The right-hand side of the comparison, interpreted per the column type and
  /// [operator]. Valueless operators ([DsFilterOperator.isEmpty] /
  /// [DsFilterOperator.isNotEmpty]) ignore it.
  final Object? value;

  /// Returns a copy with the given fields replaced. Passing [value] cannot clear
  /// it to null; construct a new [DsFilterCondition] directly for that.
  DsFilterCondition copyWith({
    String? columnKey,
    DsFilterOperator? operator,
    Object? value,
  }) {
    return DsFilterCondition(
      columnKey: columnKey ?? this.columnKey,
      operator: operator ?? this.operator,
      value: value ?? this.value,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DsFilterCondition &&
          runtimeType == other.runtimeType &&
          columnKey == other.columnKey &&
          operator == other.operator &&
          _dsValueEquals(value, other.value);

  @override
  int get hashCode => Object.hash(
        columnKey,
        operator,
        value is List ? Object.hashAll(value as List) : value,
      );
}

/// An immutable filter: an ordered list of [conditions] combined by
/// [conjunction].
///
/// [matches] is the source of truth for whether a [DsGridRow] passes the filter;
/// it is type-aware (numbers compare numerically, dates by day, selects by value
/// equality, text case-insensitively) and can be reused outside the widget to
/// drive server-side or policy filtering.
@immutable
class DsFilter {
  /// Creates a filter. An empty filter matches every row.
  const DsFilter({
    this.conjunction = DsFilterConjunction.and,
    this.conditions = const [],
  });

  /// How [conditions] are combined.
  final DsFilterConjunction conjunction;

  /// The conditions, in display order.
  final List<DsFilterCondition> conditions;

  /// Whether the filter carries no conditions (and therefore matches all rows).
  bool get isEmpty => conditions.isEmpty;

  /// Returns a copy with the given fields replaced.
  DsFilter copyWith({
    DsFilterConjunction? conjunction,
    List<DsFilterCondition>? conditions,
  }) {
    return DsFilter(
      conjunction: conjunction ?? this.conjunction,
      conditions: conditions ?? this.conditions,
    );
  }

  /// Whether [row] satisfies this filter, evaluating each condition against the
  /// matching column in [columns] for type-aware comparisons.
  ///
  /// Incomplete conditions (an unknown column, or a value-requiring operator
  /// with no value) are ignored, so a half-built condition never hides rows.
  /// When no applicable conditions remain the filter matches everything.
  bool matches(DsGridRow row, List<DsGridColumn> columns) {
    if (conditions.isEmpty) return true;

    final byKey = <String, DsGridColumn>{
      for (final column in columns) column.key: column,
    };

    bool applicable(DsFilterCondition condition) {
      final column = byKey[condition.columnKey];
      if (column == null) return false;
      return _dsRequiresValue(column.type, condition.operator)
          ? !_dsIsEmptyValue(condition.value)
          : true;
    }

    final active = conditions.where(applicable).toList(growable: false);
    if (active.isEmpty) return true;

    bool evaluate(DsFilterCondition condition) {
      final column = byKey[condition.columnKey]!;
      return _dsEvaluate(
        column.type,
        row.cells[condition.columnKey],
        condition.operator,
        condition.value,
      );
    }

    return conjunction == DsFilterConjunction.and
        ? active.every(evaluate)
        : active.any(evaluate);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DsFilter &&
          runtimeType == other.runtimeType &&
          conjunction == other.conjunction &&
          _dsListEquals(conditions, other.conditions);

  @override
  int get hashCode => Object.hash(conjunction, Object.hashAll(conditions));
}

// --- Evaluation -------------------------------------------------------------

/// Whether [operator] needs a right-hand [DsFilterCondition.value] to be
/// meaningful for a column of [type]. Valueless operators (empty / not empty)
/// and the boolean checkbox comparison do not.
bool _dsRequiresValue(DsCellType type, DsFilterOperator operator) {
  if (operator == DsFilterOperator.isEmpty ||
      operator == DsFilterOperator.isNotEmpty) {
    return false;
  }
  // A checkbox "is" reads its truth from the toggle itself; a null value is
  // treated as `false` rather than as an incomplete condition.
  if (type == DsCellType.checkbox) return false;
  return true;
}

/// Whether [value] counts as empty: null, blank text or an empty list.
bool _dsIsEmptyValue(Object? value) {
  if (value == null) return true;
  if (value is String) return value.trim().isEmpty;
  if (value is List) return value.isEmpty;
  return false;
}

/// Evaluates a single condition against a cell value.
bool _dsEvaluate(
  DsCellType type,
  Object? cell,
  DsFilterOperator operator,
  Object? value,
) {
  switch (operator) {
    case DsFilterOperator.isEmpty:
      return _dsCellIsEmpty(cell);
    case DsFilterOperator.isNotEmpty:
      return !_dsCellIsEmpty(cell);
    case DsFilterOperator.is_:
      return _dsEquals(type, cell, value);
    case DsFilterOperator.isNot:
      return !_dsEquals(type, cell, value);
    case DsFilterOperator.contains:
      return _dsContains(type, cell, value);
    case DsFilterOperator.doesNotContain:
      return !_dsContains(type, cell, value);
    case DsFilterOperator.isAnyOf:
      return _dsIsAnyOf(cell, value);
    case DsFilterOperator.isNoneOf:
      return !_dsIsAnyOf(cell, value);
    case DsFilterOperator.greaterThan:
      return _dsNumCompare(cell, value, (int c) => c > 0);
    case DsFilterOperator.lessThan:
      return _dsNumCompare(cell, value, (int c) => c < 0);
    case DsFilterOperator.before:
      return _dsDateCompare(cell, value, (int c) => c < 0);
    case DsFilterOperator.after:
      return _dsDateCompare(cell, value, (int c) => c > 0);
    case DsFilterOperator.onOrBefore:
      return _dsDateCompare(cell, value, (int c) => c <= 0);
    case DsFilterOperator.onOrAfter:
      return _dsDateCompare(cell, value, (int c) => c >= 0);
  }
}

/// Whether the cell value itself is empty, honouring the cell type.
bool _dsCellIsEmpty(Object? cell) {
  if (cell == null) return true;
  if (cell is String) return cell.trim().isEmpty;
  if (cell is List) return cell.isEmpty;
  return false;
}

bool _dsEquals(DsCellType type, Object? cell, Object? value) {
  switch (type) {
    case DsCellType.number:
    case DsCellType.currency:
    case DsCellType.rating:
    case DsCellType.progress:
      final a = _dsAsNum(cell);
      final b = _dsAsNum(value);
      return a != null && b != null && a == b;
    case DsCellType.date:
      final a = _dsAsDate(cell);
      final b = _dsAsDate(value);
      return a != null && b != null && _dsSameDay(a, b);
    case DsCellType.checkbox:
      return (_dsAsBool(cell) ?? false) == (_dsAsBool(value) ?? false);
    case DsCellType.text:
    case DsCellType.singleSelect:
    case DsCellType.status:
    case DsCellType.multiSelect:
    case DsCellType.user:
    case DsCellType.link:
      final a = _dsAsString(cell);
      final b = _dsAsString(value);
      return a != null && b != null && a.toLowerCase() == b.toLowerCase();
  }
}

bool _dsContains(DsCellType type, Object? cell, Object? value) {
  if (type == DsCellType.multiSelect) {
    final list = _dsAsStringList(cell);
    final needle = _dsAsString(value);
    if (list == null || needle == null) return false;
    final target = needle.toLowerCase();
    return list.any((item) => item.toLowerCase() == target);
  }
  final haystack = _dsAsString(cell);
  final needle = _dsAsString(value);
  if (haystack == null || needle == null) return false;
  return haystack.toLowerCase().contains(needle.toLowerCase());
}

bool _dsIsAnyOf(Object? cell, Object? value) {
  final target = _dsAsString(cell);
  final options = _dsAsStringList(value);
  if (target == null || options == null) return false;
  final lower = target.toLowerCase();
  return options.any((option) => option.toLowerCase() == lower);
}

bool _dsNumCompare(Object? cell, Object? value, bool Function(int) test) {
  final a = _dsAsNum(cell);
  final b = _dsAsNum(value);
  if (a == null || b == null) return false;
  return test(a.compareTo(b));
}

bool _dsDateCompare(Object? cell, Object? value, bool Function(int) test) {
  final a = _dsAsDate(cell);
  final b = _dsAsDate(value);
  if (a == null || b == null) return false;
  final ad = DateTime(a.year, a.month, a.day);
  final bd = DateTime(b.year, b.month, b.day);
  return test(ad.compareTo(bd));
}

bool _dsSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String? _dsAsString(Object? value) => value is String ? value : null;

num? _dsAsNum(Object? value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value.trim());
  return null;
}

bool? _dsAsBool(Object? value) => value is bool ? value : null;

DateTime? _dsAsDate(Object? value) => value is DateTime ? value : null;

List<String>? _dsAsStringList(Object? value) => value is List
    ? value.map((e) => e?.toString() ?? '').toList(growable: false)
    : null;

bool _dsValueEquals(Object? a, Object? b) {
  if (a is List && b is List) return _dsListEquals(a, b);
  return a == b;
}

bool _dsListEquals(List<Object?> a, List<Object?> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// The shape of value input a condition needs, derived from its column type and
/// operator. Drives which control [DsFilterBar] renders for the value.
enum _ValueKind {
  none,
  text,
  number,
  date,
  selectSingle,
  selectMulti,
  optionMembership,
  boolean,
}

_ValueKind _valueKindFor(DsCellType type, DsFilterOperator operator) {
  switch (operator) {
    case DsFilterOperator.isEmpty:
    case DsFilterOperator.isNotEmpty:
      return _ValueKind.none;
    case DsFilterOperator.isAnyOf:
    case DsFilterOperator.isNoneOf:
      return _ValueKind.selectMulti;
    case DsFilterOperator.greaterThan:
    case DsFilterOperator.lessThan:
      return _ValueKind.number;
    case DsFilterOperator.before:
    case DsFilterOperator.after:
    case DsFilterOperator.onOrBefore:
    case DsFilterOperator.onOrAfter:
      return _ValueKind.date;
    case DsFilterOperator.is_:
    case DsFilterOperator.isNot:
    case DsFilterOperator.contains:
    case DsFilterOperator.doesNotContain:
      break;
  }
  switch (type) {
    case DsCellType.number:
    case DsCellType.currency:
    case DsCellType.rating:
    case DsCellType.progress:
      return _ValueKind.number;
    case DsCellType.date:
      return _ValueKind.date;
    case DsCellType.checkbox:
      return _ValueKind.boolean;
    case DsCellType.singleSelect:
    case DsCellType.status:
      return _ValueKind.selectSingle;
    case DsCellType.multiSelect:
      return _ValueKind.optionMembership;
    case DsCellType.text:
    case DsCellType.user:
    case DsCellType.link:
      return _ValueKind.text;
  }
}

Object? _defaultValueForKind(_ValueKind kind) =>
    kind == _ValueKind.boolean ? true : null;

// --- Widget -----------------------------------------------------------------

/// An Airtable-class filter builder for a [DsDataGrid]'s [columns].
///
/// The bar shows a single "Filter" button carrying the active condition count.
/// Opening it reveals an editor of stacked conditions (each a
/// `[field] [operator] [value] [remove]` row) joined by a shared AND/OR
/// conjunction, plus "Add condition" and "Clear all" actions. The value control
/// adapts to the chosen column and operator: a [DsTextField] for text and
/// numbers, a [DsDateField] for dates, a [DsSelect] for single-selects, a set of
/// toggle chips for multi-value selection, a [DsSwitch] for checkboxes and no
/// input for the empty / not-empty operators.
///
/// The widget is fully controlled: every edit reports a brand-new immutable
/// [DsFilter] through [onChanged], and the same [DsFilter.matches] predicate can
/// be used to filter rows. All colours, spacing, radii and typography come from
/// [DsTokens], so it re-brands with the active theme.
///
/// ## Responsiveness & accessibility
///
/// Below [compactBreakpoint] each condition stacks its controls vertically so it
/// never overflows a 320dp phone; at or above it the controls lay out on one
/// row. Every control is a labelled, focusable target and the widget runs no
/// timers or animations, so it renders a stable frame for tests and screenshots.
class DsFilterBar extends StatefulWidget {
  /// Creates a filter bar.
  const DsFilterBar({
    super.key,
    required this.columns,
    required this.value,
    required this.onChanged,
    this.initiallyOpen = false,
    this.compactBreakpoint = 600,
  });

  /// The columns a condition may target. Their [DsGridColumn.type] selects the
  /// available operators and the value control.
  final List<DsGridColumn> columns;

  /// The current filter. The widget is controlled: it renders this value and
  /// reports edits through [onChanged].
  final DsFilter value;

  /// Called with a new immutable [DsFilter] whenever the user edits a condition,
  /// the conjunction, or the condition set.
  final ValueChanged<DsFilter> onChanged;

  /// Whether the condition editor starts expanded. Defaults to false.
  final bool initiallyOpen;

  /// The width, in logical pixels, below which each condition stacks its
  /// controls vertically instead of laying them out on one row.
  final double compactBreakpoint;

  @override
  State<DsFilterBar> createState() => _DsFilterBarState();
}

class _DsFilterBarState extends State<DsFilterBar> {
  static const double _prefixWidth = 116;

  late bool _open = widget.initiallyOpen;

  DsFilter get _filter => widget.value;

  DsGridColumn? _columnFor(String key) {
    for (final column in widget.columns) {
      if (column.key == key) return column;
    }
    return null;
  }

  void _emit(DsFilter next) => widget.onChanged(next);

  void _setCondition(int index, DsFilterCondition condition) {
    final next = List<DsFilterCondition>.of(_filter.conditions);
    next[index] = condition;
    _emit(_filter.copyWith(conditions: next));
  }

  void _addCondition() {
    if (widget.columns.isEmpty) return;
    final column = widget.columns.first;
    final operator = dsOperatorsForType(column.type).first;
    final value = _defaultValueForKind(_valueKindFor(column.type, operator));
    final next = List<DsFilterCondition>.of(_filter.conditions)
      ..add(DsFilterCondition(
        columnKey: column.key,
        operator: operator,
        value: value,
      ));
    setState(() => _open = true);
    _emit(_filter.copyWith(conditions: next));
  }

  void _removeCondition(int index) {
    final next = List<DsFilterCondition>.of(_filter.conditions)
      ..removeAt(index);
    _emit(_filter.copyWith(conditions: next));
  }

  void _clearAll() => _emit(const DsFilter());

  void _setConjunction(DsFilterConjunction conjunction) =>
      _emit(_filter.copyWith(conjunction: conjunction));

  void _changeColumn(int index, String key) {
    final column = _columnFor(key);
    if (column == null) return;
    final current = _filter.conditions[index];
    final operators = dsOperatorsForType(column.type);
    final operator =
        operators.contains(current.operator) ? current.operator : operators.first;
    _setCondition(
      index,
      DsFilterCondition(
        columnKey: key,
        operator: operator,
        // The column type changed, so any previous value no longer applies.
        value: _defaultValueForKind(_valueKindFor(column.type, operator)),
      ),
    );
  }

  void _changeOperator(int index, DsFilterOperator operator) {
    final current = _filter.conditions[index];
    final type = _columnFor(current.columnKey)?.type ?? DsCellType.text;
    final oldKind = _valueKindFor(type, current.operator);
    final newKind = _valueKindFor(type, operator);
    _setCondition(
      index,
      DsFilterCondition(
        columnKey: current.columnKey,
        operator: operator,
        // Keep the value only while the input shape is unchanged.
        value: oldKind == newKind
            ? current.value
            : _defaultValueForKind(newKind),
      ),
    );
  }

  void _changeValue(int index, Object? value) {
    final current = _filter.conditions[index];
    _setCondition(
      index,
      DsFilterCondition(
        columnKey: current.columnKey,
        operator: current.operator,
        value: value,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final count = _filter.conditions.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: DsButton(
            label: count == 0 ? 'Filter' : 'Filter ($count)',
            variant: DsButtonVariant.secondary,
            icon: DsIcons.filter,
            onPressed: () => setState(() => _open = !_open),
          ),
        ),
        if (_open) ...[
          SizedBox(height: tokens.spacingUnit),
          _buildPanel(tokens),
        ],
      ],
    );
  }

  Widget _buildPanel(DsTokens tokens) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final compact = maxWidth < widget.compactBreakpoint;
        final conditions = _filter.conditions;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.formBackgroundColor,
            border: Border.all(color: tokens.colorBorder),
            borderRadius: BorderRadius.circular(tokens.formBorderRadius),
          ),
          child: Padding(
            padding: EdgeInsets.all(tokens.spacingUnit * 1.5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (conditions.isEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'No filters',
                      style: tokens.bodyMd
                          .toTextStyle(color: tokens.colorSecondaryText),
                    ),
                  )
                else
                  for (var i = 0; i < conditions.length; i++) ...[
                    if (i > 0) SizedBox(height: tokens.spacingUnit),
                    _buildConditionRow(tokens, i, conditions[i], compact),
                  ],
                SizedBox(height: tokens.spacingUnit * 1.5),
                _buildFooter(conditions.isNotEmpty),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooter(bool hasConditions) {
    final tokens = DsTokens.of(context);
    return Wrap(
      spacing: tokens.spacingUnit,
      runSpacing: tokens.spacingUnit,
      children: [
        DsButton(
          label: 'Add condition',
          variant: DsButtonVariant.secondary,
          icon: DsIcons.add,
          onPressed: _addCondition,
        ),
        if (hasConditions)
          DsButton(
            label: 'Clear all',
            variant: DsButtonVariant.secondary,
            onPressed: _clearAll,
          ),
      ],
    );
  }

  Widget _buildConditionRow(
    DsTokens tokens,
    int index,
    DsFilterCondition condition,
    bool compact,
  ) {
    final prefix = _prefix(tokens, index);
    final field = _fieldSelect(index, condition);
    final operator = _operatorSelect(index, condition);
    final value = _valueEditor(tokens, index, condition);
    final remove = _IconAction(
      icon: DsIcons.close,
      tooltip: 'Remove filter condition',
      onTap: () => _removeCondition(index),
    );

    if (compact) {
      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: tokens.colorBorder),
          borderRadius: BorderRadius.circular(tokens.formBorderRadius),
        ),
        child: Padding(
          padding: EdgeInsets.all(tokens.spacingUnit),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: prefix),
                  remove,
                ],
              ),
              SizedBox(height: tokens.spacingUnit),
              field,
              SizedBox(height: tokens.spacingUnit),
              operator,
              SizedBox(height: tokens.spacingUnit),
              value,
            ],
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(width: _prefixWidth, child: prefix),
        SizedBox(width: tokens.spacingUnit),
        Expanded(flex: 4, child: field),
        SizedBox(width: tokens.spacingUnit),
        Expanded(flex: 4, child: operator),
        SizedBox(width: tokens.spacingUnit),
        Expanded(flex: 5, child: value),
        SizedBox(width: tokens.spacingUnit / 2),
        remove,
      ],
    );
  }

  /// The leading conjunction affordance: the word "Where" for the first row, an
  /// editable And/Or toggle for the second and the fixed conjunction word for
  /// every row after that (matching a database-style filter builder).
  Widget _prefix(DsTokens tokens, int index) {
    if (index == 0) {
      return Text(
        'Where',
        style: tokens.bodyMd.toTextStyle(color: tokens.colorSecondaryText),
      );
    }
    if (index == 1) {
      return Align(
        alignment: Alignment.centerLeft,
        child: DsSegmentedControl<DsFilterConjunction>(
          value: _filter.conjunction,
          onChanged: _setConjunction,
          segments: const <DsSegment<DsFilterConjunction>>[
            DsSegment(
              value: DsFilterConjunction.and,
              label: 'And',
              semanticLabel: 'Match all conditions',
            ),
            DsSegment(
              value: DsFilterConjunction.or,
              label: 'Or',
              semanticLabel: 'Match any condition',
            ),
          ],
        ),
      );
    }
    return Text(
      _filter.conjunction == DsFilterConjunction.and ? 'And' : 'Or',
      style: tokens.bodyMd.toTextStyle(color: tokens.colorText).copyWith(
            fontWeight: tokens.mediumLabelFontWeight,
          ),
    );
  }

  Widget _fieldSelect(int index, DsFilterCondition condition) {
    // A persisted filter may reference a column no longer present (DsFilter.matches
    // tolerates that); show an empty picker rather than asserting on an
    // unmatched dropdown value.
    final known = _columnFor(condition.columnKey) != null;
    return DsSelect<String>(
      value: known ? condition.columnKey : null,
      hintText: 'Field',
      options: [
        for (final column in widget.columns)
          DsSelectOption<String>(value: column.key, label: column.title),
      ],
      onChanged: (key) {
        if (key != null) _changeColumn(index, key);
      },
    );
  }

  Widget _operatorSelect(int index, DsFilterCondition condition) {
    final column = _columnFor(condition.columnKey);
    final operators = dsOperatorsForType(column?.type ?? DsCellType.text);
    return DsSelect<DsFilterOperator>(
      value: operators.contains(condition.operator) ? condition.operator : null,
      hintText: 'Condition',
      options: [
        for (final operator in operators)
          DsSelectOption<DsFilterOperator>(
            value: operator,
            label: operator.label,
          ),
      ],
      onChanged: (operator) {
        if (operator != null) _changeOperator(index, operator);
      },
    );
  }

  Widget _valueEditor(DsTokens tokens, int index, DsFilterCondition condition) {
    final column = _columnFor(condition.columnKey);
    final type = column?.type ?? DsCellType.text;
    final options = column?.options ?? const <DsGridOption>[];
    final kind = _valueKindFor(type, condition.operator);

    switch (kind) {
      case _ValueKind.none:
        return _mutedValue(tokens, 'No value needed');
      case _ValueKind.text:
        return _ValueTextField(
          key: ValueKey<String>('value-$index-${condition.columnKey}-text'),
          initialText: _dsAsString(condition.value) ?? '',
          hintText: 'Value',
          keyboardType: TextInputType.text,
          onChanged: (text) =>
              _changeValue(index, text.isEmpty ? null : text),
        );
      case _ValueKind.number:
        return _ValueTextField(
          key: ValueKey<String>('value-$index-${condition.columnKey}-number'),
          initialText: condition.value == null ? '' : '${condition.value}',
          hintText: 'Value',
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true, signed: true),
          onChanged: (text) {
            final trimmed = text.trim();
            _changeValue(index, trimmed.isEmpty ? null : num.tryParse(trimmed));
          },
        );
      case _ValueKind.date:
        return DsDateField(
          value: _dsAsDate(condition.value),
          hintText: 'Select a date',
          onChanged: (date) => _changeValue(index, date),
        );
      case _ValueKind.selectSingle:
      case _ValueKind.optionMembership:
        if (options.isEmpty) return _mutedValue(tokens, 'No options');
        // Only pass a value the option set actually contains, so a stale value
        // can't trip the dropdown's single-match assert.
        final current = _dsAsString(condition.value);
        final known = options.any((o) => o.value == current);
        return DsSelect<String>(
          value: known ? current : null,
          hintText: 'Select',
          options: [
            for (final option in options)
              DsSelectOption<String>(
                value: option.value,
                label: option.effectiveLabel,
              ),
          ],
          onChanged: (value) => _changeValue(index, value),
        );
      case _ValueKind.selectMulti:
        if (options.isEmpty) return _mutedValue(tokens, 'No options');
        return _OptionChips(
          options: options,
          selected: _dsAsStringList(condition.value) ?? const [],
          onChanged: (values) =>
              _changeValue(index, values.isEmpty ? null : values),
        );
      case _ValueKind.boolean:
        final on = _dsAsBool(condition.value) ?? false;
        return Align(
          alignment: Alignment.centerLeft,
          child: DsSwitch(
            value: on,
            label: on ? 'True' : 'False',
            onChanged: (next) => _changeValue(index, next),
          ),
        );
    }
  }

  Widget _mutedValue(DsTokens tokens, String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.spacingUnit * 1.5),
        child: Text(
          text,
          style: tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText),
        ),
      ),
    );
  }
}

/// The wrap of toggle chips used for the multi-value select operators
/// ([DsFilterOperator.isAnyOf] / [DsFilterOperator.isNoneOf]).
class _OptionChips extends StatelessWidget {
  const _OptionChips({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<DsGridOption> options;
  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return Wrap(
      spacing: tokens.spacingUnit / 2,
      runSpacing: tokens.spacingUnit / 2,
      children: [
        for (final option in options)
          _chip(tokens, option, selected.contains(option.value)),
      ],
    );
  }

  Widget _chip(DsTokens tokens, DsGridOption option, bool isSelected) {
    return DsChip(
      label: option.effectiveLabel,
      backgroundColor: isSelected ? tokens.offsetBackgroundColor : null,
      borderColor: isSelected ? tokens.formAccentColor : tokens.colorBorder,
      textColor: isSelected ? tokens.colorText : tokens.colorSecondaryText,
      trailing: isSelected
          ? DsIcon(
              icon: DsIcons.check,
              size: DsIconSize.xs,
              color: tokens.colorText,
            )
          : null,
      onTap: () {
        final next = List<String>.of(selected);
        if (!next.remove(option.value)) next.add(option.value);
        onChanged(next);
      },
    );
  }
}

/// A small icon-only affordance (remove) with a >=48dp target, a tooltip and a
/// semantics button label.
class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
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
                child: DsIcon(
                  icon: icon,
                  size: DsIconSize.md,
                  color: tokens.colorSecondaryText,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A self-contained text input for a condition value that owns its controller so
/// keystrokes never reset the field, seeded once from [initialText] (the widget
/// is re-keyed when the target column or operator changes).
class _ValueTextField extends StatefulWidget {
  const _ValueTextField({
    super.key,
    required this.initialText,
    required this.hintText,
    required this.keyboardType,
    required this.onChanged,
  });

  final String initialText;
  final String hintText;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;

  @override
  State<_ValueTextField> createState() => _ValueTextFieldState();
}

class _ValueTextFieldState extends State<_ValueTextField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DsTextField(
      controller: _controller,
      hintText: widget.hintText,
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
    );
  }
}
