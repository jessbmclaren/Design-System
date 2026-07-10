import 'package:flutter/material.dart';
import '../../tokens/ds_icons.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_spacing.dart';

/// The severity and tone of a [DsBanner].
///
/// The variant selects both the status icon and the colour set drawn from the
/// badge tokens, so a banner always reads consistently with the status badges
/// elsewhere in the system.
enum DsBannerVariant {
  /// Neutral, informational context. Uses the neutral badge palette.
  info,

  /// A positive outcome or confirmation. Uses the success badge palette.
  success,

  /// Something that may need attention soon. Uses the warning badge palette.
  warning,

  /// A blocking problem or failure. Uses the danger badge palette.
  danger,
}

/// A single trailing text action shown inside a [DsBanner].
///
/// Rendered as a text button tinted with the banner's variant colour. Use it
/// for the one action that resolves the banner (for example "Retry" or
/// "Review"); anything more elaborate belongs in the page body.
@immutable
class DsBannerAction {
  /// Creates a banner action with a [label] and its [onPressed] callback.
  const DsBannerAction({required this.label, required this.onPressed});

  /// The action label.
  final String label;

  /// Called when the action is tapped.
  final VoidCallback onPressed;
}

/// A persistent, inline banner that surfaces an issue or a required action.
///
/// Place a [DsBanner] directly under a page header (or at the top of a section)
/// to communicate state that should stay visible until it is resolved — a
/// failed payment, a pending verification, a saved-successfully confirmation.
/// Unlike a transient snackbar it does not disappear on its own; provide
/// [onDismiss] if the user should be able to close it.
///
/// The [variant] drives the leading status icon and the tinted colour set
/// (background, border and text) pulled from the badge tokens. Supply a
/// [title] for the headline, an optional [message] for supporting detail, an
/// optional [action] for the single most relevant next step, and [onDismiss]
/// to show a close button.
///
/// The layout is fully responsive: the text column flexes and the trailing
/// action drops below the text on narrow widths so the banner never overflows,
/// even at 320dp.
class DsBanner extends StatelessWidget {
  /// Creates an inline status banner.
  const DsBanner({
    super.key,
    required this.variant,
    required this.title,
    this.message,
    this.action,
    this.onDismiss,
  });

  /// The severity and tone of the banner.
  final DsBannerVariant variant;

  /// The banner headline. Shown in bold using the variant text colour.
  final String title;

  /// Optional supporting detail shown below the [title].
  final String? message;

  /// An optional trailing text action.
  final DsBannerAction? action;

  /// Called when the close button is tapped. When null, no close button is
  /// shown and the banner cannot be dismissed by the user.
  final VoidCallback? onDismiss;

  /// The width below which the [action] wraps onto its own line.
  static const double _wrapBreakpoint = 420;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    final (background, foreground, border, icon) = switch (variant) {
      DsBannerVariant.info => (
          tokens.badgeNeutralColorBackground,
          tokens.badgeNeutralColorText,
          tokens.badgeNeutralColorBorder,
          DsIcons.info,
        ),
      DsBannerVariant.success => (
          tokens.badgeSuccessColorBackground,
          tokens.badgeSuccessColorText,
          tokens.badgeSuccessColorBorder,
          DsIcons.success,
        ),
      DsBannerVariant.warning => (
          tokens.badgeWarningColorBackground,
          tokens.badgeWarningColorText,
          tokens.badgeWarningColorBorder,
          DsIcons.warning,
        ),
      DsBannerVariant.danger => (
          tokens.badgeDangerColorBackground,
          tokens.badgeDangerColorText,
          tokens.badgeDangerColorBorder,
          DsIcons.error,
        ),
    };

    final textColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: tokens.headingSm.toTextStyle(color: foreground),
        ),
        if (message != null && message!.isNotEmpty) ...[
          const SizedBox(height: DsSpacing.xs),
          Text(
            message!,
            style: tokens.bodySm.toTextStyle(
              color: foreground.withValues(alpha: 0.9),
            ),
          ),
        ],
      ],
    );

    final actionButton =
        action == null ? null : _buildAction(tokens, foreground);
    final closeButton = onDismiss == null ? null : _buildClose(foreground);

    return Semantics(
      container: true,
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(tokens.formBorderRadius),
        ),
        child: Padding(
          padding: const EdgeInsets.all(DsSpacing.md),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stackAction =
                  actionButton != null && constraints.maxWidth < _wrapBreakpoint;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 20, color: foreground),
                  const SizedBox(width: DsSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        textColumn,
                        if (stackAction) ...[
                          const SizedBox(height: DsSpacing.sm),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: actionButton,
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (!stackAction && actionButton != null) ...[
                    const SizedBox(width: DsSpacing.sm),
                    actionButton,
                  ],
                  if (closeButton != null) ...[
                    const SizedBox(width: DsSpacing.xs),
                    closeButton,
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildAction(DsTokens tokens, Color foreground) {
    return TextButton(
      onPressed: action!.onPressed,
      style: TextButton.styleFrom(
        foregroundColor: foreground,
        padding: const EdgeInsets.symmetric(
          horizontal: DsSpacing.sm,
          vertical: DsSpacing.xs,
        ),
        minimumSize: const Size(0, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        textStyle: tokens.labelMd.toTextStyle().copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      child: Text(
        action!.label,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildClose(Color foreground) {
    return IconButton(
      onPressed: onDismiss,
      icon: const Icon(DsIcons.close),
      iconSize: 18,
      color: foreground,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: EdgeInsets.zero,
      tooltip: 'Dismiss',
    );
  }
}
