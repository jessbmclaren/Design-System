import 'package:flutter/material.dart';
import '../../tokens/ds_icons.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';
import '../../tokens/ds_spacing.dart';
import '../atoms/ds_button.dart';

/// An onboarding coachmark: a small spotlight callout that points a first-time
/// user at one thing and moves them through a short guided sequence.
///
/// A coachmark is a compact elevated card (capped at roughly 320dp wide) that
/// carries a [title], an optional supporting [body], an optional set of step
/// dots ([stepIndex] of [stepCount]) and up to two actions. Use the primary
/// action for the step's forward move ("Next", "Got it") and the secondary
/// action for the escape hatch ("Skip", "Back"). Provide [onDismiss] to show a
/// close affordance in the header.
///
/// This widget renders the card only; it does not position itself over a target
/// or draw a spotlight. Place it inside your own overlay, popover or
/// positioned layout. It starts no timers and runs no animation, so it is safe
/// to screenshot the moment it is built.
///
/// ## Responsiveness
///
/// The card shrinks to the available width and never exceeds
/// [maxWidth] (~320dp), so it fits comfortably from a 320dp phone up to a large
/// desktop. The footer keeps the step dots and the actions on one row when
/// there is room and wraps the actions below the dots when space is tight, so
/// it never overflows.
///
/// ## Accessibility
///
/// The card is exposed as a single semantic container. The close control has a
/// tooltip and a >=48dp touch target, and the actions inherit [DsButton]'s
/// button semantics and touch sizing.
///
/// ```dart
/// DsCoachmark(
///   title: 'Filter your results',
///   body: 'Narrow the list to just what you need before you export.',
///   stepIndex: 0,
///   stepCount: 3,
///   primaryActionLabel: 'Next',
///   onPrimary: _goToNextStep,
///   secondaryActionLabel: 'Skip',
///   onSecondary: _dismissTour,
///   onDismiss: _dismissTour,
/// )
/// ```
class DsCoachmark extends StatelessWidget {
  /// Creates an onboarding coachmark card.
  const DsCoachmark({
    super.key,
    required this.title,
    this.body,
    this.primaryActionLabel,
    this.onPrimary,
    this.secondaryActionLabel,
    this.onSecondary,
    this.onDismiss,
    this.stepIndex,
    this.stepCount,
    this.maxWidth = 320,
  });

  /// The headline. Rendered with the `headingSm` ramp step.
  final String title;

  /// Optional supporting copy shown under the [title].
  final String? body;

  /// The label of the primary (forward) action. When null, or when [onPrimary]
  /// is null, the primary button is hidden.
  final String? primaryActionLabel;

  /// Called when the primary action is tapped.
  final VoidCallback? onPrimary;

  /// The label of the secondary (supporting) action. When null, or when
  /// [onSecondary] is null, the secondary button is hidden.
  final String? secondaryActionLabel;

  /// Called when the secondary action is tapped.
  final VoidCallback? onSecondary;

  /// Called when the header close control is tapped. When null, no close
  /// control is shown.
  final VoidCallback? onDismiss;

  /// The zero-based index of the current step. When both [stepIndex] and
  /// [stepCount] are provided (and [stepCount] is greater than one), a row of
  /// progress dots is shown in the footer.
  final int? stepIndex;

  /// The total number of steps in the sequence.
  final int? stepCount;

  /// The maximum width of the card. Defaults to 320dp; the card shrinks below
  /// this on narrower viewports.
  final double maxWidth;

