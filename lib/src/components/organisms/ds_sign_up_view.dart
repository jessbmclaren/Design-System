import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_breakpoints.dart';
import '../../tokens/ds_icon_size.dart';
import '../../tokens/ds_icons.dart';
import '../../tokens/ds_spacing.dart';
import '../atoms/ds_box.dart';
import '../atoms/ds_button.dart';
import '../atoms/ds_icon.dart';
import '../atoms/ds_icon_button.dart';

/// How an auth card's heading block is aligned.
///
/// Applies to the title, the description and any brand header above them.
/// Start alignment reads as a conventional form; centred alignment suits a
/// short, focused card such as a one-step sign-up.
enum DsHeadingAlignment {
  /// Align the heading block with the leading edge.
  start,

  /// Centre the heading block.
  center,
}

/// A centred sign-up screen scaffold.
///
/// [DsSignUpView] frames account creation as a focused card: an optional brand
/// glyph, a [title], a supporting [description], a caller-supplied [form]
/// (typically a `DsFormFieldGroup` or a column of `DsTextField`s), a full-width
/// primary [DsButton] built from [primaryActionLabel] / [onSubmit] and an
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
/// When no [aside] is supplied the card is constrained to a comfortable reading
/// width (~440dp) and centred; it shrinks to fit narrower viewports so it never
/// overflows on a 320dp phone.
///
/// When an [aside] (an optional marketing / benefits panel) is supplied, wide
/// viewports (at or above the [DsBreakpoints.expanded] breakpoint) lay the form
/// card and the aside out side by side in a two-column row capped at ~960dp,
/// with the aside taking roughly 40% of the width inside a tinted [DsBox].
/// Below that breakpoint the columns stack: the card is shown first, with the
/// aside beneath it, so nothing is lost on small screens.
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
    this.footer,
    this.aside,
    this.onClose,
    this.showBorder = true,
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

  /// Whether the primary action is in a pending / in-flight state, which shows
  /// a spinner and prevents further taps.
  final bool submitPending;

  /// Optional content shown below the primary action, such as a sign-in link.
  /// Rendered centred beneath the button.
  final Widget? footer;

  /// An optional marketing / benefits panel shown beside the form on wide
  /// screens and stacked beneath it on compact ones. When omitted the card is
  /// centred on its own.
  final Widget? aside;

  /// Called when the close button in the card's top corner is tapped. When
  /// null no close affordance is shown.
  final VoidCallback? onClose;

  /// Whether the card draws a hairline border. Set false for a shadow-only
  /// card.
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final showAsideBeside =
            aside != null && width.isFinite && width >= DsBreakpoints.expanded;

        return Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(DsSpacing.xl),
            child: showAsideBeside
                ? _buildWide(context, tokens)
                : _buildStacked(context, tokens),
          ),
        );
      },
    );
  }

  /// Side-by-side layout: the form card and the [aside] share a row capped at
  /// ~960dp. The [ConstrainedBox] resolves a finite width so the [Expanded]
  /// children below are safe under otherwise-unbounded constraints.
  Widget _buildWide(BuildContext context, DsTokens tokens) {
    // Top-align the two columns (do NOT use IntrinsicHeight + stretch): the
    // form contains text fields, which cannot report an intrinsic height, so a
    // stretch/intrinsic layout would throw. Each column takes its natural
    // height instead.
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 960),
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
              footer: footer,
              onClose: onClose,
              showBorder: showBorder,
            ),
          ),
          const SizedBox(width: DsSpacing.xl),
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
  Widget _buildStacked(BuildContext context, DsTokens tokens) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
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
            footer: footer,
            onClose: onClose,
            showBorder: showBorder,
          ),
          if (aside != null) ...[
            const SizedBox(height: DsSpacing.lg),
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
            padding: const EdgeInsets.all(DsSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (header != null) ...[
                  Align(alignment: headerAlignment, child: header),
                  const SizedBox(height: DsSpacing.lg),
                ] else if (brandIcon != null) ...[
                  _BrandMark(
                    icon: brandIcon!,
                    color: brandColor ?? tokens.buttonPrimaryColorBackground,
                    alignment: headerAlignment,
                  ),
                  const SizedBox(height: DsSpacing.lg),
                ],
                Semantics(
                  header: true,
                  child: Text(
                    title,
                    textAlign: textAlign,
                    style:
                        tokens.headingLg.toTextStyle(color: tokens.colorText),
                  ),
                ),
                if (description != null) ...[
                  const SizedBox(height: DsSpacing.sm),
                  Text(
                    description!,
                    textAlign: textAlign,
                    style: tokens.bodySm.toTextStyle(
                      color: tokens.colorSecondaryText,
                    ),
                  ),
                ],
                if (aboveForm != null) ...[
                  const SizedBox(height: DsSpacing.sm),
                  aboveForm!,
                ],
                const SizedBox(height: DsSpacing.xl),
                form,
                const SizedBox(height: DsSpacing.xl),
                DsButton(
                  label: primaryActionLabel,
                  onPressed: onSubmit,
                  pending: submitPending,
                  fullWidth: true,
                ),
                if (footer != null) ...[
                  const SizedBox(height: DsSpacing.lg),
                  Align(alignment: Alignment.center, child: footer),
                ],
              ],
            ),
          ),
          if (onClose != null)
            Positioned(
              top: DsSpacing.sm,
              right: DsSpacing.sm,
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

/// The tinted panel that hosts an optional marketing / benefits [aside].
class _AsidePanel extends StatelessWidget {
  const _AsidePanel({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    return DsBox(
      width: double.infinity,
      padding: const EdgeInsets.all(DsSpacing.xl),
      background: tokens.offsetBackgroundColor,
      borderColor: tokens.colorBorder,
      borderRadius: tokens.overlayBorderRadius,
      alignment: Alignment.centerLeft,
      child: child,
    );
  }
}

/// The tinted rounded square that frames a brand glyph.
class _BrandMark extends StatelessWidget {
  const _BrandMark({
    required this.icon,
    required this.color,
    required this.alignment,
  });

  final IconData icon;
  final Color color;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return Align(
      alignment: alignment,
      child: Container(
        padding: const EdgeInsets.all(DsSpacing.md),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(tokens.formBorderRadius),
          boxShadow: tokens.shadowMedium,
        ),
        child: DsIcon(
          icon: icon,
          size: DsIconSize.xl,
          color: tokens.buttonPrimaryColorText,
        ),
      ),
    );
  }
}
