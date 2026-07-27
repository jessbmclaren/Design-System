import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icons.dart';
import '../atoms/ds_button.dart';
import '../atoms/ds_icon_button.dart';
import '../atoms/ds_link.dart';

/// A compact "verify your email" card, usually shown over a dimmed page in a
/// [DsTakeover] as a reminder rather than a hard gate.
///
/// The card holds two states in one surface, and the caller owns which is
/// shown through [verified]:
///
/// * **Check your inbox** ([verified] is false): a heading, a line pointing the
///   user at their inbox with their [email] emphasised, and a secondary resend
///   action. An optional change-email link ([onChangeEmail]) sits beside the
///   resend for the person who mistyped their address, and an optional close
///   affordance dismisses the reminder without verifying.
/// * **Email verified** ([verified] is true): a confirmation heading, a line
///   reading back the verified [email], and a primary continue action. The
///   corner close, when shown, completes rather than dismisses, so closing a
///   verified card never throws the confirmation away.
///
/// The card is controlled and runs no timers: it never flips itself from the
/// inbox state to the verified state. The caller verifies the email in its own
/// state (a real inbox round-trip, or a simulated delay in a demo) and rebuilds
/// with `verified: true`. While a resend is in flight, pass
/// [resendPending] to show the busy state on the resend action.
///
/// When [verified] flips true the confirmation heading is announced as a live
/// region, so a screen-reader user hears the outcome rather than being left on
/// the inbox copy.
///
/// All copy defaults to brand-neutral English and every label is a parameter,
/// so a product supplies its own wording without forking the card.
class DsVerifyEmailCard extends StatelessWidget {
  /// Creates a verify-email card.
  const DsVerifyEmailCard({
    super.key,
    required this.email,
    this.verified = false,
    this.onContinue,
    this.onResend,
    this.resendPending = false,
    this.onChangeEmail,
    this.onClose,
    this.title = 'Verify your email',
    this.verifiedTitle = 'Email verified',
    this.resendLabel = 'Resend email',
    this.changeEmailLabel = 'Wrong email? Change it',
    this.continueLabel = 'Continue',
    this.closeSemanticLabel = 'Close',
    this.maxWidth = 460,
  });

  /// The address the verification link was sent to, emphasised in the body
  /// copy. When blank the copy falls back to a neutral "your email".
  final String email;

  /// Whether the email has been verified. The caller owns this: while false
  /// the card shows the check-your-inbox state, and once true it shows the
  /// confirmation. Defaults to false.
  final bool verified;

  /// Called from the primary continue action in the verified state, and from
  /// the corner close while verified (closing a verified card completes it). A
  /// null callback drops the continue action from the focus order.
  final VoidCallback? onContinue;

  /// Called from the resend action in the inbox state. A null callback drops
  /// the resend action from the focus order.
  final VoidCallback? onResend;

  /// Whether a resend is in flight, shown as the busy state on the resend
  /// action. Defaults to false.
  final bool resendPending;

  /// Called from the change-email link in the inbox state — the doorway for a
  /// mistyped address, so a wrong email is a correction rather than a dead
  /// account. When null (the default) the link is not shown. The verified
  /// state never shows it: a verified address is not in doubt.
  final VoidCallback? onChangeEmail;

  /// Called from the corner close in the inbox state, dismissing the reminder
  /// without verifying. When null (the default) the inbox state shows no close
  /// affordance; the verified state still shows one, routed to [onContinue].
  final VoidCallback? onClose;

  /// The heading for the check-your-inbox state. Defaults to
  /// `'Verify your email'`.
  final String title;

  /// The heading for the verified state. Defaults to `'Email verified'`.
  final String verifiedTitle;

  /// The label of the resend action. Defaults to `'Resend email'`.
  final String resendLabel;

  /// The label of the change-email link. Defaults to
  /// `'Wrong email? Change it'`.
  final String changeEmailLabel;

  /// The label of the continue action. Defaults to `'Continue'`.
  final String continueLabel;

  /// The accessible label of the corner close affordance. Defaults to
  /// `'Close'`.
  final String closeSemanticLabel;

