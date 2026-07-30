import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../util/ds_motion.dart';
import '../atoms/ds_icon_badge.dart';

/// A shortcut card: a glyph above a title and a supporting line.
///
/// [DsActionTile] is the tile a home screen puts its common jobs on, where
/// [DsStatTile] states a number. The glyph does the recognising, so a thumb
/// finds the tile before the label is read; the title names the job and the
/// subtitle says what it leads to.
///
/// A grid of tiles is a `Row` of `Expanded` tiles, or a `Wrap` below a
/// comfortable width so each keeps a readable measure.
///
/// ```dart
/// Row(
///   children: [
///     Expanded(
///       child: DsActionTile(
///         icon: DsIcons.fuel,
///         title: 'I want to fuel',
///         subtitle: 'Find a station',
///         tone: DsIconBadgeTone.danger,
///         onTap: openStations,
///       ),
///     ),
///     const SizedBox(width: 12),
///     Expanded(
///       child: DsActionTile(
///         icon: DsIcons.rewards,
///         title: 'Rewards',
///         subtitle: 'Points & streaks',
///         tone: DsIconBadgeTone.warning,
///         onTap: openRewards,
///       ),
///     ),
///   ],
/// )
/// ```
class DsActionTile extends StatefulWidget {
  /// Creates a shortcut card.
  const DsActionTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.tone = DsIconBadgeTone.brandSoft,
    this.shape = DsIconBadgeShape.rounded,
    this.markSize = 44,
    this.onTap,
  });

  /// The glyph shown in the tile's leading mark.
  final IconData icon;

  /// The job the tile leads to.
  final String title;

  /// Optional supporting line beneath the [title].
  final String? subtitle;

  /// The tone of the leading mark. Defaults to [DsIconBadgeTone.brandSoft], so
  /// a row of tiles reads as one family until a caller distinguishes them.
  final DsIconBadgeTone tone;

  /// The shape of the leading mark. Defaults to [DsIconBadgeShape.rounded], the
  /// launcher-tile reading a shortcut wants; a circle reads as a status.
  final DsIconBadgeShape shape;

  /// The leading mark's side in logical pixels. Defaults to 44, large enough to
  /// carry the tile at a glance without crowding the two lines beneath it.
  final double markSize;

  /// Called when the tile is chosen. Null renders a plain, static card and
  /// drops it from the focus order.
  final VoidCallback? onTap;

  @override
  State<DsActionTile> createState() => _DsActionTileState();
}

class _DsActionTileState extends State<DsActionTile> {
  bool _hovered = false;
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);
    final double unit = tokens.spacingUnit;
    final bool interactive = widget.onTap != null;

    final Color fill = _hovered && interactive
        ? tokens.surfaceHoverColor
        : tokens.formBackgroundColor;

    final Widget card = AnimatedContainer(
      duration: DsMotion.durationOf(context, DsMotion.fast),
      curve: DsMotion.curveOf(context, DsMotion.standard),
      padding: EdgeInsets.all(unit * 2),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        // The card carries a shadow rather than an outline, so a grid of tiles
        // reads as objects lifted off the page. Keyboard focus is the one time
        // it draws a ring, since a shadow cannot show focus.
        border: _focused
            ? Border.all(
                color: tokens.focusRingColor,
                width: tokens.focusRingWidth,
              )
            : Border.all(color: Colors.transparent, width: tokens.focusRingWidth),
        boxShadow: tokens.shadowLow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // The mark is decorative here: the title already names the job, so a
          // screen reader would only hear it twice.
          DsIconBadge(
            icon: widget.icon,
            tone: widget.tone,
            shape: widget.shape,
            size: widget.markSize,
          ),
          SizedBox(height: unit * 1.5),
          Text(
            widget.title,
            style: tokens.labelMd.toTextStyle(color: tokens.colorText),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (widget.subtitle != null) ...<Widget>[
            SizedBox(height: unit / 4),
            Text(
              widget.subtitle!,
              style: tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );

    if (!interactive) {
      return Semantics(
        container: true,
        label: _announcement(),
        child: ExcludeSemantics(child: card),
      );
    }

    return Semantics(
      button: true,
      label: _announcement(),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(tokens.radiusLg),
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          onHover: (bool value) => setState(() => _hovered = value),
          onFocusChange: (bool value) => setState(() => _focused = value),
          child: ExcludeSemantics(child: card),
        ),
      ),
    );
  }

  /// The tile reads as one thing: the job, then where it leads.
  String _announcement() {
    final String subtitle =
        widget.subtitle == null ? '' : ', ${widget.subtitle}';
    return '${widget.title}$subtitle';
  }
}
