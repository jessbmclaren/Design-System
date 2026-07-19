import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';
import '../../tokens/ds_icons.dart';
import '../atoms/ds_icon_button.dart';
import '../atoms/ds_spinner.dart';
import 'ds_text_field.dart';

/// A search input: a leading search glyph, a placeholder and a clear
/// affordance that appears once there is something to clear.
///
/// [DsSearchField] is the Design System's standard way to filter a collection
/// or start a lookup. It composes a [DsTextField] with the search glyph on the
/// leading edge, so it inherits the field family's fill, border, focus and
/// disabled treatments and sits flush beside other form controls. While the
/// field is non-empty an inline clear button renders on the trailing edge;
/// pressing it empties the field, reports `''` through [onChanged] and fires
/// [onClear].
///
/// For an asynchronous lookup, set [pending] while results are loading and a
/// small spinner replaces the clear affordance, so the field itself signals
/// that work is in flight.
///
/// The caller owns the text: pass a [controller] to read, seed or clear the
/// query from outside. A null [onChanged] disables the field and removes it
/// from the focus order, matching the system's controlled convention.
///
/// ```dart
/// DsSearchField(
///   controller: _query,
///   hintText: 'Search accounts',
///   onChanged: (query) => _filter(query),
/// )
/// ```
class DsSearchField extends StatefulWidget {
  /// Creates a search input.
  const DsSearchField({
    super.key,
    this.controller,
    required this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.hintText = 'Search',
    this.pending = false,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
  });

  /// Controls the query being edited. When null the field manages its own
  /// controller internally.
  final TextEditingController? controller;

  /// Called whenever the query changes, including with `''` when the clear
  /// affordance is pressed. A null callback disables the field and drops it
  /// from the focus order.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits the query, for example via the keyboard's
  /// search action.
  final ValueChanged<String>? onSubmitted;

  /// Called after the clear affordance empties the field, in addition to the
  /// `''` reported through [onChanged].
  final VoidCallback? onClear;

  /// Placeholder text shown while the field is empty.
  final String hintText;

  /// Whether an asynchronous lookup is in flight. While true a small spinner
  /// replaces the clear affordance.
  final bool pending;

  /// The name assistive technology announces for the field. Defaults to
  /// [hintText].
  final String? semanticLabel;

  /// An optional focus node controlling the field's focus.
  final FocusNode? focusNode;

  /// Whether the field requests focus as soon as it is shown.
  final bool autofocus;

  @override
  State<DsSearchField> createState() => _DsSearchFieldState();
}

class _DsSearchFieldState extends State<DsSearchField> {
  /// The internal controller, created only when the caller passes none.
  TextEditingController? _internalController;

  /// Whether the field holds text, tracked so the widget rebuilds only when
  /// emptiness flips rather than on every keystroke.
  bool _hasText = false;

  TextEditingController get _controller =>
      widget.controller ?? (_internalController ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
    _hasText = _controller.text.isNotEmpty;
  }

  @override
  void didUpdateWidget(DsSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _internalController)
          ?.removeListener(_onTextChanged);
      _controller.addListener(_onTextChanged);
      _hasText = _controller.text.isNotEmpty;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _internalController?.dispose();
    super.dispose();
  }

  /// Rebuilds only when there is a change to whether text can be cleared.
  void _onTextChanged() {
    final bool hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);
    final bool enabled = widget.onChanged != null;
    final bool hasText = _hasText;

    // The trailing slot: a spinner while a lookup is pending, the clear
    // button while there is text, otherwise nothing.
    final Widget? suffix;
    if (widget.pending) {
      suffix = Padding(
        padding: EdgeInsets.symmetric(horizontal: tokens.spacingUnit),
        child: const DsSpinner(size: DsSpinnerSize.small),
      );
    } else if (hasText && enabled) {
      suffix = DsIconButton(
        icon: DsIcons.close,
        size: tokens.spacingUnit * 4,
        iconSize: DsIconSize.xs,
        semanticLabel: 'Clear search',
        onPressed: _clear,
      );
    } else {
      suffix = null;
    }

    return Semantics(
      label: widget.semanticLabel ?? widget.hintText,
      child: DsTextField(
        controller: _controller,
        onChanged: enabled ? widget.onChanged : null,
        onSubmitted: widget.onSubmitted,
        enabled: enabled,
        hintText: widget.hintText,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        textInputAction: TextInputAction.search,
        // The glyph is a graphic, so it uses the secondary text colour, which
        // clears the 3:1 graphic bar in every theme; the placeholder grey
        // does not on the neutral light base.
        prefixIcon: Icon(
          DsIcons.search,
          size: DsIconSize.md,
          color: tokens.colorSecondaryText,
        ),
        suffixIcon: suffix,
      ),
    );
  }
}
