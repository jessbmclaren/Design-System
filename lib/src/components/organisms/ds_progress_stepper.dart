import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_breakpoints.dart';
import '../../tokens/ds_spacing.dart';

/// A single step within a [DsProgressStepper].
///
/// A step carries only a human-readable [label]; the stepper derives each
/// step's visual state (completed, current or upcoming) from its position
/// relative to [DsProgressStepper.currentIndex].
@immutable
class DsStep {
  /// Creates a step described by [label].
  const DsStep({required this.label});

  /// The short, human-readable name of the step, shown beneath (or beside, in
  /// the compact form) its circle.
  final String label;
}

/// A horizontal progress stepper for guiding users through a multi-step task.
///
/// Renders a numbered circle for each of [steps], connected by thin lines.
/// Each step is drawn in one of three states, derived from [currentIndex]:
///
/// * **completed** (`index < currentIndex`) — a filled circle with a check mark.
/// * **current** (`index == currentIndex`) — a filled circle with the step
///   number, and its label emphasized.
/// * **upcoming** (`index > currentIndex`) — an outlined circle with the step
///   number in muted text.
///
/// Use this when a task has a small, fixed number of ordered stages (checkout,
/// onboarding, a setup wizard) and you want to communicate both position and
/// remaining work.
///
/// The stepper is responsive. On widths below [DsBreakpoints.medium] it collapses
/// to a compact form — a "Step X of N" summary, the current step's label and a
/// thin progress bar — so it never overflows on narrow (down to 320dp) screens.
/// The full circle-and-connector layout is used on wider screens.
///
/// The widget is purely declarative and renders no animation, so it is safe to
/// capture in screenshots without any additional configuration.
class DsProgressStepper extends StatelessWidget {
  /// Creates a horizontal progress stepper.
  ///
  /// [currentIndex] is clamped into the range of [steps], so callers may pass
  /// [steps]`.length` to indicate that every step is complete.
  const DsProgressStepper({
    super.key,
    required this.steps,
    required this.currentIndex,
  });

  /// The ordered steps to display. Should contain at least one step.
  final List<DsStep> steps;

  /// The zero-based index of the step currently in progress.
  ///
  /// Steps before this index are treated as completed; steps after it as
  /// upcoming. Pass [steps]`.length` to mark all steps complete.
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final total = steps.length;
    final clampedCurrent = total == 0 ? 0 : currentIndex.clamp(0, total);

    return Semantics(
      container: true,
      label: total == 0
          ? null
          : 'Step ${(clampedCurrent + 1).clamp(1, total)} of $total',
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (total == 0) return const SizedBox.shrink();
          // Resolve a finite width so the flex children below never receive
          // unbounded constraints (which would throw a RenderFlex assertion
          // under a horizontal scroll view or an unconstrained Row).
          final width = constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width;
          final compact = width < DsBreakpoints.medium;
          return SizedBox(
            width: width,
            child: compact
                ? _buildCompact(context, tokens, clampedCurrent, total)
                : _buildFull(context, tokens, clampedCurrent, total),
          );
        },
      ),
    );
  }

  Widget _buildFull(
    BuildContext context,
    DsTokens tokens,
    int current,
    int total,
  ) {
    final children = <Widget>[];
    for (var i = 0; i < total; i++) {
      children.add(
        Flexible(
          child: _StepMarker(
            tokens: tokens,
            index: i,
            current: current,
            label: steps[i].label,
          ),
        ),
      );
      if (i < total - 1) {
        final connectorComplete = i < current;
        children.add(
          Expanded(
            child: Padding(
              // Align the connector with the vertical center of the circles.
              padding: const EdgeInsets.only(
                top: _circleSize / 2,
                left: DsSpacing.xs,
                right: DsSpacing.xs,
              ),
              child: Container(
                height: 1,
                color: connectorComplete
                    ? tokens.buttonPrimaryColorBackground
                    : tokens.colorBorder,
              ),
            ),
          ),
        );
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _buildCompact(
    BuildContext context,
    DsTokens tokens,
    int current,
    int total,
  ) {
    // In the compact form there is no "current" step once every step is
    // complete; fall back to the last step's label for context.
    final displayIndex = current >= total ? total - 1 : current;
    final progress = total == 0 ? 0.0 : (current / total).clamp(0.0, 1.0);
    final stepNumber = (current + 1).clamp(1, total);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              'Step $stepNumber of $total',
              style: tokens.labelSm.toTextStyle(
                color: tokens.colorSecondaryText,
              ),
            ),
            const SizedBox(width: DsSpacing.sm),
            Expanded(
              child: Text(
                steps[displayIndex].label,
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                style: tokens.labelSm
                    .toTextStyle(color: tokens.colorText)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: DsSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: tokens.colorBorder,
            valueColor: AlwaysStoppedAnimation<Color>(
              tokens.buttonPrimaryColorBackground,
            ),
          ),
        ),
      ],
    );
  }
}

/// Diameter of a step circle in the full layout.
const double _circleSize = 28;

/// A single numbered circle plus its label, used by the full layout.
class _StepMarker extends StatelessWidget {
  const _StepMarker({
    required this.tokens,
    required this.index,
    required this.current,
    required this.label,
  });

  final DsTokens tokens;
  final int index;
  final int current;
  final String label;

  @override
  Widget build(BuildContext context) {
    final completed = index < current;
    final isCurrent = index == current;

    final Color background;
    final Color borderColor;
    final Widget marker;
    if (completed) {
      background = tokens.buttonPrimaryColorBackground;
      borderColor = tokens.buttonPrimaryColorBackground;
      marker = Icon(
        Icons.check,
        size: 16,
        color: tokens.buttonPrimaryColorText,
      );
    } else if (isCurrent) {
      background = tokens.buttonPrimaryColorBackground;
      borderColor = tokens.buttonPrimaryColorBackground;
      marker = Text(
        '${index + 1}',
        style: tokens.labelSm
            .toTextStyle(color: tokens.buttonPrimaryColorText)
            .copyWith(fontWeight: FontWeight.w600),
      );
    } else {
      background = tokens.formBackgroundColor;
      borderColor = tokens.colorBorder;
      marker = Text(
        '${index + 1}',
        style: tokens.labelSm.toTextStyle(
          color: tokens.colorSecondaryText,
        ),
      );
    }

    final labelColor =
        isCurrent ? tokens.colorText : tokens.colorSecondaryText;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: _circleSize,
          height: _circleSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: background,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor),
          ),
          child: marker,
        ),
        const SizedBox(height: DsSpacing.xs),
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: tokens.labelSm.toTextStyle(color: labelColor).copyWith(
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w400,
              ),
        ),
      ],
    );
  }
}
