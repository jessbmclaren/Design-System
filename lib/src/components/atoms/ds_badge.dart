import 'package:flutter/material.dart';
import '../../theme/ds_tokens_extension.dart';

/// The visual intent of a [DsBadge].
///
/// Each variant maps to a semantically meaningful set of background, text and
/// border tokens defined in the theme:
///
/// * [neutral]: informational or default state with no strong connotation.
/// * [success]: positive, completed or healthy state.
/// * [warning]: cautionary state that may need attention.
/// * [danger]: error, failure or destructive state.
enum DsBadgeVariant { neutral, success, warning, danger }

/// A compact status badge rendered as a rounded pill.
///
/// [DsBadge] is used to label the state of an entity (such as a payment,
/// account or task) with a short word or phrase and an optional leading icon.
/// It sizes itself to its content (it never expands to fill available width)
/// so it can sit inline with text, inside table cells, list rows or headers.
///
/// All colours, radius, padding and typography are read from [DsTokens] so the
/// badge automatically adopts the active white-label theme. The [label] is
/// transformed according to the theme's `badgeLabelTextTransform` (for example
/// forced to uppercase) before being rendered.
///
/// This widget is purely static: it runs no animations or timers, so it is
/// safe to render directly in screenshots and golden tests.
///
/// Example:
/// ```dart
/// const DsBadge(
///   label: 'Paid',
///   variant: DsBadgeVariant.success,
///   icon: DsIcons.success,
/// )
/// ```
class DsBadge extends StatelessWidget {
  /// Creates a status badge.
  ///
  /// The [label] is required and should be short; long values are truncated
  /// with an ellipsis. The [variant] selects the colour scheme and defaults to
  /// [DsBadgeVariant.neutral]. Provide an optional [icon] to show a small
  /// leading glyph tinted with the badge's text colour.
  const DsBadge({
    super.key,
    required this.label,
    this.variant = DsBadgeVariant.neutral,
    this.icon,
  });

  /// The text shown inside the badge.
  ///
  /// The theme's `badgeLabelTextTransform` is applied to this value before it
  /// is rendered.
  final String label;

  /// The semantic intent of the badge, which selects its colours.
  final DsBadgeVariant variant;

  /// An optional leading icon tinted with the badge's text colour.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    final (background, foreground, border) = switch (variant) {
      DsBadgeVariant.neutral => (
          tokens.badgeNeutralColorBackground,
          tokens.badgeNeutralColorText,
          tokens.badgeNeutralColorBorder,
        ),
      DsBadgeVariant.success => (
          tokens.badgeSuccessColorBackground,
          tokens.badgeSuccessColorText,
          tokens.badgeSuccessColorBorder,
        ),
      DsBadgeVariant.warning => (
          tokens.badgeWarningColorBackground,
          tokens.badgeWarningColorText,
          tokens.badgeWarningColorBorder,
        ),
      DsBadgeVariant.danger => (
          tokens.badgeDangerColorBackground,
          tokens.badgeDangerColorText,
          tokens.badgeDangerColorBorder,
        ),
    };

    final transformedLabel = tokens.badgeLabelTextTransform.apply(label);

    final textStyle = TextStyle(
      color: foreground,
      fontSize: tokens.badgeLabelFontSize,
      fontWeight: tokens.badgeLabelFontWeight,
      height: 1.0,
    );

    return Semantics(
      container: true,
      label: transformedLabel,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(tokens.badgeBorderRadius),
          border: Border.all(color: border),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: tokens.badgePaddingX,
            vertical: tokens.badgePaddingY,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: tokens.badgeLabelFontSize + 2,
                  color: foreground,
                ),
                SizedBox(width: tokens.badgePaddingX / 2),
              ],
              Flexible(
                child: Text(
                  transformedLabel,
                  style: textStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
