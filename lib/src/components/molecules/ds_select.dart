import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icons.dart';
import '../../util/ds_motion.dart';
import '../atoms/ds_field_label.dart';
import '../atoms/ds_icon.dart';

/// The extra inset an [InputDecorator] gives an outlined field's content, taken
/// from the border's own gap padding. The menu rows carry the same inset, so an
/// option's label lands exactly where the closed field's text sat.
final double _fieldContentGap = const OutlineInputBorder().gapPadding;

/// A single choice within a [DsSelect].
///
/// Pairs the underlying [value] the control reports through its
/// `onChanged` callback with the human-readable [label] shown in the menu and
/// in the closed field.
@immutable
class DsSelectOption<T> {
  /// Creates an option binding a [value] to a display [label].
  const DsSelectOption({required this.value, required this.label});

  /// The value reported when this option is selected.
  final T value;

  /// The text shown for this option, both in the open menu and once selected.
  final String label;
}

/// A labelled dropdown select, generic over the selected value type [T].
///
/// `DsSelect` mirrors the look of the design system's text field: an optional
/// [label] sits above a filled, outlined control that opens a menu of
/// [options]. Selecting an option reports its `value` through [onChanged]; the
/// closed field shows that option's label, or the [hintText] placeholder while
/// [value] is `null`.
///
/// Use it whenever a user must pick exactly one value from a known, bounded
/// list (a country, a status, a currency) where a set of radio buttons would
/// take too much room. For free-form entry use a text field instead; for
/// multi-select, use a different control.
///
/// Pass a [helperText] to show a subdued line of guidance beneath the field,
/// and an [errorText] to move it into its error state. Inside a [Form], pass
/// a [validator] instead and the field reports its own message when the form
/// validates; [autovalidateMode] controls when that happens and [onSaved]
/// receives the chosen value when the form is saved.
///
/// All colours, spacing, radii and typography are read from [DsTokens], so the
/// control re-brands with the active theme and never hardcodes appearance.
///
/// ```dart
/// DsSelect<String>(
///   label: 'Country',
///   value: selected,
///   hintText: 'Select a country',
///   options: const [
///     DsSelectOption(value: 'us', label: 'United States'),
///     DsSelectOption(value: 'be', label: 'Belgium'),
///   ],
///   onChanged: (value) => setState(() => selected = value),
/// )
/// ```
///
/// ## The open menu
///
/// The menu drops **beneath** the closed field rather than covering it, so the
/// question stays readable while the answer is chosen, and it matches the
/// field's width and text inset so nothing shifts as it opens. It is the same
/// surface [DsMenu] uses: [DsTokens.formBackgroundColor] behind a 1px
/// [DsTokens.colorBorder], [DsTokens.overlayBorderRadius] corners and a
/// [DsTokens.shadowMedium] drop shadow. The current choice is marked with the
/// brand tint, the brand ink and a tick, and is scrolled into view and focused
/// as the menu opens. Long lists scroll inside a capped surface instead of
/// filling the viewport.
///
/// ## States
///
/// The border follows the rest of the field family: [DsTokens.colorBorder] at
/// rest, [DsTokens.formHighlightColorBorder] while focused or open, and
/// [DsTokens.colorDanger] in error, with error and focus sharing the
/// [DsTokens.inputFocusBorderWidth] emphasis. A disabled control dims its
/// border, its text and its chevron, and leaves the focus order entirely.
/// Passing no [options] disables the control too, since there is nothing to
/// pick.
///
/// ## Accessibility
///
/// The closed field is exposed as a button that reports its expanded state and
/// announces its label, its current value and any error message together. It
/// is reachable by Tab, opens on Enter or Space, walks with the arrow keys and
/// closes on Escape, and it holds a [DsTokens.minTapTarget] target in every
/// state, including while a validation message is showing.
///
/// ## Motion
///
/// The chevron turns through [DsMotion.control] as the menu opens and settles
/// to a still frame when the user asks for reduced motion.
class DsSelect<T> extends StatefulWidget {
  /// Creates a labelled dropdown select.
  ///
  /// [value] is the currently selected value (or `null` for none) and must
  /// match the `value` of one of the [options], or be `null`. [onChanged] is
  /// called with the newly picked value; passing `null` (or setting [enabled]
  /// to `false`) renders the control disabled.
  const DsSelect({
    super.key,
    this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.hintText,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.validator,
    this.autovalidateMode,
    this.onSaved,
    this.reserveErrorSpace = false,
  });

  /// Optional text shown above the field, describing what is being chosen.
  final String? label;

