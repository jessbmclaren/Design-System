import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
// DsHeadingAlignment is the shared alignment vocabulary already exported from
// the package barrel; reuse it rather than minting a near-duplicate enum.
import 'ds_heading_alignment.dart';

/// The type-ramp size a [DsStepHeader] renders at.
enum DsStepHeaderSize {
  /// A compact header for a step inside a dense card. Uses `headingMd`.
  small,

  /// The default header for a full-screen step. Uses `headingLg`.
  medium,

  /// A hero header for the opening step of a flow. Uses `headingXl`.
  large,
}

/// The heading block at the top of a wizard or onboarding step.
///
/// [DsStepHeader] pairs a [title] with an optional [lead] paragraph that sets
/// up the step's single question or task. The title takes its size and weight
/// from the type ramp token selected by [size], and the lead renders in the
/// secondary text colour so the question stays the loudest thing on screen.
///
/// With [inlineLead] the lead continues the title's own paragraph in a lighter
/// weight, so the pair reads as one flowing sentence: a bold question followed
/// by a muted why. That is the house style for onboarding steps. The default
/// keeps the lead as its own paragraph beneath the title, which suits longer
/// supporting copy.
///
/// [alignment] mirrors the heading alignment used by the auth views, so a
/// step header lines up with a `DsSignUpView` or `DsSignInView` on an
/// adjacent screen.
///
/// The header is static text: it wraps rather than clipping, holds no state
/// and runs no animations, so it is safe in goldens and screenshots.
///
/// ```dart
/// const DsStepHeader(
///   title: 'Describe your business in a few words.',
///   lead: 'This helps us recommend the best setup.',
///   inlineLead: true,
/// )
/// ```
class DsStepHeader extends StatelessWidget {
  /// Creates a step heading block.
  const DsStepHeader({
    super.key,
    required this.title,
    this.lead,
    this.size = DsStepHeaderSize.medium,
    this.alignment = DsHeadingAlignment.start,
    this.inlineLead = false,
  });

  /// The step's question or task, kept to one sentence.
  final String title;

  /// An optional paragraph explaining why the step matters.
  ///
  /// Renders in the secondary text colour, either beneath the title or, with
  /// [inlineLead], flowing on from it in the same paragraph.
  final String? lead;

  /// The type-ramp size of the title. Defaults to [DsStepHeaderSize.medium].
  final DsStepHeaderSize size;

  /// How the block is aligned. Defaults to [DsHeadingAlignment.start].
  final DsHeadingAlignment alignment;

  /// Whether the [lead] continues the title's paragraph rather than starting
  /// its own.
  ///
  /// When true the lead shares the title's size and line height but drops to
  /// the body weight and the secondary text colour, so the two read as one
  /// sentence pair. Defaults to false.
  final bool inlineLead;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final titleToken = switch (size) {
      DsStepHeaderSize.small => tokens.headingMd,
      DsStepHeaderSize.medium => tokens.headingLg,
      DsStepHeaderSize.large => tokens.headingXl,
    };
    final leadToken = switch (size) {
      DsStepHeaderSize.small => tokens.bodySm,
      _ => tokens.bodyMd,
    };

    final centred = alignment == DsHeadingAlignment.center;
    final textAlign = centred ? TextAlign.center : TextAlign.start;
    final titleStyle = titleToken.toTextStyle(color: tokens.colorText);

    if (inlineLead && lead != null) {
      // One flowing paragraph: the bold title followed by the muted lead at
      // the same size, the onboarding step style.
      return Semantics(
        header: true,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: title, style: titleStyle),
              TextSpan(
                text: ' ${lead!}',
                style: titleToken.toTextStyle(
                  color: tokens.colorSecondaryText,
                ).copyWith(fontWeight: leadToken.fontWeight),
              ),
            ],
          ),
          textAlign: textAlign,
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          centred ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: titleStyle, textAlign: textAlign),
        ),
        if (lead != null) ...[
          SizedBox(height: tokens.spacingUnit),
          Text(
            lead!,
            style: leadToken.toTextStyle(color: tokens.colorSecondaryText),
            textAlign: textAlign,
          ),
        ],
      ],
    );
  }
}