  bool get _showDots {
    final count = stepCount;
    final index = stepIndex;
    return count != null && count > 1 && index != null;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    final hasPrimary = primaryActionLabel != null && onPrimary != null;
    final hasSecondary = secondaryActionLabel != null && onSecondary != null;
    final hasActions = hasPrimary || hasSecondary;

    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            // Keep the title clear of the close control's touch target.
            padding: EdgeInsets.only(top: onDismiss != null ? DsSpacing.sm : 0),
            child: Text(
              title,
              style: tokens.headingSm.toTextStyle(color: tokens.colorText),
            ),
          ),
        ),
        if (onDismiss != null)
          Padding(
            padding: const EdgeInsets.only(left: DsSpacing.sm),
            child: _CloseButton(
              onPressed: onDismiss!,
              color: tokens.colorSecondaryText,
            ),
          ),
      ],
    );

    final footer = _Footer(
      showDots: _showDots,
      stepIndex: stepIndex ?? 0,
      stepCount: stepCount ?? 0,
      filledColor: tokens.buttonPrimaryColorBackground,
      emptyColor: tokens.colorBorder,
      hasPrimary: hasPrimary,
      hasSecondary: hasSecondary,
      primaryActionLabel: primaryActionLabel ?? '',
      secondaryActionLabel: secondaryActionLabel ?? '',
      onPrimary: onPrimary,
      onSecondary: onSecondary,
    );

    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.formBackgroundColor,
        borderRadius: BorderRadius.circular(tokens.overlayBorderRadius),
        border: Border.all(color: tokens.colorBorder),
        boxShadow: tokens.shadowHigh,
      ),
      child: Padding(
        padding: const EdgeInsets.all(DsSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            if (body != null) ...[
              const SizedBox(height: DsSpacing.sm),
              Text(
                body!,
                style: tokens.bodySm
                    .toTextStyle(color: tokens.colorSecondaryText),
              ),
            ],
            if (_showDots || hasActions) ...[
              const SizedBox(height: DsSpacing.lg),
              footer,
            ],
          ],
        ),
      ),
    );

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: _showDots
          ? 'Step ${(stepIndex ?? 0) + 1} of $stepCount'
          : null,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: card,
      ),
    );
  }
}

/// The footer row: step dots on the left, actions on the right. Wraps the
/// actions below the dots when the width is too small to keep them on one line.
class _Footer extends StatelessWidget {
  const _Footer({
    required this.showDots,
    required this.stepIndex,
    required this.stepCount,
    required this.filledColor,
    required this.emptyColor,
    required this.hasPrimary,
    required this.hasSecondary,
    required this.primaryActionLabel,
    required this.secondaryActionLabel,
    required this.onPrimary,
    required this.onSecondary,
  });

  final bool showDots;
  final int stepIndex;
  final int stepCount;
  final Color filledColor;
  final Color emptyColor;
  final bool hasPrimary;
  final bool hasSecondary;
  final String primaryActionLabel;
  final String secondaryActionLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final dots = showDots
        ? _StepDots(
            index: stepIndex,
            count: stepCount,
            filledColor: filledColor,
            emptyColor: emptyColor,
          )
        : null;

    final actions = (hasPrimary || hasSecondary)
        ? Wrap(
            spacing: DsSpacing.sm,
            runSpacing: DsSpacing.sm,
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (hasSecondary)
                DsButton(
                  label: secondaryActionLabel,
                  onPressed: onSecondary,
                  variant: DsButtonVariant.secondary,
                ),
              if (hasPrimary)
                DsButton(
                  label: primaryActionLabel,
                  onPressed: onPrimary,
                ),
            ],
          )
        : null;

    if (dots == null && actions == null) {
      return const SizedBox.shrink();
    }
    if (actions == null) {
      return Align(alignment: Alignment.centerLeft, child: dots);
    }
    if (dots == null) {
      return actions;
    }

    // Both present: keep them on one row when it fits, otherwise stack the
    // actions under the dots so nothing overflows at narrow widths.
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        // A comfortable threshold below which a single row would crowd.
        final stack = width < 260;
        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(alignment: Alignment.centerLeft, child: dots),
              const SizedBox(height: DsSpacing.md),
              actions,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            dots,
            const SizedBox(width: DsSpacing.md),
            Expanded(child: actions),
          ],
        );
      },
    );
  }
}

/// A row of progress dots: filled up to and including [index], empty after.
class _StepDots extends StatelessWidget {
  const _StepDots({
    required this.index,
    required this.count,
    required this.filledColor,
    required this.emptyColor,
  });

  final int index;
  final int count;
  final Color filledColor;
  final Color emptyColor;

  @override
  Widget build(BuildContext context) {
    const dotSize = 8.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          Padding(
            padding: EdgeInsets.only(right: i == count - 1 ? 0 : DsSpacing.xs),
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: i <= index ? filledColor : emptyColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}

/// An icon-only close control with a tooltip and a >=48dp touch target.
class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.onPressed, required this.color});

  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Dismiss',
      child: Tooltip(
        message: 'Dismiss',
        child: InkResponse(
          onTap: onPressed,
          radius: 24,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
            child: Center(
              child: Icon(
                DsIcons.close,
                size: DsIconSize.md,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
