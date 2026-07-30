import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icons.dart';

/// How an unmet [DsCheckDot] reads.
enum DsCheckDotTone {
  /// Not satisfied yet, and that is fine. The default: a quiet outlined ring
  /// in the border colour, so a checklist someone is still working through
  /// never looks like a list of mistakes.
  neutral,

  /// Not satisfied, and it is now a problem. The ring takes the danger colour.
  /// Reach for this only once the person has tried to move on, never while
  /// they are still typing.
  danger,
}

/// The marker beside one item in a checklist: a filled check once the item is
/// satisfied, an outlined ring until then.
///
/// The dot is decorative and hidden from assistive technology, because the
/// state it shows is already carried by the row around it (a
/// `Semantics(checked:)` node) and by the label's own colour. Meaning never
/// rests on colour alone: a satisfied item gains a check glyph as well as a
/// tint, so the two states stay apart for a colour-blind reader and in a
/// greyscale print.
///
/// Used by [DsPasswordRequirements] and, through it, [DsPasswordStrength].
///
/// {@tool snippet}
///
/// ```dart
/// DsCheckDot(met: rule.met, unmetTone: DsCheckDotTone.danger)
/// ```
///
/// {@end-tool}
class DsCheckDot extends StatelessWidget {
  /// Creates a checklist marker.
  const DsCheckDot({
    super.key,
    required this.met,
    this.unmetTone = DsCheckDotTone.neutral,
    this.size,
  });

  /// Whether the item this dot marks is satisfied.
  final bool met;

  /// How the dot reads while [met] is false. Ignored once it is true.
  final DsCheckDotTone unmetTone;

  /// The dot's diameter. When null, resolves to [DsTokens.iconSizeMd].
  final double? size;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final double diameter = size ?? tokens.iconSizeMd;

    // The check glyph is sized by the ratio the icon scale itself sets between
    // its smallest and its row step, so a resized dot keeps its proportions
    // rather than needing a second measurement, and a skin that re-scales the
    // glyph steps carries the dot's interior with it.
    final double glyphRatio = tokens.iconSizeXxs / tokens.iconSizeMd;

    final Color unmetColor = switch (unmetTone) {
      DsCheckDotTone.neutral => tokens.colorBorder,
      DsCheckDotTone.danger => tokens.colorDanger,
    };

    return ExcludeSemantics(
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: DecoratedBox(
          decoration: met
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  color: tokens.badgeSuccessColorBackground,
                  border: Border.all(color: tokens.badgeSuccessColorBorder),
                )
              : BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: unmetColor, width: 1.5),
                ),
          child: met
              ? Center(
                  child: Icon(
                    DsIcons.check,
                    size: diameter * glyphRatio,
                    color: tokens.badgeSuccessColorText,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
