import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_breakpoints.dart';
import '../../tokens/ds_spacing.dart';
import '../atoms/ds_box.dart';
import '../atoms/ds_button.dart';

/// A centred sign-up screen scaffold.
///
/// [DsSignUpView] frames account creation as a focused card: an optional brand
/// glyph, a [title], a supporting [description], a caller-supplied [form]
/// (typically a `DsFormFieldGroup` or a column of `DsTextField`s), a full-width
/// primary [DsButton] built from [primaryActionLabel] / [onSubmit] and an
/// optional [footer] for secondary links (such as an "Already have an account?"
/// prompt).
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
    this.submitPending = false,
    this.footer,
    this.aside,
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
              form: form,
              primaryActionLabel: primaryActionLabel,
              onSubmit: onSubmit,
              submitPending: submitPending,
              footer: footer,
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
            form: form,
            primaryActionLabel: primaryActionLabel,
            onSubmit: onSubmit,
            submitPending: submitPending,
            footer: footer,
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
    required this.form,
    required this.primaryActionLabel,
    required this.onSubmit,
    required this.submitPending,
    required this.footer,
  });

  final String title;
  final String? description;
  final IconData? brandIcon;
  final Color? brandColor;
  final Widget form;
  final String primaryActionLabel;
  final VoidCallback? onSubmit;
  final bool submitPending;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DsSpacing.xl),
      decoration: BoxDecoration(
        color: tokens.formBackgroundColor,
        border: Border.all(color: tokens.colorBorder),
        borderRadius: BorderRadius.circular(tokens.overlayBorderRadius),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (brandIcon != null) ...[
            _BrandMark(
              icon: brandIcon!,
              color: brandColor ?? tokens.buttonPrimaryColorBackground,
            ),
            const SizedBox(height: DsSpacing.lg),
          ],
          Semantics(
            header: true,
            child: Text(
              title,
              style: tokens.headingMd.toTextStyle(color: tokens.colorText),
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: DsSpacing.sm),
            Text(
              description!,
              style: tokens.bodySm.toTextStyle(
                color: tokens.colorSecondaryText,
              ),
            ),
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
  const _BrandMark({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(tokens.formBorderRadius),
          border: Border.all(color: color.withValues(alpha: 0.24)),
        ),
        child: Icon(icon, size: 28, color: color),
      ),
    );
  }
}
