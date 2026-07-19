import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../atoms/ds_button.dart';
import '../atoms/ds_heading_alignment.dart';
import '../atoms/ds_icon_button.dart';
import '../../tokens/ds_icons.dart';
import 'ds_auth_card_parts.dart';
import 'ds_sign_in_view.dart' show DsSignInAction;

/// A centred password-recovery card scaffold.
///
/// [DsForgotPasswordView] is the sibling of [DsSignInView] for the "forgot
/// your password" journey. It frames a single step of that journey as a focused
/// card: an optional brand glyph, a [title], a supporting [description] (plain
/// or, for a message that emphasises the address, a [descriptionRich] widget),
/// an optional caller-supplied [form] (typically the email field), a full-width
/// primary [DsButton] built from [primaryAction], and a [footer] for the
/// secondary links the step needs ("Return to sign-in", "Don't know which
/// email?", or a resend control).
///
/// Like the other auth scaffolds it **owns no form state and collects no
/// credentials of its own** — the caller owns the field contents and validation
/// and drives the step. Because the whole recovery flow is one morphing card,
/// the caller renders the request step (title "Reset your password", the email
/// [form], a "Continue" [primaryAction]) and the confirmation step (title
/// "Check your email", no form, a [descriptionRich] that names the address and a
/// resend control in the [footer]) by passing different props to this one view.
///
/// The card is constrained to [DsAuthCardLayout.signInMaxWidth] and shrinks to
/// fit narrower viewports, so it never overflows on small phones.
class DsForgotPasswordView extends StatelessWidget {
  /// Creates a centred password-recovery card.
  const DsForgotPasswordView({
    super.key,
    required this.title,
    this.primaryAction,
    this.description,
    this.descriptionRich,
    this.form,
    this.footer,
    this.brandIcon,
    this.brandColor,
    this.headingAlignment = DsHeadingAlignment.start,
    this.onClose,
    this.showBorder = true,
    this.embedded = false,
  }) : assert(
         description == null || descriptionRich == null,
         'Pass at most one of description or descriptionRich.',
       );

  /// The prominent heading — e.g. "Reset your password" or "Check your email".
  final String title;

  /// The full-width primary action (e.g. "Continue" on the request step).
  ///
  /// Optional, because some steps of a recovery journey deliberately have no
  /// button at all. Once a link is on its way the next move is in the person's
  /// inbox, not on the screen, so the step offers only quiet text links in its
  /// [footer]; a filled button there would compete with the email for the
  /// attention it needs. Omit this and the card renders straight from the body
  /// to the [footer].
  final DsSignInAction? primaryAction;

  /// Optional plain supporting copy shown beneath the [title].
  final String? description;

  /// Optional rich supporting copy, for a message that emphasises part of
  /// itself (such as the address a link was sent to). Mutually exclusive with
  /// [description].
  final Widget? descriptionRich;

  /// An optional form body — typically the email field on the request step.
  /// Rendered between the description and the primary action. The view lays it
  /// out but owns none of its state. Omit it on the confirmation step.
  final Widget? form;

  /// Optional content shown below the primary action: the secondary links
  /// ("Return to sign-in", "Don't know which email?") or a resend control.
  final Widget? footer;

  /// An optional brand glyph shown in a tinted rounded square above the title.
  final IconData? brandIcon;

  /// The tint used for the brand glyph's container. Defaults to the primary
  /// button background token when omitted.
  final Color? brandColor;

  /// How the heading block is aligned. Defaults to [DsHeadingAlignment.start].
  final DsHeadingAlignment headingAlignment;

  /// Called when the corner close button is tapped. When null no close
  /// affordance is shown.
  final VoidCallback? onClose;

  /// Whether the card draws a hairline border. Set false for a shadow-only card.
  final bool showBorder;

  /// Whether the card frames its own page.
  ///
  /// When false (the default) the view centres and scrolls itself, so it can be
  /// dropped straight into a `Scaffold` body. Set it true to render just the
  /// constrained card, for a host that already owns the page framing — a
  /// template that supplies the background, the centring and the scroll (an
  /// auth shell). Nesting a self-framing view inside such a host would scroll
  /// twice; embedded mode is how the same card lives in both places.
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    final card = ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: DsAuthCardLayout.signInMaxWidth,
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: tokens.formBackgroundColor,
          border: showBorder ? Border.all(color: tokens.colorBorder) : null,
          borderRadius: BorderRadius.circular(tokens.overlayBorderRadius),
          boxShadow: tokens.shadowMedium,
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(tokens.spacingUnit * 3),
              child: _buildBody(tokens),
            ),
            if (onClose != null)
              Positioned(
                top: tokens.spacingUnit,
                right: tokens.spacingUnit,
                child: DsIconButton(
                  icon: DsIcons.close,
                  semanticLabel: 'Close',
                  onPressed: onClose,
                ),
              ),
          ],
        ),
      ),
    );

    // Embedded: the host frames the page, so hand back just the card.
    if (embedded) return card;

    // Standalone: frame our own page — centred and scrollable for a Scaffold.
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(tokens.spacingUnit * 3),
        child: card,
      ),
    );
  }

  Widget _buildBody(DsTokens tokens) {
    final centred = headingAlignment == DsHeadingAlignment.center;
    final textAlign = centred ? TextAlign.center : TextAlign.start;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.only(
            right: onClose != null ? DsAuthCardLayout.headingCloseInset(tokens) : 0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (brandIcon != null) ...[
                DsAuthBrandMark(
                  icon: brandIcon!,
                  color: brandColor ?? tokens.buttonPrimaryColorBackground,
                  alignment: centred ? Alignment.center : Alignment.centerLeft,
                ),
                SizedBox(height: tokens.spacingUnit * 2),
              ],
              Semantics(
                header: true,
                child: Text(
                  title,
                  textAlign: textAlign,
                  style: tokens.headingLg.toTextStyle(color: tokens.colorText),
                ),
              ),
              if (description != null) ...[
                SizedBox(height: tokens.spacingUnit),
                Text(
                  description!,
                  textAlign: textAlign,
                  style: tokens.bodyMd.toTextStyle(
                    color: tokens.colorSecondaryText,
                  ),
                ),
              ] else if (descriptionRich != null) ...[
                SizedBox(height: tokens.spacingUnit),
                DefaultTextStyle.merge(
                  textAlign: textAlign,
                  style: tokens.bodyMd.toTextStyle(
                    color: tokens.colorSecondaryText,
                  ),
                  child: descriptionRich!,
                ),
              ],
            ],
          ),
        ),
        SizedBox(height: tokens.spacingUnit * 3),
        if (form != null) ...[
          form!,
          SizedBox(height: tokens.spacingUnit * 3),
        ],
        if (primaryAction case final DsSignInAction action)
          DsButton(
            label: action.label,
            onPressed: action.onPressed,
            pending: action.pending,
            fullWidth: true,
          ),
        if (footer != null) ...[
          // Without a button above it the footer is the step's only action, so
          // it does not need pushing away from one.
          if (primaryAction != null) SizedBox(height: tokens.spacingUnit * 2),
          Align(alignment: Alignment.center, child: footer),
        ],
      ],
    );
  }
}