  /// The currently selected value, or `null` when nothing is selected.
  ///
  /// Must equal the [DsSelectOption.value] of exactly one entry in [options],
  /// or be `null`. The control is fully controlled: this value is what the
  /// closed field shows, so a caller that ignores [onChanged] sees no change.
  final T? value;

  /// The choices offered in the dropdown menu.
  ///
  /// An empty list disables the control; there is nothing to choose.
  final List<DsSelectOption<T>> options;

  /// Called with the newly selected value when the user picks an option.
  ///
  /// A `null` callback renders the control disabled (non-interactive).
  final ValueChanged<T?>? onChanged;

  /// Placeholder text shown in the closed field while [value] is `null`.
  final String? hintText;

  /// Guidance shown beneath the field. Ignored when a message from [errorText]
  /// or [validator] is showing.
  final String? helperText;

  /// An error message shown beneath the field. When non-null the control also
  /// adopts its error (danger) border. For [Form]-driven validation prefer
  /// [validator], which reports its message through the field itself. A manual
  /// [errorText] wins over a [validator] message.
  final String? errorText;

  /// Whether the control is interactive. Defaults to `true`. When `false` the
  /// field is dimmed and cannot be opened, and it sits the form out: its
  /// [validator] does not run and [onSaved] is not called, so a disabled
  /// select can never block a form with an error the user cannot fix.
  final bool enabled;

  /// Validates the selected value inside a [Form]. Return null for a valid
  /// value or the message to show beneath the field. The message renders in
  /// the same caption style as [errorText] and moves the border to the danger
  /// colour. Not run while the control is disabled.
  final FormFieldValidator<T>? validator;

  /// When the [validator] runs. Defaults to the enclosing [Form]'s mode; set
  /// [AutovalidateMode.onUserInteraction] to validate only once the user has
  /// picked an option, so an untouched field never shows a required error.
  final AutovalidateMode? autovalidateMode;

  /// Called with the selected value when the enclosing [Form] is saved. Not
  /// called while the control is disabled.
  final FormFieldSetter<T>? onSaved;

  /// Whether to keep the caption line allocated while nothing occupies it, so
  /// the field does not shift the layout as an error appears and clears. The
  /// matching switch on [DsTextField], for a form whose fields sit in a row.
  final bool reserveErrorSpace;

  @override
  State<DsSelect<T>> createState() => _DsSelectState<T>();
}

class _DsSelectState<T> extends State<DsSelect<T>> {
  final MenuController _menu = MenuController();
  final ScrollController _scroll = ScrollController();
  final FocusNode _triggerFocus = FocusNode(debugLabel: 'DsSelect');

  /// Marks the current choice so it can be scrolled into view as the menu
  /// opens, rather than leaving the user to hunt for it in a long list.
  final GlobalKey _selectedRowKey = GlobalKey();

  bool _open = false;
  bool _hovered = false;
  bool _focused = false;

  @override
  void dispose() {
    _scroll.dispose();
    _triggerFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);

    // A null callback also disables the control, matching Flutter convention,
    // and so does an empty list: there would be nothing behind the chevron.
    final bool isEnabled =
        widget.enabled && widget.onChanged != null && widget.options.isNotEmpty;

