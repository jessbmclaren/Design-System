import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../atoms/ds_checkbox.dart';

/// One choice within a [DsCheckList].
///
/// An option pairs a stable [value] (what the list reports back) with the
/// [label] the user reads. Set [enabled] to `false` to lock a choice in place:
/// a locked option keeps whatever state it is in and ignores taps, which is
/// how a caller guarantees a selection can never empty.
@immutable
class DsCheckOption {
  /// Creates a check-list option.
  const DsCheckOption({
    required this.value,
    required this.label,
    this.enabled = true,
  });

  /// The identifier reported through [DsCheckList.onChanged]. Must be unique
  /// within the list.
  final String value;

  /// The text shown beside the checkbox.
  final String label;

  /// Whether the option can be toggled. A locked option is dimmed and ignores
  /// taps.
  final bool enabled;
}

/// A scrollable column of checkbox rows with an optional trailing action row.
///
/// This is the body shared by every "pick several from a set" surface in the
/// system — the `DsCheckMenu` column picker and the data grid's multi-select
/// cell editor both render one, so two checklists in the same product are the
/// same checklist. It draws no surface of its own: the host supplies the fill,
/// border, radius and shadow, because a popover, a panel and an inline block
/// frame their content differently.
///
/// It is controlled. Every toggle reports the whole next selection through
/// [onChanged] and the caller passes the result back in [selected], so the
/// list holds no state.
///
/// ```dart
/// DsCheckList(
///   options: const [
///     DsCheckOption(value: 'status', label: 'Status', enabled: false),
///     DsCheckOption(value: 'spend', label: 'Spend'),
///   ],
///   selected: _visible,
///   onChanged: (next) => setState(() => _visible = next),
///   actionLabel: 'Select all',
///   onAction: _selectAll,
/// )
/// ```
///
/// ## Layout
///
/// The rows scroll once they pass [maxHeight] while the action row stays
/// pinned beneath them, so a long list never pushes its own action off the
/// bottom. The list sizes to its host's width; give it bounded width (a
/// popover's `ConstrainedBox`, a panel's column) rather than an unbounded one.
///
/// ## Accessibility
///
/// Each row is a `DsCheckbox`: labelled, keyboard-focusable and toggled by
/// Enter or Space, with a 48dp target. The action row is a button of the same
/// height. Nothing here is pointer-only.
class DsCheckList extends StatelessWidget {
  /// Creates a check list.
  const DsCheckList({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.actionLabel,
    this.onAction,
    this.maxHeight = 320,
  });

  /// The choices, in display order.
  final List<DsCheckOption> options;

  /// The values currently ticked.
  final Set<String> selected;

  /// Called with the whole next selection whenever a row is toggled. A null
  /// callback disables every row, leaving the list readable but inert.
  final ValueChanged<Set<String>>? onChanged;

  /// The trailing action row's label. Null renders no action row.
  final String? actionLabel;

  /// Called when the action row is activated. Null (with an [actionLabel] set)
  /// renders the row disabled.
  final VoidCallback? onAction;

  /// The height past which the rows scroll instead of growing.
  final double maxHeight;

  void _toggle(DsCheckOption option, bool next) {
    final Set<String> updated = <String>{...selected};
    if (next) {
      updated.add(option.value);
    } else {
      updated.remove(option.value);
    }
    onChanged?.call(updated);
  }

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);
    final double padX = tokens.spacingUnit * 1.5;
    final bool enabled = onChanged != null;
    final String? label = actionLabel;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: SingleChildScrollView(
              // Hosts commonly already own a scrollable that has claimed the
              // PrimaryScrollController (MenuAnchor does). This list must not
              // claim it too, or an enclosing scrollbar sees two positions and
              // throws.
              primary: false,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: tokens.spacingUnit / 2),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    for (final DsCheckOption option in options)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: padX),
                        child: DsCheckbox(
                          value: selected.contains(option.value),
                          label: option.label,
                          onChanged: enabled && option.enabled
                              ? (bool next) => _toggle(option, next)
                              : null,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (label != null)
          _DsCheckListAction(tokens: tokens, label: label, onTap: onAction),
      ],
    );
  }
}

/// The trailing row that runs the list's one action.
class _DsCheckListAction extends StatelessWidget {
  const _DsCheckListAction({
    required this.tokens,
    required this.label,
    required this.onTap,
  });

  final DsTokens tokens;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = onTap == null
        ? tokens.actionPrimaryColorText.withValues(alpha: 0.38)
        : tokens.actionPrimaryColorText;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: tokens.colorBorder)),
      ),
      child: Semantics(
        button: true,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              // A full 48dp target, so the row is comfortable on touch.
              constraints: const BoxConstraints(minHeight: 48),
              child: Center(
                child: Text(
                  label,
                  style: tokens.labelMd.toTextStyle(color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
