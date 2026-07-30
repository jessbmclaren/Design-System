import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../atoms/ds_icon.dart';

/// A slim status strip along an app's bottom edge.
///
/// [DsStatusBar] closes the chrome frame beneath the content: a hairline-
/// topped band carrying a quiet [label] (with an optional [icon]) on the
/// leading edge and any [trailing] widgets on the other. Use it for ambient
/// footer chrome such as an environment name, a developers strip or quick
/// links; keep primary actions out of it.
///
/// Set [transparent] to drop the fill and hairline when the bar sits over a
/// decorated backdrop and only its content should show.
///
/// ```dart
/// DsStatusBar(
///   icon: DsIcons.terminal,
///   label: 'Developers',
/// )
/// ```
class DsStatusBar extends StatelessWidget {
  /// Creates a status strip.
  const DsStatusBar({
    super.key,
    this.label,
    this.icon,
    this.trailing = const <Widget>[],
    this.transparent = false,
  });

  /// The quiet leading text. Null leaves the leading edge empty.
  final String? label;

  /// An optional glyph before the [label].
  final IconData? icon;

  /// Widgets pinned to the trailing edge, in display order. Purely decorative
  /// runs should be wrapped in [ExcludeSemantics] by the caller.
  final List<Widget> trailing;

  /// Whether to drop the fill and top hairline, leaving only the content.
  final bool transparent;

  /// The bar height, in logical pixels.
  static const double height = 36;

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);
    final double unit = tokens.spacingUnit;

    return Container(
      // The design height is a minimum: the bar grows with the user's text
      // scale instead of clipping its content.
      constraints: const BoxConstraints(minHeight: height),
      alignment: AlignmentDirectional.centerStart,
      padding: EdgeInsets.symmetric(horizontal: unit * 2),
      decoration: transparent
          ? null
          : BoxDecoration(
              color: tokens.colorBackground,
              border: Border(
                top: BorderSide(color: tokens.colorBorderSubtle),
              ),
            ),
      child: Row(
        children: <Widget>[
          if (icon != null) ...<Widget>[
            DsIcon(
              icon: icon!,
              size: tokens.iconSizeSm,
              color: tokens.colorSecondaryText,
            ),
            SizedBox(width: unit),
          ],
          if (label != null)
            Expanded(
              child: Text(
                label!,
                style: tokens.labelSm
                    .toTextStyle(color: tokens.colorSecondaryText),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            const Spacer(),
          // Flexible so the trailing run yields to the label and shrinks
          // (its texts ellipsize) rather than overflowing the slim bar when
          // a narrow width or a large text scale runs out of room.
          for (int i = 0; i < trailing.length; i++) ...<Widget>[
            if (i > 0) SizedBox(width: unit * 2),
            Flexible(child: trailing[i]),
          ],
        ],
      ),
    );
  }
}