    return _DsSelectFormField<T>(
      selected: widget.value,
      enabled: isEnabled,
      // A disabled control cannot be operated, so it neither validates nor
      // saves; otherwise Form.validate() could fail on an error the user has
      // no way to fix.
      validator: isEnabled ? widget.validator : null,
      autovalidateMode: widget.autovalidateMode,
      onSaved: isEnabled ? widget.onSaved : null,
      builder: (FormFieldState<T> field) =>
          _buildField(context, tokens, field, isEnabled),
    );
  }

  Widget _buildField(
    BuildContext context,
    DsTokens tokens,
    FormFieldState<T> field,
    bool isEnabled,
  ) {
    // A manual errorText wins over the validator's message, and both render in
    // the one caption slot beneath the field, so the control keeps its full
    // tap target whatever it is saying.
    final String? message = widget.errorText ?? field.errorText;
    final bool hasError = message != null;
    final String? caption = message ?? widget.helperText;
    final Color captionColor = hasError
        ? tokens.colorDanger
        : tokens.colorSecondaryText;

    DsSelectOption<T>? selected;
    for (final DsSelectOption<T> option in widget.options) {
      if (option.value == widget.value) {
        selected = option;
        break;
      }
    }

    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (widget.label != null) ...<Widget>[
            DsFieldLabel(label: widget.label!),
            SizedBox(height: tokens.fieldLabelGap),
          ],
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return _buildAnchor(
                tokens: tokens,
                field: field,
                isEnabled: isEnabled,
                hasError: hasError,
                selected: selected,
                // The menu matches the field, so nothing jumps as it opens.
                // An unbounded parent leaves nothing to match, so the surface
                // falls back to the menu's own sizing.
                width: constraints.hasBoundedWidth
                    ? constraints.maxWidth
                    : null,
                ambientTextStyle: DefaultTextStyle.of(context).style,
              );
            },
          ),
          if (caption != null || widget.reserveErrorSpace) ...<Widget>[
            SizedBox(height: tokens.fieldLabelGap),
            Text(
              caption ?? ' ',
              style: tokens.bodySm.toTextStyle(color: captionColor),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnchor({
    required DsTokens tokens,
    required FormFieldState<T> field,
    required bool isEnabled,
    required bool hasError,
    required DsSelectOption<T>? selected,
    required double? width,
    required TextStyle ambientTextStyle,
  }) {
    return MenuAnchor(
      controller: _menu,
      // Keyboard traversal off the top of the menu lands back on the field
      // that opened it, rather than somewhere behind the overlay.
      childFocusNode: _triggerFocus,
      // The surface below draws its own fill, border and shadow, so the
      // anchor's built-in panel is transparent and un-clipped to avoid
      // double-painting or clipping the drop shadow.
      clipBehavior: Clip.none,
      alignmentOffset: Offset(0, tokens.spacingUnit / 2),
      style: const MenuStyle(
        backgroundColor: WidgetStatePropertyAll<Color>(Color(0x00000000)),
        surfaceTintColor: WidgetStatePropertyAll<Color>(Color(0x00000000)),
        shadowColor: WidgetStatePropertyAll<Color>(Color(0x00000000)),
        elevation: WidgetStatePropertyAll<double>(0),
        padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(EdgeInsets.zero),
      ),
      onOpen: () {
        setState(() => _open = true);
        _revealSelected();
      },
      onClose: () {
        setState(() => _open = false);
        // Escape leaves focus in an overlay that is about to go away, so hand
        // it back to the field the user opened. A close caused by moving on to
        // something else has already placed focus, so leave that alone.
        if (FocusManager.instance.primaryFocus is FocusScopeNode) {
          _triggerFocus.requestFocus();
        }
      },
      menuChildren: <Widget>[
        _DsSelectSurface<T>(
          tokens: tokens,
          options: widget.options,
          selectedValue: widget.value,
          width: width,
          // The overlay sits outside the field's text inheritance, so the
          // theme's effective font travels with it; a family-less token style
          // would otherwise render the options in the fallback face.
          rowTextStyle: tokens.bodyMd.toTextStyle().copyWith(
            fontFamily: ambientTextStyle.fontFamily,
            fontFamilyFallback: ambientTextStyle.fontFamilyFallback,
          ),
          controller: _scroll,
          selectedRowKey: _selectedRowKey,
          onSelected: (T value) => _select(field, value),
        ),
      ],
      builder: (BuildContext context, MenuController controller, Widget? child) {
        return Semantics(
          button: true,
          enabled: isEnabled,
          expanded: _open,
          onTap: isEnabled ? _toggle : null,
          child: FocusableActionDetector(
            focusNode: _triggerFocus,
            // A disabled control leaves the focus order rather than trapping
            // a keyboard user on something inert.
            enabled: isEnabled,
            mouseCursor: isEnabled
                ? SystemMouseCursors.click
                : SystemMouseCursors.basic,
            onShowFocusHighlight: (bool value) {
              if (_focused != value) setState(() => _focused = value);
            },
            onShowHoverHighlight: (bool value) {
              if (_hovered != value) setState(() => _hovered = value);
            },
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
              onTap: isEnabled ? _toggle : null,
              child: child,
            ),
          ),
        );
      },
      child: _buildTrigger(
        tokens: tokens,
        isEnabled: isEnabled,
        hasError: hasError,
        selected: selected,
      ),
    );
  }

  Widget _buildTrigger({
    required DsTokens tokens,
    required bool isEnabled,
    required bool hasError,
    required DsSelectOption<T>? selected,
  }) {
    final BorderRadius radius = BorderRadius.circular(tokens.formBorderRadius);

    OutlineInputBorder borderWith(Color color, double width) {
      return OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: color, width: width),
      );
    }

    final Color textColor = !isEnabled
        ? tokens.colorTextDisabled
        : selected != null
        ? tokens.colorText
        : tokens.formPlaceholderTextColor;

    final Color chevronColor = isEnabled
        ? tokens.colorSecondaryText
        : tokens.colorSecondaryText.withValues(
            alpha: tokens.stateDisabledOpacity,
          );

    final Widget content = Row(
      children: <Widget>[
        Expanded(
          child: Text(
            selected?.label ?? widget.hintText ?? '',
            style: tokens.bodyMd.toTextStyle(color: textColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: tokens.spacingUnit),
        AnimatedRotation(
          turns: _open ? 0.5 : 0,
          duration: DsMotion.durationOf(context, DsMotion.control),
          curve: DsMotion.curveOf(context, DsMotion.standard),
          child: DsIcon(
            icon: DsIcons.expandMore,
            size: tokens.iconSizeMd,
            color: chevronColor,
          ),
        ),
      ],
    );

    final InputDecoration decoration = InputDecoration(
      isDense: true,
      filled: true,
      fillColor: tokens.formBackgroundColor,
      enabled: isEnabled,
      // The same vertical padding the rest of the bordered field family
      // paints, so a select and a text field standing side by side in a form
      // are the same height rather than eight pixels apart.
      contentPadding: EdgeInsets.symmetric(
        horizontal: tokens.inputFieldPaddingX,
        vertical: tokens.textFieldPaddingY,
      ),
      border: borderWith(tokens.colorBorder, tokens.inputBorderWidth),
      enabledBorder: borderWith(tokens.colorBorder, tokens.inputBorderWidth),
      focusedBorder: borderWith(
        tokens.formHighlightColorBorder,
        tokens.inputFocusBorderWidth,
      ),
      // Error borders carry the focus emphasis, the same as the rest of the
      // field family, so a mistake is never quieter than a focus ring.
      errorBorder: borderWith(tokens.colorDanger, tokens.inputFocusBorderWidth),
      focusedErrorBorder: borderWith(
        tokens.colorDanger,
        tokens.inputFocusBorderWidth,
      ),
      disabledBorder: borderWith(
        tokens.colorBorder.withValues(alpha: tokens.stateDisabledOpacity),
        tokens.inputBorderWidth,
      ),
      // The message renders in the caption beneath the field, so the decorator
      // only needs to know that an error is present in order to pick its
      // border. Giving it no space keeps the control's tap target intact.
      error: hasError ? const SizedBox.shrink() : null,
      errorStyle: const TextStyle(height: 0, fontSize: 0),
    );

    return ConstrainedBox(
      // Guarantee an accessible touch target regardless of density, in every
      // state: the caption sits outside this box, so a validation message can
      // never shrink the control.
      constraints: BoxConstraints(minHeight: tokens.minTapTarget),
      child: InputDecorator(
        decoration: decoration,
        isFocused: _open || _focused,
        isHovering: _hovered,
        isEmpty: false,
        child: content,
      ),
    );
  }

  void _toggle() {
    if (_menu.isOpen) {
      _menu.close();
    } else {
      _menu.open();
    }
  }

  void _select(FormFieldState<T> field, T value) {
    // Tell the form first, so an onUserInteraction validator sees the pick
    // even when the caller drives no state of its own.
    field.didChange(value);
    widget.onChanged?.call(value);
    // Hand focus back to the field the user came from, not to whatever the
    // closing overlay leaves behind.
    _triggerFocus.requestFocus();
  }

  void _revealSelected() {
    if (widget.value == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? rowContext = _selectedRowKey.currentContext;
      if (!mounted || rowContext == null) return;
      Scrollable.ensureVisible(
        rowContext,
        alignment: 0.5,
        duration: Duration.zero,
      );
    });
  }
}