  /// The card's maximum width in logical pixels. Defaults to 460.
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final unit = tokens.spacingUnit;
    final address = email.trim().isEmpty ? 'your email' : email.trim();

    // The corner close completes a verified card and dismisses an unverified
    // one; it is only shown when the action it maps to exists, so it is never
    // a dead control.
    final VoidCallback? closeAction = verified ? onContinue : onClose;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        decoration: BoxDecoration(
          color: tokens.formBackgroundColor,
          borderRadius: BorderRadius.circular(tokens.overlayBorderRadius),
          boxShadow: tokens.shadowMedium,
        ),
        padding: EdgeInsets.all(unit * 3),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Semantics(
                    header: true,
                    // Announce the outcome when the card flips to verified,
                    // rather than leaving the user on the inbox copy.
                    liveRegion: verified,
                    child: Text(
                      verified ? verifiedTitle : title,
                      style: tokens.headingSm.toTextStyle(
                        color: tokens.colorText,
                      ),
                    ),
                  ),
                ),
                if (closeAction != null)
                  DsIconButton(
                    icon: DsIcons.close,
                    semanticLabel: closeSemanticLabel,
                    onPressed: closeAction,
                  ),
              ],
            ),
            SizedBox(height: unit * 1.5),
            Text.rich(
              _bodySpan(tokens, address),
              style: tokens.bodyMd.toTextStyle(
                color: tokens.colorSecondaryText,
              ),
            ),
            SizedBox(height: unit * 3),
            Align(
              alignment: Alignment.centerRight,
              child: verified
                  ? DsButton(
                      label: continueLabel,
                      onPressed: onContinue,
                    )
                  : DsButton(
                      label: resendLabel,
                      variant: DsButtonVariant.secondary,
                      pending: resendPending,
                      onPressed: onResend,
                    ),
            ),
            // The mistyped-address doorway is the quiet aside beneath the
            // resend action — its own line, so neither crowds the other at
            // narrow widths.
            if (!verified && onChangeEmail != null) ...<Widget>[
              SizedBox(height: unit * 1.5),
              Align(
                alignment: Alignment.centerLeft,
                child: DsLink(
                  label: changeEmailLabel,
                  small: true,
                  onPressed: onChangeEmail,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// The body copy with [address] emphasised in the primary text colour: an
  /// inbox instruction while unverified, a read-back confirmation once
  /// verified. A blank address reads back without stitching the fallback noun
  /// into the sentence.
  TextSpan _bodySpan(DsTokens tokens, String address) {
    final emphasis = TextStyle(
      color: tokens.colorText,
      fontWeight: tokens.strongLabelFontWeight,
    );
    final blank = email.trim().isEmpty;
    if (verified) {
      // "Your email <addr> has been verified." collapses to a natural
      // "Your email has been verified." when there is no address to name,
      // rather than "Your email your email has been verified.".
      if (blank) return const TextSpan(text: 'Your email has been verified.');
      return TextSpan(
        children: <InlineSpan>[
          const TextSpan(text: 'Your email '),
          TextSpan(text: _breakable(address), style: emphasis),
          const TextSpan(text: ' has been verified.'),
        ],
      );
    }
    return TextSpan(
      children: <InlineSpan>[
        const TextSpan(text: 'Check '),
        TextSpan(text: _breakable(address), style: emphasis),
        const TextSpan(text: ' for a link to verify your email.'),
      ],
    );
  }

  /// Inserts zero-width break opportunities after an address's segment
  /// delimiters, so an ordinary email (which carries no whitespace or hyphens)
  /// wraps to the next line at a narrow width instead of painting past the
  /// card edge. The visible glyphs are unchanged.
  static String _breakable(String s) {
    const breakAfter = <int>{0x40, 0x2E, 0x2D, 0x5F, 0x2B, 0x2F}; // @ . - _ + /
    final buffer = StringBuffer();
    for (final rune in s.runes) {
      buffer.writeCharCode(rune);
      if (breakAfter.contains(rune)) buffer.write('​');
    }
    return buffer.toString();
  }
}
