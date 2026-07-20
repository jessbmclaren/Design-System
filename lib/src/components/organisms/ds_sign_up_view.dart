import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_breakpoints.dart';
import '../../tokens/ds_icons.dart';
import '../atoms/ds_box.dart';
import '../atoms/ds_button.dart';
import '../atoms/ds_heading_alignment.dart';
import '../atoms/ds_icon_button.dart';
import 'ds_auth_card_parts.dart';

/// A centred sign-up screen scaffold.
///
/// [DsSignUpView] frames account creation as a focused card: an optional brand
/// glyph, a [title], a supporting [description], a caller-supplied [form]
/// (typically a `DsFormFieldGroup` or a column of `DsTextField`s), a full-width
/// primary [DsButton] built from [primaryActionLabel] and [onSubmit], plus an
/// optional [footer] for secondary links (such as an "Already have an account?"
/// prompt).
///
/// For a brand-led card, pass a [header] (typically a `DsWordmark`) in place
/// of the glyph, centre the heading block with [headingAlignment], slot a
/// sign-in prompt into [aboveForm] and add a corner close button with
/// [onClose]. Set [showBorder] to false for a shadow-only card.
///
/// The view composes existing Design System components rather than
/// re-implementing fields or buttons. The caller owns the form's contents and
/// validation, while this scaffold owns the surrounding layout, spacing and
/// responsive behaviour. It collects no credentials of its own: [onSubmit] is
/// expected to validate the caller's [form] and navigate the user onward.
///
/// ## Responsiveness
///
/// When no [aside] is supplied the card is constrained to a comfortable
/// reading width ([DsAuthCardLayout.signUpMaxWidth]) and centred; it shrinks
/// to fit narrower viewports so it never overflows on a 320dp phone.
///
/// When an [aside] (an optional marketing or benefits panel) is supplied, wide
/// viewports (at or above the [DsBreakpoints.expanded] breakpoint) lay the form
/// card and the aside out side by side in a two-column row capped at
/// [DsBreakpoints.contentMaxWidth], with the aside taking roughly 40% of the
/// width inside a tinted [DsBox]. Below that breakpoint the columns stack: the
/// card is shown first, with the aside beneath it, so nothing is lost on small
/// screens.
///
/// {@tool snippet}
///
/// ```dart
/// DsSignUpView(
///   brandIcon: DsIcons.workspace,
///   title: 'Create your workspace',
///   description: 'Start your 14-day trial. No card required.',
///   form: DsFormFieldGroup(children: [/* DsTextFields */]),
///   primaryActionLabel: 'Create account',
///   onSubmit: _handleSubmit,
///   footer: Row(/* Already have an account? Sign in */),
/// )
/// ```
///
/// {@end-tool}
class DsSignUpView extends StatelessWidget {
  /// Creates a centred sign-up screen scaffold.
  const DsSignUpView({
    super.key,
    required this.title,
    required this.form,
    required this.primaryActionLabel,
    required this.onSubmit,
    this.description,
    this.brandIcon,
    this.brandColor,
    this.header,
    this.headingAlignment = DsHeadingAlignment.start,
    this.aboveForm,
    this.submitPending = false,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.footer,
    this.aside,
    this.onClose,
    this.showBorder = true,
    this.embedded = false,
  });

  /// The prominent heading, typically a short "Create your account" message.
  final String title;

  /// Optional supporting copy shown beneath the [title].
  final String? description;

  /// An optional brand glyph shown in a tinted rounded square above the title.
  final IconData? brandIcon;

  /// The tint used for the brand glyph's container. Defaults to the primary
  /// button background token when omitted.
  final Color? brandColor;

  /// An optional brand header (typically a `DsWordmark`) rendered above the
  /// [title]. When set it replaces the [brandIcon] treatment.
  final Widget? header;

  /// How the heading block (the [header] or [brandIcon], the [title] and the
  /// [description]) is aligned. Defaults to [DsHeadingAlignment.start].
  final DsHeadingAlignment headingAlignment;

  /// Optional content rendered between the [description] and the [form], such
  /// as an "Already have an account?" prompt.
  final Widget? aboveForm;

