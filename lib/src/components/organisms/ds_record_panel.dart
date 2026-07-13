import 'package:flutter/material.dart';
import '../../tokens/ds_icons.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';
import '../atoms/ds_avatar.dart';
import '../atoms/ds_badge.dart';
import '../atoms/ds_button.dart';
import '../atoms/ds_checkbox.dart';
import '../atoms/ds_icon.dart';
import '../atoms/ds_icon_button.dart';
import '../atoms/ds_link.dart';
import '../atoms/ds_switch.dart';
import '../molecules/ds_currency_field.dart';
import '../molecules/ds_date_field.dart';
import '../molecules/ds_form_field_group.dart';
import '../molecules/ds_select.dart';
import '../molecules/ds_text_field.dart';
import 'ds_data_grid.dart';

/// A named section of a [DsRecordPanel] form.
///
/// A group draws a titled block (rendered as a [DsFormFieldGroup] legend) around
/// the fields whose column keys are listed in [columnKeys], in the order given.
/// Columns that are not referenced by any group fall into a trailing **Other**
/// section (see [DsRecordPanel.groups]).
@immutable
class DsRecordFieldGroup {
  /// Creates a titled field group.
  const DsRecordFieldGroup({required this.title, required this.columnKeys});

  /// The heading shown above the group's fields.
  final String title;

  /// The [DsGridColumn.key]s of the fields in this group, in display order.
  final List<String> columnKeys;
}

/// The detail / create / edit surface for a single record.
///
/// [DsRecordPanel] is the record modal used in database-style products: a
/// titled panel wrapping a typed, editable form of one record's fields. A
/// record's fields *are* [DsGridColumn]s (the same definitions a
/// [DsDataGrid] renders in columns) and its values a `Map<String, Object?>`
/// keyed by [DsGridColumn.key], so a row in a grid opens directly into a panel
/// with no translation layer.
///
/// It mirrors the titled-panel structure of [DsContextView] and [DsFocusView]
/// so it reads as part of the same family: a header (an optional leading avatar
/// derived from the [title], the title and [subtitle], and a labelled close
/// button when [onClose] is set), a scrollable body of labelled fields and an
/// optional footer carrying a primary **Save** and a secondary **Cancel**
/// button when their callbacks are provided. Every colour, radius, padding and
/// type style is read from [DsTokens.of], so the panel re-brands with the active
/// white-label theme.
///
/// ## Field editors
///
/// Each column renders the editor that suits its [DsGridColumn.type]:
///
/// * [DsCellType.text] / [DsCellType.link] / [DsCellType.user]: a
///   [DsTextField] (a `user` field edits the person's name).
/// * [DsCellType.number]: a numeric [DsTextField].
/// * [DsCellType.currency]: a [DsCurrencyField] using the column's
///   [DsGridColumn.currencySymbol].
/// * [DsCellType.date]: a [DsDateField].
/// * [DsCellType.singleSelect] / [DsCellType.status]: a [DsSelect] of the
///   column's [DsGridColumn.options].
/// * [DsCellType.multiSelect]: a checkable list of [DsCheckbox]es.
/// * [DsCellType.checkbox]: a [DsSwitch].
/// * [DsCellType.rating]: a row of tappable stars.
/// * [DsCellType.progress]: always read-only (a percentage).
///
/// A key listed in [readOnlyKeys] (and every `progress` field) renders its
/// value as display text / a badge / an avatar rather than an input.
///
/// ## Controlled
///
/// The panel holds no copy of the record: every edit emits a *new* full
/// [values] map through [onChanged] with only the edited key changed, and the
/// parent feeds the updated map straight back. Field editors are keyed by their
/// stable column key and reseed their controllers when an incoming value
/// changes, so editing one field, switching the displayed record or a
/// parent-driven value change never strands stale text in the wrong field.
///
/// ## Create vs edit
///
/// There is no mode flag: pass a populated [values] map (and, say, the record's
/// name as [title]) to edit an existing record, or an empty map (and a title
/// like `'New vehicle'`) to create a new one. The same fields render empty.
///
/// ## Responsiveness & accessibility
///
/// On medium and wider panels the fields flow two-per-row; on a 320dp phone
/// they stack one per row without overflowing. The header title ellipsizes. The
/// panel fills the height of its (bounded) parent: place it in a drawer, a
/// dialog or an [Expanded]. It scrolls its body when the form is taller than
/// the space available. It starts no timers or animations, so it renders a
/// stable frame that is safe to capture in screenshots.
class DsRecordPanel extends StatelessWidget {
  /// Creates a record panel.
  const DsRecordPanel({
    super.key,
    required this.columns,
    required this.values,
    required this.onChanged,
    this.title,
    this.subtitle,
    this.readOnlyKeys = const <String>{},
    this.onSave,
    this.onClose,
    this.saveLabel = 'Save',
    this.groups,
  });

