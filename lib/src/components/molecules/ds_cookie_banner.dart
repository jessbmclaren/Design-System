import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../atoms/ds_button.dart';

/// The width below which the banner's actions stack as full-width buttons.
const double _stackActionsBelow = 480;

/// The width at or above which the message and the actions share one row.
const double _sideBySideAt = 960;

/// The widest the banner's content grows, so the bar reads as one line of
/// content rather than sprawling across a large desktop.
const double _maxContentWidth = 1120;

/// The site cookie consent bar.
///
/// [DsCookieBanner] is a full-width bar pinned to the bottom of a public
/// page, typically through the `banner` slot of a `DsAuthShell`. It carries a
/// short explanation and the three standard consent actions, all visible at
/// once: accept all cookies, reject the non-essential ones or open the
/// preferences surface (usually a `DsCookiePreferences` hosted in a
/// `DsTakeover`).
///
/// Pass the explanation as a [message] string or as a [messageWidget] when
/// the copy needs inline links. The whole bar is a polite live region, so a
/// screen reader announces the message when the banner first appears without
/// interrupting what the user was doing.
///
/// The component is controlled: it holds no consent state and simply reports
/// the choice through its callbacks. A null callback disables that action.
///
/// The banner measures its own width. When the bar is wide the message and
/// the actions share a row; on middling widths the actions drop beneath the
/// message; when the bar itself is narrow the three buttons stack full-width
/// with the primary action first.
///
/// ```dart
/// DsCookieBanner(
///   message: 'We use cookies to keep your account secure and to '
///       'understand how the product is used.',
///   onAcceptAll: _acceptAll,
///   onRejectNonEssential: _rejectNonEssential,
///   onManagePreferences: _openPreferences,
/// )
/// ```
class DsCookieBanner extends StatelessWidget {
  /// Creates the cookie consent bar.
  ///
  /// Provide exactly one of [message] and [messageWidget].
  const DsCookieBanner({
    super.key,
    this.message,
    this.messageWidget,
    this.onAcceptAll,
    this.onRejectNonEssential,
    this.onManagePreferences,
    this.acceptAllLabel = 'Accept all',
    this.rejectLabel = 'Reject non-essential',
    this.preferencesLabel = 'Manage preferences',
  }) : assert(
          (message == null) != (messageWidget == null),
          'Provide exactly one of message or messageWidget.',
        );

  /// The consent explanation, set in the theme's small body style. Ignored
  /// when [messageWidget] is provided.
  final String? message;

  /// A widget alternative to [message], for copy that carries inline links.
  final Widget? messageWidget;

  /// Called when the user accepts every cookie category. A null callback
  /// disables the button.
  final VoidCallback? onAcceptAll;

  /// Called when the user rejects every non-essential category. A null
  /// callback disables the button.
  final VoidCallback? onRejectNonEssential;

  /// Called when the user asks to manage individual categories. A null
  /// callback disables the button.
  final VoidCallback? onManagePreferences;

  /// The label of the primary accept action.
  final String acceptAllLabel;

  /// The label of the reject action.
  final String rejectLabel;

  /// The label of the quiet preferences action.
  final String preferencesLabel;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final unit = tokens.spacingUnit;

    final Widget messageContent = messageWidget ??
        Text(
          message!,
          style: tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText),
        );

    Widget actions({required bool stacked, required bool alignEnd}) {
      final preferences = DsButton(
        label: preferencesLabel,
        onPressed: onManagePreferences,
        variant: DsButtonVariant.tertiary,
        fullWidth: stacked,
      );
      final reject = DsButton(
        label: rejectLabel,
        onPressed: onRejectNonEssential,
        variant: DsButtonVariant.secondary,
        fullWidth: stacked,
      );
      final accept = DsButton(
        label: acceptAllLabel,
        onPressed: onAcceptAll,
        fullWidth: stacked,
      );
      if (stacked) {
        // Stacked keeps the primary action first, the standard mobile
        // ordering, with the quiet preferences action last.
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            accept,
            SizedBox(height: unit),
            reject,
            SizedBox(height: unit),
            preferences,
          ],
        );
      }
      // A wrap rather than a row, so long translated labels flow onto a
      // second line between the thresholds instead of overflowing.
      return Wrap(
        spacing: unit,
        runSpacing: unit,
        alignment: alignEnd ? WrapAlignment.end : WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [preferences, reject, accept],
      );
    }

    return Semantics(
      container: true,
      liveRegion: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: tokens.formBackgroundColor,
          border: Border(top: BorderSide(color: tokens.colorBorder)),
          boxShadow: tokens.shadowMedium,
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: unit * 3,
            vertical: unit * 2,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxContentWidth),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  if (width >= _sideBySideAt) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // The action cluster takes the larger share of the
                        // free space, so the three buttons hold one line and
                        // a long message wraps instead.
                        Flexible(flex: 2, child: messageContent),
                        SizedBox(width: unit * 3),
                        Expanded(
                          flex: 3,
                          child: actions(stacked: false, alignEnd: true),
                        ),
                      ],
                    );
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      messageContent,
                      SizedBox(height: unit * 2),
                      actions(
                        stacked: width < _stackActionsBelow,
                        alignEnd: false,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
