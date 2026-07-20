import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';

/// A keycap showing the keyboard shortcut that triggers a nearby action.
///
/// [DsKeyHint] renders one or more keys as small caps beside an action, the
/// way a product teaches its shortcuts in place: a Create button hinting `N`,
/// a dialog's submit hinting `⌘` `↵`. It is decorative by default, because
/// the control it sits beside already carries the action and its name; a
/// screen reader that also announced the keycap would say the action twice.
/// Pass a [semanticLabel] when the hint stands alone, such as in a shortcut
/// reference table.
///
/// ```dart
/// DsButton(
///   label: 'New record',
///   onPressed: create,
///   keyHint: const ['N'],
/// )
/// ```
class DsKeyHint extends StatelessWidget {
  /// Creates a keyboard hint.
  const DsKeyHint({
    super.key,
    required this.keys,
    this.onSurface = false,
    this.semanticLabel,
  });

  /// The keys to show, in press order: `['⌘', '↵']` reads as command then
  /// enter. Each renders as its own cap.
  final List<String> keys;

  /// Whether the hint sits on a filled control (a primary button) rather than
  /// a plain surface. On a filled control the cap borrows the label's colour
  /// at low opacity so it reads as part of the button.
  final bool onSurface;

  /// The name assistive technology announces. Null (the default) hides the
  /// hint from assistive technology, since the control beside it already
  /// carries the action.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    // Nothing to teach: an empty hint takes no room rather than drawing an
    // empty cap. A const constructor cannot assert a list's length, so the
    // guard lives here.
    if (keys.isEmpty) return const SizedBox.shrink();

    final DsTokens tokens = DsTokens.of(context);
    final double unit = tokens.spacingUnit;
    // On a filled control the cap tints from the surrounding label colour; on
    // a plain surface it uses the muted fill and secondary ink.
    final Color ink = onSurface
        ? DefaultTextStyle.of(context).style.color ?? tokens.colorText
        : tokens.colorSecondaryText;
    final Color fill = onSurface
        ? ink.withValues(alpha: tokens.stateHoverOpacity * 2)
        : tokens.offsetBackgroundColor;

    final Widget caps = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int i = 0; i < keys.length; i++) ...<Widget>[
          if (i > 0) SizedBox(width: unit / 2),
          Container(
            constraints: BoxConstraints(minWidth: unit * 2.5),
            padding: EdgeInsets.symmetric(
              horizontal: unit / 2,
              vertical: unit / 4,
            ),
            decoration: BoxDecoration(
              color: fill,
              borderRadius: BorderRadius.circular(tokens.radiusControl),
            ),
            child: Text(
              keys[i],
              textAlign: TextAlign.center,
              style: tokens.labelSm.toTextStyle(color: ink),
              maxLines: 1,
            ),
          ),
        ],
      ],
    );

    if (semanticLabel == null) return ExcludeSemantics(child: caps);
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: caps,
    );
  }
}