  /// The record's fields, in display order.
  final List<DsGridColumn> columns;

  /// The current values keyed by [DsGridColumn.key]. An empty map creates a new
  /// record (every field renders empty).
  final Map<String, Object?> values;

  /// Called with the full updated map on every edit; only the edited key
  /// differs from the incoming [values].
  final ValueChanged<Map<String, Object?>> onChanged;

  /// The panel title, for example `'Ford Transit'` or `'New vehicle'`.
  final String? title;

  /// Optional supporting text shown beneath the [title].
  final String? subtitle;

  /// Column keys shown but not editable (an id, a derived field). Their values
  /// render read-only rather than as inputs.
  final Set<String> readOnlyKeys;

  /// Called by the footer's primary **Save** button. When null, no Save button
  /// is shown.
  final VoidCallback? onSave;

  /// Called by the header close button and the footer's secondary **Cancel**
  /// button. When null, neither is shown.
  final VoidCallback? onClose;

  /// The label of the footer's primary button. Defaults to `'Save'`.
  final String saveLabel;

  /// Optional sections that group the fields under titled blocks. When null the
  /// form is one flat, responsive list. Columns not referenced by any group are
  /// collected into a trailing **Other** section.
  final List<DsRecordFieldGroup>? groups;

  /// Emits a new full [values] map with [key] set to [value].
  void _emit(String key, Object? value) {
    final next = Map<String, Object?>.of(values);
    next[key] = value;
    onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final borderColor = tokens.colorBorder;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.formBackgroundColor,
        borderRadius: BorderRadius.circular(tokens.overlayBorderRadius),
        border: Border.all(color: borderColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tokens.overlayBorderRadius),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(
              title: title,
              subtitle: subtitle,
              onClose: onClose,
              tokens: tokens,
            ),
            Divider(height: 1, thickness: 1, color: borderColor),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: _buildForm(context, tokens),
              ),
            ),
            if (onSave != null || onClose != null) ...[
              Divider(height: 1, thickness: 1, color: borderColor),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Wrap(
                    spacing: tokens.spacingUnit * 1.5,
                    runSpacing: tokens.spacingUnit,
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (onClose != null)
                        DsButton(
                          label: 'Cancel',
                          variant: DsButtonVariant.secondary,
                          onPressed: onClose,
                        ),
                      if (onSave != null)
                        DsButton(
                          label: saveLabel,
                          onPressed: onSave,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, DsTokens tokens) {
    final byKey = <String, DsGridColumn>{
      for (final column in columns) column.key: column,
    };

    // Flat form: one responsive group of every column, in order.
    final groupList = groups;
    if (groupList == null) {
      return DsFormFieldGroup(
        children: [
          for (final column in columns) _buildField(context, tokens, column),
        ],
      );
    }

    // Grouped form: a titled section per group, then a trailing "Other" section
    // for any columns no group referenced (kept in their original order).
    final placed = <String>{};
    final sections = <Widget>[];
    for (final group in groupList) {
      final fields = <Widget>[];
      for (final key in group.columnKeys) {
        final column = byKey[key];
        if (column == null) continue;
        placed.add(key);
        fields.add(_buildField(context, tokens, column));
      }
      if (fields.isEmpty) continue;
      sections.add(
        DsFormFieldGroup(legend: group.title, children: fields),
      );
    }

    final leftovers = [
      for (final column in columns)
        if (!placed.contains(column.key))
          _buildField(context, tokens, column),
    ];
    if (leftovers.isNotEmpty) {
      sections.add(DsFormFieldGroup(legend: 'Other', children: leftovers));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < sections.length; i++) ...[
          if (i > 0) SizedBox(height: tokens.spacingUnit * 3),
          sections[i],
        ],
      ],
    );
  }

  /// Builds the editor (or read-only display) for a single [column], keyed by
  /// the stable column key so its controller state survives rebuilds and record
  /// switches.
  Widget _buildField(
    BuildContext context,
    DsTokens tokens,
    DsGridColumn column,
  ) {
    final key = ValueKey<String>('field:${column.key}');
    final value = values[column.key];
    final readOnly =
        readOnlyKeys.contains(column.key) || column.type == DsCellType.progress;

    if (readOnly) {
      return _LabeledField(
        key: key,
        label: column.title,
        child: _readOnlyValue(tokens, column, value),
      );
    }

    switch (column.type) {
      case DsCellType.text:
      case DsCellType.link:
      case DsCellType.user:
        return _TextRecordField(
          key: key,
          label: column.title,
          text: value is String ? value : (value?.toString() ?? ''),
          onChanged: (raw) => _emit(column.key, raw),
        );
      case DsCellType.number:
        return _TextRecordField(
          key: key,
          label: column.title,
          text: value is num ? _plainNumber(value) : (value?.toString() ?? ''),
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true, signed: true),
          onChanged: (raw) => _emit(column.key, _parseNumber(raw)),
        );
      case DsCellType.currency:
        return _CurrencyRecordField(
          key: key,
          label: column.title,
          symbol: column.currencySymbol ?? r'$',
          value: value is num ? value : null,
          onChanged: (amount) => _emit(column.key, amount),
        );
      case DsCellType.date:
        return DsDateField(
          key: key,
          label: column.title,
          value: value is DateTime ? value : null,
          hintText: 'Select a date',
          onChanged: (date) => _emit(column.key, date),
        );
      case DsCellType.singleSelect:
      case DsCellType.status:
        return _buildSelect(key, column, value);
      case DsCellType.multiSelect:
        return _buildMultiSelect(tokens, key, column, value);
      case DsCellType.checkbox:
        return _LabeledField(
          key: key,
          label: column.title,
          child: DsSwitch(
            value: value is bool ? value : false,
            onChanged: (next) => _emit(column.key, next),
          ),
        );
      case DsCellType.rating:
        return _buildRating(tokens, key, column, value);
      case DsCellType.progress:
        // Handled by the read-only branch above; kept for exhaustiveness.
        return _LabeledField(
          key: key,
          label: column.title,
          child: _readOnlyValue(tokens, column, value),
        );
    }
  }

  Widget _buildSelect(Key key, DsGridColumn column, Object? value) {
    final options = column.options;
    // Without a declared choice set a select degrades to a free-text field.
    if (options == null || options.isEmpty) {
      return _TextRecordField(
        key: key,
        label: column.title,
        text: value is String ? value : (value?.toString() ?? ''),
        onChanged: (raw) => _emit(column.key, raw),
      );
    }
    final current = value is String ? value : null;
    final items = <DsSelectOption<String>>[
      for (final option in options)
        DsSelectOption<String>(
          value: option.value,
          label: option.effectiveLabel,
        ),
    ];
    // Keep an out-of-set current value selectable rather than asserting.
    if (current != null && !items.any((o) => o.value == current)) {
      items.add(DsSelectOption<String>(value: current, label: current));
    }
    return DsSelect<String>(
      key: key,
      label: column.title,
      value: current,
      hintText: 'Select',
      options: items,
      onChanged: (next) => _emit(column.key, next),
    );
  }

  Widget _buildMultiSelect(
    DsTokens tokens,
    Key key,
    DsGridColumn column,
    Object? value,
  ) {
    final options = column.options ?? const <DsGridOption>[];
    final selected = <String>{
      if (value is List)
        for (final item in value) item?.toString() ?? '',
    };
    return _LabeledField(
      key: key,
      label: column.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final option in options)
            DsCheckbox(
              value: selected.contains(option.value),
              label: option.effectiveLabel,
              onChanged: (checked) {
                final next = Set<String>.of(selected);
                if (checked) {
                  next.add(option.value);
                } else {
                  next.remove(option.value);
                }
                // Preserve option order in the emitted list.
                _emit(column.key, [
                  for (final o in options)
                    if (next.contains(o.value)) o.value,
                ]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildRating(
    DsTokens tokens,
    Key key,
    DsGridColumn column,
    Object? value,
  ) {
    final filled = (value is num ? value : 0).clamp(0, 5).round();
    return _LabeledField(
      key: key,
      label: column.title,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var star = 1; star <= 5; star++)
            Semantics(
              button: true,
              label: 'Rate $star',
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: () => _emit(column.key, star),
                  borderRadius: BorderRadius.circular(tokens.formBorderRadius),
                  child: Padding(
                    padding: EdgeInsets.all(tokens.spacingUnit / 2),
                    child: DsIcon(
                      icon: star <= filled ? DsIcons.star : DsIcons.starOutline,
                      size: DsIconSize.lg,
                      color: star <= filled
                          ? tokens.colorPrimary
                          : tokens.colorBorder,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Renders a value as read-only display, mirroring the data grid's cell
  /// language (text, badges, avatars, links, stars).
  Widget _readOnlyValue(DsTokens tokens, DsGridColumn column, Object? value) {
    final emDash = Text(
      '—',
      style: tokens.bodyMd.toTextStyle(color: tokens.colorSecondaryText),
    );
    Text text(String value) => Text(
          value,
          style: tokens.bodyMd.toTextStyle(color: tokens.colorText),
        );

    switch (column.type) {
      case DsCellType.text:
        return value is String && value.isNotEmpty ? text(value) : emDash;
      case DsCellType.number:
        return value is num ? text(_displayNumber(value)) : emDash;
      case DsCellType.currency:
        if (value is! num) return emDash;
        final symbol = column.currencySymbol ?? r'$';
        return text('$symbol${_displayNumber(value, decimals: 2)}');
      case DsCellType.date:
        return value is DateTime ? text(_formatDate(value)) : emDash;
      case DsCellType.checkbox:
        final on = value is bool && value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DsIcon(
              icon: on ? DsIcons.checkboxChecked : DsIcons.checkboxBlank,
              size: DsIconSize.md,
              color: on ? tokens.colorPrimary : tokens.colorSecondaryText,
            ),
            SizedBox(width: tokens.spacingUnit),
            text(on ? 'Yes' : 'No'),
          ],
        );
      case DsCellType.singleSelect:
      case DsCellType.status:
        if (value is! String || value.isEmpty) return emDash;
        return _optionBadge(column, value);
      case DsCellType.multiSelect:
        if (value is! List || value.isEmpty) return emDash;
        return Wrap(
          spacing: tokens.spacingUnit / 2,
          runSpacing: tokens.spacingUnit / 2,
          children: [
            for (final item in value) _optionBadge(column, item?.toString() ?? ''),
          ],
        );
      case DsCellType.link:
        if (value is! String || value.isEmpty) return emDash;
        return DsLink(label: value, onPressed: _noop);
      case DsCellType.user:
        if (value is! String || value.isEmpty) return emDash;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            DsAvatar(name: value, size: 24),
            SizedBox(width: tokens.spacingUnit),
            Flexible(
              child: Text(
                value,
                style: tokens.bodyMd.toTextStyle(color: tokens.colorText),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      case DsCellType.rating:
        if (value is! num) return emDash;
        final filled = value.clamp(0, 5).round();
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 5; i++)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: DsIcon(
                  icon: i < filled ? DsIcons.star : DsIcons.starOutline,
                  size: DsIconSize.sm,
                  color: i < filled ? tokens.colorPrimary : tokens.colorBorder,
                ),
              ),
          ],
        );
      case DsCellType.progress:
        if (value is! num) return emDash;
        final percent = (value.clamp(0.0, 1.0) * 100).round();
        return text('$percent%');
    }
  }

  /// A read-only badge for a select / status / multi-select value, resolving the
  /// column's [DsGridOption] for its label, explicit colour or semantic variant.
  Widget _optionBadge(DsGridColumn column, String value) {
    DsGridOption? option;
    for (final candidate in column.options ?? const <DsGridOption>[]) {
      if (candidate.value == value) {
        option = candidate;
        break;
      }
    }
    final label = option?.effectiveLabel ?? value;
    final variant = option?.variant ?? _variantForStatus(value);
    return DsBadge(label: label, variant: variant);
  }
}

/// The panel header: an optional leading avatar, the title and subtitle, and a
/// close button when [onClose] is provided.
class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.subtitle,
    required this.onClose,
    required this.tokens,
  });

  final String? title;
  final String? subtitle;
  final VoidCallback? onClose;
  final DsTokens tokens;

  @override
  Widget build(BuildContext context) {
    final title = this.title;
    final subtitle = this.subtitle;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 8, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (title != null && title.isNotEmpty) ...[
            DsAvatar(name: title, size: 36),
            SizedBox(width: tokens.spacingUnit * 1.5),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (title != null)
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          tokens.headingSm.toTextStyle(color: tokens.colorText),
                    ),
                  ),
                if (subtitle != null && subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tokens.bodySm
                        .toTextStyle(color: tokens.colorSecondaryText),
                  ),
                ],
              ],
            ),
          ),
          if (onClose != null) ...[
            const SizedBox(width: 4),
            DsIconButton(
              icon: DsIcons.close,
              onPressed: onClose,
              semanticLabel: 'Close',
              iconSize: DsIconSize.lg,
              color: tokens.colorSecondaryText,
            ),
          ],
        ],
      ),
    );
  }
}