  /// The caller-supplied form body, typically a `DsFormFieldGroup` or a column
  /// of `DsTextField`s. The view lays this out between the header and the
  /// primary action but does not own its state or validation.
  final Widget form;

  /// The label rendered on the full-width primary button.
  final String primaryActionLabel;

  /// Called when the primary button is tapped. Pass `null` to disable the
  /// button (for example while the form is invalid). The callback is expected
  /// to validate the [form] and navigate the user onward.
  final VoidCallback? onSubmit;

  /// Whether the primary action is in flight, which shows a spinner and
  /// prevents further taps.
  final bool submitPending;

  /// Optional label for a low-commitment secondary action, rendered as a
  /// full-width secondary [DsButton] directly beneath the primary action (for
  /// example "Launch demo"). When null no secondary button is shown.
  final String? secondaryActionLabel;

  /// Called when the secondary action is tapped. Pass null to disable it.
  final VoidCallback? onSecondaryAction;

  /// Optional content shown below the primary action, such as a sign-in link.
  /// Rendered centred beneath the button.
  final Widget? footer;

  /// An optional marketing or benefits panel shown beside the form on wide
  /// screens and stacked beneath it on compact ones. When omitted the card is
  /// centred on its own.
  final Widget? aside;

  /// Called when the close button in the card's top corner is tapped. When
  /// null no close affordance is shown. While the button is shown the heading
  /// block is inset at its trailing edge so the title never paints beneath it.
  final VoidCallback? onClose;

  /// Whether the card draws a hairline border. Set false for a shadow-only
  /// card.
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final showAsideBeside =
            aside != null && width.isFinite && width >= DsBreakpoints.expanded;
        final content =
            showAsideBeside ? _buildWide(tokens) : _buildStacked(tokens);

        // Embedded: the host frames the page, so hand back just the card.
        if (embedded) return content;

        // Standalone: frame our own page — centred and scrollable for a
        // Scaffold.
        return Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(tokens.spacingUnit * 3),
            child: content,
          ),
        );
      },
    );
  }

  /// Side-by-side layout: the form card and the [aside] share a row capped at
  /// [DsBreakpoints.contentMaxWidth]. The [ConstrainedBox] resolves a finite
  /// width so the [Expanded] children below are safe under
  /// otherwise-unbounded constraints.
  Widget _buildWide(DsTokens tokens) {
    // Top-align the two columns (do NOT use IntrinsicHeight + stretch): the
    // form contains text fields, which cannot report an intrinsic height, so a
    // stretch/intrinsic layout would throw. Each column takes its natural
    // height instead.
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: DsBreakpoints.contentMaxWidth,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: _FormCard(
              title: title,
              description: description,
              brandIcon: brandIcon,
              brandColor: brandColor,
              header: header,
              headingAlignment: headingAlignment,
              aboveForm: aboveForm,
              form: form,
              primaryActionLabel: primaryActionLabel,
              onSubmit: onSubmit,
              submitPending: submitPending,
              secondaryActionLabel: secondaryActionLabel,
              onSecondaryAction: onSecondaryAction,
              footer: footer,
              onClose: onClose,
              showBorder: showBorder,
            ),
          ),
          SizedBox(width: tokens.spacingUnit * 3),
          Expanded(
            flex: 4,
            child: _AsidePanel(child: aside!),
          ),
        ],
      ),
    );
  }

  /// Stacked layout: the card is constrained to a comfortable reading width and
  /// centred. When an [aside] is present it is shown beneath the card so no
  /// content is dropped on compact screens.
  Widget _buildStacked(DsTokens tokens) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: DsAuthCardLayout.signUpMaxWidth,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _FormCard(
            title: title,
            description: description,
            brandIcon: brandIcon,
            brandColor: brandColor,
            header: header,
            headingAlignment: headingAlignment,
            aboveForm: aboveForm,
            form: form,
            primaryActionLabel: primaryActionLabel,
            onSubmit: onSubmit,
            submitPending: submitPending,
            secondaryActionLabel: secondaryActionLabel,
            onSecondaryAction: onSecondaryAction,
            footer: footer,
            onClose: onClose,
            showBorder: showBorder,
          ),
          if (aside != null) ...[
            SizedBox(height: tokens.spacingUnit * 2),
            _AsidePanel(child: aside!),
          ],
        ],
      ),
    );
  }
}

