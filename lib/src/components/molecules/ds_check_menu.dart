import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import 'ds_check_list.dart';
import 'menu_shell.dart';

/// A checklist anchored beneath a trigger, for choosing several things at once.
///
/// Where `DsMenu` picks one command and closes, [DsCheckMenu] stays open while
/// the user ticks options on and off — the shape you want for a column picker,
/// a tag picker or a filter's value list. It is controlled: every toggle
/// reports the whole next selection through [onChanged] and the caller passes
/// the result back in [selected], so the menu never holds state of its own.
///
/// ```dart
/// DsCheckMenu(
///   trigger: const DsIcon(icon: DsIcons.tune, semanticLabel: 'Columns'),
///   options: const [
///     DsCheckOption(value: 'status', label: 'Status', enabled: false),
///     DsCheckOption(value: 'spend', label: 'Spend'),
///     DsCheckOption(value: 'clicks', label: 'Clicks'),
///   ],
///   selected: _visible,
///   onChanged: (next) => setState(() => _visible = next),
/// )
/// ```
///
/// The surface takes its fill ([DsTokens.formBackgroundColor]), corner radius
/// ([DsTokens.overlayBorderRadius]), 1px border ([DsTokens.colorBorder]) and
/// [DsTokens.shadowMedium] drop shadow from the active theme, matching
/// `DsMenu`, so a white-label skin restyles both without touching either
/// widget.
///
/// ## The select-all row
///
/// A trailing row selects every enabled option; once they are all selected it
/// flips to clearing them again. Locked options ([DsCheckOption.enabled]
/// `false`) are never touched by it, so a caller that locks one option knows
/// the selection can never be emptied. Pass [showSelectAll] `false` to drop the
/// row entirely.
///
/// ## Responsiveness
///
/// The surface sizes to its content between 200dp and 320dp wide, so it fits a
/// 320dp phone, and scrolls vertically past [maxListHeight] rather than
/// overflowing when the option list is long. [MenuAnchor] keeps it on screen
/// and repositions it near edges.
///
/// ## Accessibility
///
/// The trigger is a button that reports its expanded state. Each row is a
/// labelled checkbox that is keyboard-focusable and toggles on Enter and
/// Space; Escape closes the menu. Give an icon-only [trigger] its own label
/// (for example via `DsIcon.semanticLabel`) so its purpose is announced.
///
/// ## Screenshot safety
///
/// The menu is closed on first build and starts no timers or animations, so it
/// renders deterministically in a static demo.
class DsCheckMenu extends StatelessWidget {
  /// Creates a checklist menu.
  const DsCheckMenu({
    super.key,
    required this.trigger,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.showSelectAll = true,
    this.selectAllLabel = 'Select all',
    this.clearAllLabel = 'Clear all',
    this.maxListHeight = 320,
  });

  /// The widget the user taps to open the menu.
  final Widget trigger;

  /// The choices shown when the menu is open, in display order.
  final List<DsCheckOption> options;

  /// The values currently ticked.
  final Set<String> selected;

  /// Called with the whole next selection whenever a row (or the select-all
  /// row) is toggled. A null callback disables every row, leaving the menu
  /// readable but inert.
  final ValueChanged<Set<String>>? onChanged;

  /// Whether the trailing select-all / clear-all row is shown.
  final bool showSelectAll;

  /// The select-all row's label while some enabled option is unticked.
  final String selectAllLabel;

  /// The select-all row's label once every enabled option is ticked, when
  /// activating it clears them instead.
  final String clearAllLabel;

  /// The height past which the option list scrolls instead of growing.
  final double maxListHeight;

  /// The options the select-all row is allowed to touch.
  Iterable<DsCheckOption> get _togglable =>
      options.where((DsCheckOption option) => option.enabled);

  /// Whether every togglable option is already ticked, which flips the
  /// select-all row into a clear-all row. An empty togglable set never reads as
  /// "all selected", so the row stays a no-op rather than inverting.
  bool get _allSelected =>
      _togglable.isNotEmpty &&
      _togglable.every((DsCheckOption o) => selected.contains(o.value));

  void _toggleAll() {
    final Set<String> updated = <String>{...selected};
    // Locked options are left exactly as they are, so a caller that locks one
    // option is guaranteed a non-empty selection.
    for (final DsCheckOption option in _togglable) {
      if (_allSelected) {
        updated.remove(option.value);
      } else {
        updated.add(option.value);
      }
    }
    onChanged?.call(updated);
  }

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);
    final BorderRadius radius = BorderRadius.circular(
      tokens.overlayBorderRadius,
    );
    final bool enabled = onChanged != null;

    return MenuShell(
      trigger: trigger,
      panel: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 200, maxWidth: 320),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.formBackgroundColor,
            borderRadius: radius,
            border: Border.all(color: tokens.colorBorder),
            boxShadow: tokens.shadowMedium,
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: DsCheckList(
              options: options,
              selected: selected,
              onChanged: onChanged,
              maxHeight: maxListHeight,
              actionLabel: showSelectAll
                  ? (_allSelected ? clearAllLabel : selectAllLabel)
                  : null,
              onAction:
                  enabled && _togglable.isNotEmpty ? _toggleAll : null,
            ),
          ),
        ),
      ),
    );
  }
}