/// A labelled block for editors that do not render their own label (switches,
/// ratings, multi-select lists and read-only displays).
class _LabeledField extends StatelessWidget {
  const _LabeledField({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: _fieldLabelStyle(tokens)),
        SizedBox(height: tokens.fieldLabelGap),
        child,
      ],
    );
  }
}

/// A controlled text editor whose [TextEditingController] is reseeded when the
/// incoming [text] changes to something the field is not already showing, so a
/// switched record or a parent-driven value change never leaves stale text,
/// while never fighting the user's own keystrokes.
class _TextRecordField extends StatefulWidget {
  const _TextRecordField({
    super.key,
    required this.label,
    required this.text,
    required this.onChanged,
    this.keyboardType,
  });

  final String label;
  final String text;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;

  @override
  State<_TextRecordField> createState() => _TextRecordFieldState();
}

class _TextRecordFieldState extends State<_TextRecordField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.text);
  final FocusNode _focusNode = FocusNode();

  @override
  void didUpdateWidget(_TextRecordField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reseed only for a genuine external change: the incoming value differs from
    // what the field currently displays. The focus guard means our own live
    // keystrokes (which echo back identical) never move the cursor.
    if (widget.text != _controller.text && !_focusNode.hasFocus) {
      _controller.value = TextEditingValue(
        text: widget.text,
        selection: TextSelection.collapsed(offset: widget.text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DsTextField(
      label: widget.label,
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: widget.keyboardType,
      onChanged: widget.onChanged,
    );
  }
}

/// A controlled [DsCurrencyField]. Because the field owns its own controller via
/// `initialValue`, an external value change is applied by re-keying it (so it
/// re-seeds from the new value), while the user's live typing (which echoes the
/// value we just emitted) leaves the field untouched.
class _CurrencyRecordField extends StatefulWidget {
  const _CurrencyRecordField({
    super.key,
    required this.label,
    required this.symbol,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String symbol;
  final num? value;
  final ValueChanged<num?> onChanged;

  @override
  State<_CurrencyRecordField> createState() => _CurrencyRecordFieldState();
}

class _CurrencyRecordFieldState extends State<_CurrencyRecordField> {
  int _seed = 0;

  /// The value currently reflected by the inner field: our last echo.
  num? _shown;

  @override
  void initState() {
    super.initState();
    _shown = widget.value;
  }

  @override
  void didUpdateWidget(_CurrencyRecordField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Not our own echo → an external change → reseed the inner field.
    if (!_numEquals(widget.value, _shown)) {
      _shown = widget.value;
      _seed++;
    }
  }

  void _handle(num? next) {
    _shown = next;
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return DsCurrencyField(
      key: ValueKey<int>(_seed),
      label: widget.label,
      symbol: widget.symbol,
      value: widget.value,
      onChanged: _handle,
    );
  }
}

// --- Shared helpers ---------------------------------------------------------

bool _numEquals(num? a, num? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  return a == b;
}

TextStyle _fieldLabelStyle(DsTokens tokens) => tokens.labelMd
    .toTextStyle(color: tokens.colorText)
    .copyWith(fontWeight: tokens.mediumLabelFontWeight);

/// A no-op used to render a read-only [DsLink] as an active-looking link.
void _noop() {}

/// Formats a number for a plain, ungrouped editable field: an integer keeps no
/// decimals and a whole double drops its trailing `.0`.
String _plainNumber(num value) {
  if (value is int) return value.toString();
  if (value == value.roundToDouble()) return value.toStringAsFixed(0);
  return value.toString();
}

/// Parses editable numeric input, tolerating grouping commas and whitespace.
/// Returns null (an empty value) when the field is empty or unparseable.
num? _parseNumber(String raw) {
  final cleaned = raw.trim().replaceAll(',', '');
  if (cleaned.isEmpty) return null;
  return num.tryParse(cleaned);
}

/// Formats [value] with thousands separators for read-only display and with a
/// fixed number of fractional digits when [decimals] is given.
String _displayNumber(num value, {int? decimals}) {
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
DsBadgeVariant _variantForStatus(String value) {
  final normalized = value.trim().toLowerCase();
  const success = {
    'active',
    'success',
    'succeeded',
    'paid',
    'complete',
    'completed',
    'approved',
    'done',
    'live',
    'enabled',
    'on',
    'available',
  };
  const warning = {
    'pending',
    'warning',
    'in progress',
    'processing',
    'review',
    'in review',
    'waiting',
    'draft',
    'scheduled',
    'paused',
  };
  const danger = {
    'failed',
    'error',
    'danger',
    'declined',
    'rejected',
    'overdue',
    'cancelled',
    'canceled',
    'disabled',
    'off',
    'inactive',
    'blocked',
    'expired',
  };
  if (success.contains(normalized)) return DsBadgeVariant.success;
  if (warning.contains(normalized)) return DsBadgeVariant.warning;
  if (danger.contains(normalized)) return DsBadgeVariant.danger;
  return DsBadgeVariant.neutral;
}