/// The themed surface that hosts the options, matched to the field's width.
class _DsSelectSurface<T> extends StatelessWidget {
  const _DsSelectSurface({
    required this.tokens,
    required this.options,
    required this.selectedValue,
    required this.width,
    required this.rowTextStyle,
    required this.controller,
    required this.selectedRowKey,
    required this.onSelected,
  });

  final DsTokens tokens;
  final List<DsSelectOption<T>> options;
  final T? selectedValue;
  final double? width;
  final TextStyle rowTextStyle;
  final ScrollController controller;
  final GlobalKey selectedRowKey;
  final ValueChanged<T> onSelected;

  /// The tallest the list grows before it scrolls, so thirty options open a
  /// menu rather than a wall. The anchor has already trimmed the incoming
  /// constraints to the room on screen, so this only ever caps them further.
  static const double _maxHeight = 320;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(
      tokens.overlayBorderRadius,
    );

    final bool hasSelection = options.any(
      (DsSelectOption<T> option) => option.value == selectedValue,
    );

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: width ?? 200,
        maxWidth: width ?? 320,
        maxHeight: _maxHeight,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.formBackgroundColor,
          borderRadius: radius,
          border: Border.all(color: tokens.colorBorder),
          boxShadow: tokens.shadowMedium,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: tokens.spacingUnit / 2),
            child: SingleChildScrollView(
              // Its own controller, so a long list never fights the page's
              // primary scroll view for the scrollbar.
              controller: controller,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (int i = 0; i < options.length; i++)
                    _DsSelectRow<T>(
                      key: options[i].value == selectedValue
                          ? selectedRowKey
                          : null,
                      tokens: tokens,
                      option: options[i],
                      textStyle: rowTextStyle,
                      selected: options[i].value == selectedValue,
                      // Open with the keyboard already on the current choice,
                      // or on the first row when there is nothing to return to.
                      autofocus: hasSelection
                          ? options[i].value == selectedValue
                          : i == 0,
                      onSelected: onSelected,
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

/// A single option, rendered as a [MenuItemButton] so it inherits focus,
/// keyboard navigation and automatic close-on-select from the [MenuAnchor].
class _DsSelectRow<T> extends StatelessWidget {
  const _DsSelectRow({
    super.key,
    required this.tokens,
    required this.option,
    required this.textStyle,
    required this.selected,
    required this.autofocus,
    required this.onSelected,
  });

  final DsTokens tokens;
  final DsSelectOption<T> option;
  final TextStyle textStyle;
  final bool selected;
  final bool autofocus;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final Color base = selected
        ? tokens.actionPrimaryColorText
        : tokens.colorText;

    return MenuItemButton(
      autofocus: autofocus,
      onPressed: () => onSelected(option.value),
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll<Color?>(
          selected ? tokens.brandTintColor : null,
        ),
        minimumSize: WidgetStatePropertyAll<Size>(Size(0, tokens.minTapTarget)),
        // The same inset as the closed field, so the label does not shift
        // sideways as the menu opens.
        padding: WidgetStatePropertyAll<EdgeInsetsGeometry>(
          EdgeInsets.symmetric(
            horizontal: tokens.inputFieldPaddingX + _fieldContentGap,
          ),
        ),
        shape: const WidgetStatePropertyAll<OutlinedBorder>(
          RoundedRectangleBorder(),
        ),
        textStyle: WidgetStatePropertyAll<TextStyle>(textStyle),
        foregroundColor: WidgetStatePropertyAll<Color>(base),
        iconColor: WidgetStatePropertyAll<Color>(base),
        overlayColor: WidgetStateProperty.resolveWith<Color>((
          Set<WidgetState> states,
        ) {
          if (states.contains(WidgetState.pressed)) {
            return base.withValues(alpha: 0.12);
          }
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused)) {
            return base.withValues(alpha: 0.08);
          }
          return const Color(0x00000000);
        }),
      ),
      // A tick, not colour alone, carries which option is the current one.
      trailingIcon: selected
          ? DsIcon(icon: DsIcons.check, size: tokens.iconSizeSm, color: base)
          : null,
      // The selected flag rides inside the button's own semantics node, so
      // the row is announced as the chosen one rather than as a sibling.
      child: Semantics(
        selected: selected,
        child: Text(option.label, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

/// The [FormField] host, which keeps the form's copy of the value in step with
/// the [DsSelect.value] the caller owns.
class _DsSelectFormField<T> extends FormField<T> {
  const _DsSelectFormField({
    required T? selected,
    required super.builder,
    required super.enabled,
    super.validator,
    super.onSaved,
    super.autovalidateMode,
  }) : selected = selected,
       super(initialValue: selected);

  /// The value the caller currently owns.
  final T? selected;

  @override
  FormFieldState<T> createState() => _DsSelectFormFieldState<T>();
}

class _DsSelectFormFieldState<T> extends FormFieldState<T> {
  _DsSelectFormField<T> get _field => widget as _DsSelectFormField<T>;

  @override
  void didUpdateWidget(covariant _DsSelectFormField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The caller owns the value, so an external change is the truth. Adopt it
    // without marking the field as touched, which would spring an
    // onUserInteraction validator on someone who has not chosen anything yet.
    if (oldWidget.selected != _field.selected) {
      setValue(_field.selected);
    }
  }
}