/// The bordered card that frames the sign-up header, form and primary action.
class _FormCard extends StatelessWidget {
  const _FormCard({
    required this.title,
    required this.description,
    required this.brandIcon,
    required this.brandColor,
    required this.header,
    required this.headingAlignment,
    required this.aboveForm,
    required this.form,
    required this.primaryActionLabel,
    required this.onSubmit,
    required this.submitPending,
    required this.secondaryActionLabel,
    required this.onSecondaryAction,
    required this.footer,
    required this.onClose,
    required this.showBorder,
  });

  final String title;
  final String? description;
  final IconData? brandIcon;
  final Color? brandColor;
  final Widget? header;
  final DsHeadingAlignment headingAlignment;
  final Widget? aboveForm;
  final Widget form;
  final String primaryActionLabel;
  final VoidCallback? onSubmit;
  final bool submitPending;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final Widget? footer;
  final VoidCallback? onClose;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final centred = headingAlignment == DsHeadingAlignment.center;
    final headerAlignment = centred ? Alignment.center : Alignment.centerLeft;
    final textAlign = centred ? TextAlign.center : TextAlign.start;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: tokens.formBackgroundColor,
        border: showBorder ? Border.all(color: tokens.colorBorder) : null,
        borderRadius: BorderRadius.circular(tokens.overlayBorderRadius),
        boxShadow: tokens.shadowMedium,
      ),
      // The close affordance sits fully inside the Stack: hit-testing stops at
      // the Stack's bounds, so a control hanging outside the padded body would
      // paint whole but respond only in part.
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(tokens.spacingUnit * 3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // While a close button floats in the corner the heading block
                // gives up its trailing edge to it, so title and description
                // glyphs never paint beneath the icon.
                Padding(
                  padding: EdgeInsets.only(
                    right: onClose != null
                        ? DsAuthCardLayout.headingCloseInset(tokens)
                        : 0,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (header != null) ...[
                        Align(alignment: headerAlignment, child: header),
                        SizedBox(height: tokens.spacingUnit * 2),
                      ] else if (brandIcon != null) ...[
                        DsAuthBrandMark(
                          icon: brandIcon!,
                          color: brandColor ??
                              tokens.buttonPrimaryColorBackground,
                          alignment: headerAlignment,
                        ),
                        SizedBox(height: tokens.spacingUnit * 2),
                      ],
                      Semantics(
                        header: true,
                        child: Text(
                          title,
                          textAlign: textAlign,
                          style: tokens.headingLg
                              .toTextStyle(color: tokens.colorText),
                        ),
                      ),
                      if (description != null) ...[
                        SizedBox(height: tokens.spacingUnit),
                        Text(
                          description!,
                          textAlign: textAlign,
                          style: tokens.bodySm.toTextStyle(
                            color: tokens.colorSecondaryText,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (aboveForm != null) ...[
                  SizedBox(height: tokens.spacingUnit),
                  aboveForm!,
                ],
                SizedBox(height: tokens.spacingUnit * 3),
                form,
                SizedBox(height: tokens.spacingUnit * 3),
                DsButton(
                  label: primaryActionLabel,
                  onPressed: onSubmit,
                  pending: submitPending,
                  fullWidth: true,
                ),
                if (secondaryActionLabel != null) ...[
                  SizedBox(height: tokens.spacingUnit),
                  DsButton(
                    label: secondaryActionLabel!,
                    onPressed: onSecondaryAction,
                    variant: DsButtonVariant.secondary,
                    fullWidth: true,
                  ),
                ],
                if (footer != null) ...[
                  SizedBox(height: tokens.spacingUnit * 2),
                  Align(alignment: Alignment.center, child: footer),
                ],
              ],
            ),
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
    );
  }
}

/// The tinted panel that hosts an optional marketing or benefits [aside].
class _AsidePanel extends StatelessWidget {
  const _AsidePanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    return DsBox(
      width: double.infinity,
      padding: EdgeInsets.all(tokens.spacingUnit * 3),
      background: tokens.offsetBackgroundColor,
      borderColor: tokens.colorBorder,
      borderRadius: tokens.overlayBorderRadius,
      alignment: Alignment.centerLeft,
      child: child,
    );
  }
}
