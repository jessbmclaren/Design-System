import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../util/ds_motion.dart';
import '../atoms/ds_button.dart';
import '../atoms/ds_progress_bar.dart';

/// One step of a [DsTourCard] walkthrough.
///
/// A step is plain data: a [title], a supporting [body] and an optional
/// [illustration] the card shows in its tinted frame. The design system ships
/// no artwork; the illustration is any widget the caller supplies, from a
/// simple icon to a small animated scene.
@immutable
class DsTourStep {
  /// Creates a tour step described by [title] and [body].
  const DsTourStep({
    required this.title,
    required this.body,
    this.illustration,
    this.illustrationLabel,
  });

  /// The step headline, one short line naming the idea being introduced.
  final String title;

  /// The supporting copy under the [title]. Keep it to a sentence or two.
  final String body;

  /// An optional visual shown in the card's tinted frame above the copy.
  ///
  /// The card draws a token-tinted surface behind it and swaps it with the
  /// step transition. Null leaves the frame empty for this step; when no step
  /// in the tour has an illustration the frame is omitted entirely.
  final Widget? illustration;

  /// A short description of the [illustration] for assistive technology.
  ///
  /// Most tour illustrations restate the copy visually, so the default (null)
  /// treats them as decorative and drops them from the semantics tree. Set a
  /// label only when the illustration carries information the [title] and
  /// [body] do not.
  final String? illustrationLabel;
}

/// A stepped, illustrated walkthrough card.
///
/// [DsTourCard] presents a short product tour as a single standalone card: a
/// tinted frame holding the current step's illustration, the step's title and
/// body, an animated progress bar and Back and Next actions, with Next
/// becoming the finishing action on the last step. Use it right after sign-up
/// or a major release, floated over the page in your own overlay or a
/// `DsTakeover`-style scrim.
///
/// It differs from `DsCoachmark` in scope: a coachmark is a compact callout
/// you anchor to one piece of UI, while the tour card is self-contained and
/// walks through several ideas without pointing at anything.
///
/// The card is controlled. The caller owns [currentStep] and moves it in
/// [onStepChanged]; the card never advances itself. A null [onStepChanged]
/// disables every navigation affordance. [onSkip] shows a skip control above
/// the frame and [onDone] powers the final action.
///
/// ## Responsiveness
///
/// The card shrinks to the available width and never exceeds [maxWidth].
/// Below roughly 440dp of its own width (measured with a `LayoutBuilder`, not
/// the viewport) the footer restacks: the progress bar takes its own line and
/// the actions go full width beneath it, so nothing overflows on a 320dp
/// phone.
///
/// ## Motion
///
/// Step transitions and the progress fill run on the [DsMotion] scale and
/// collapse to a still frame under reduced motion.
///
/// ## Accessibility
///
/// Arrow keys move between steps whenever focus is inside the card, every
/// control is keyboard-activatable with a >=48dp touch target, progress is
/// announced as "Step x of y" on each change and illustrations stay out of
/// the semantics tree unless a step labels them.
///
/// ```dart
/// DsTourCard(
///   steps: const [
///     DsTourStep(title: 'Import your data', body: 'One spreadsheet does it.'),
///     DsTourStep(title: 'Invite your team', body: 'Everyone sees the same picture.'),
///   ],
///   currentStep: step,
///   onStepChanged: (value) => setState(() => step = value),
///   onSkip: _closeTour,
///   onDone: _closeTour,
/// )
/// ```
class DsTourCard extends StatelessWidget {
  /// Creates a tour card over [steps].
  ///
  /// [steps] must not be empty. [currentStep] is clamped into the list's
  /// range for rendering, so a stale index never throws.
  const DsTourCard({
    super.key,
    required this.steps,
    required this.currentStep,
    required this.onStepChanged,
    this.onSkip,
    this.onDone,
    this.backLabel = 'Back',
    this.nextLabel = 'Next',
    this.doneLabel = 'Done',
    this.skipLabel = 'Skip tour',
    this.maxWidth = 560,
    this.illustrationHeight = 180,
    this.enableSwipe = false,
  }) : assert(steps.length > 0, 'DsTourCard needs at least one step');

  /// The width of the card, in logical pixels, below which the footer
  /// restacks: progress bar on its own line, full-width actions beneath.
  static const double _stackBelow = 440;

  /// The steps of the tour, in order. Must not be empty.
  final List<DsTourStep> steps;

  /// The zero-based index of the step being shown. The caller owns it; the
  /// card only renders it. Out-of-range values are clamped.
  final int currentStep;

  /// Called with the new index when the user navigates by button, arrow key
  /// or swipe. Null disables navigation: the actions grey out, arrow keys
  /// fall through to normal focus traversal and swiping does nothing.
  final ValueChanged<int>? onStepChanged;

  /// Called when the skip control is activated. Null hides the control.
  final VoidCallback? onSkip;

  /// Called when the forward action is activated on the last step. Null
  /// disables that final action.
  final VoidCallback? onDone;

  /// The label of the backward action. Hidden on the first step.
  final String backLabel;

  /// The label of the forward action on every step but the last.
  final String nextLabel;

  /// The label of the forward action on the last step ("Done", "Get
  /// started").
  final String doneLabel;

  /// The label of the skip control shown while [onSkip] is set.
  final String skipLabel;

  /// The maximum width of the card. It shrinks below this on narrow parents.
  final double maxWidth;

  /// The height of the illustration frame, in logical pixels. An
  /// illustration taller than this is clipped rather than overflowing.
  final double illustrationHeight;

  /// Whether a horizontal swipe over the card also navigates. Off by
  /// default; buttons and arrow keys always work.
  final bool enableSwipe;

  int get _index => currentStep.clamp(0, steps.length - 1);

  bool get _isLast => _index == steps.length - 1;

  void _move(int delta) {
    final onChanged = onStepChanged;
    if (onChanged == null) return;
    final target = (_index + delta).clamp(0, steps.length - 1);
    if (target != _index) onChanged(target);
  }

  void _handleSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < 0) {
      _move(1);
    } else if (velocity > 0) {
      _move(-1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final step = steps[_index];
    final hasFrame = steps.any((s) => s.illustration != null);
    final canNavigate = onStepChanged != null;

    final card = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: tokens.formBackgroundColor,
        borderRadius: BorderRadius.circular(tokens.overlayBorderRadius),
        border: Border.all(color: tokens.colorBorder),
        boxShadow: tokens.shadowHigh,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasFrame)
            _Frame(
              step: step,
              stepIndex: _index,
              height: illustrationHeight,
              skipLabel: skipLabel,
              onSkip: onSkip,
            ),
          Padding(
            padding: EdgeInsets.all(tokens.spacingUnit * 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!hasFrame && onSkip != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: DsButton(
                      label: skipLabel,
                      onPressed: onSkip,
                      variant: DsButtonVariant.tertiary,
                    ),
                  ),
                _StepSwitcher(
                  stepIndex: _index,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        step.title,
                        style: tokens.headingMd
                            .toTextStyle(color: tokens.colorText),
                      ),
                      SizedBox(height: tokens.spacingUnit),
                      Text(
                        step.body,
                        style: tokens.bodyMd
                            .toTextStyle(color: tokens.colorSecondaryText),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: tokens.spacingUnit * 3),
                _Footer(
                  stepIndex: _index,
                  stepCount: steps.length,
                  isLast: _isLast,
                  canNavigate: canNavigate,
                  backLabel: backLabel,
                  nextLabel: nextLabel,
                  doneLabel: doneLabel,
                  onBack: canNavigate ? () => _move(-1) : null,
                  onNext: _isLast
                      ? onDone
                      : (canNavigate ? () => _move(1) : null),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.arrowRight): _TourNextIntent(),
        SingleActivator(LogicalKeyboardKey.arrowLeft): _TourBackIntent(),
      },
      child: Actions(
        // With navigation disabled the map is empty, so arrow keys are not
        // consumed and normal focus traversal keeps working.
        actions: canNavigate
            ? {
                _TourNextIntent: CallbackAction<_TourNextIntent>(
                  onInvoke: (_) {
                    _move(1);
                    return null;
                  },
                ),
                _TourBackIntent: CallbackAction<_TourBackIntent>(
                  onInvoke: (_) {
                    _move(-1);
                    return null;
                  },
                ),
              }
            : const <Type, Action<Intent>>{},
        child: FocusTraversalGroup(
          // Explicit child nodes keep the copy, the progress announcement and
          // each button as separate nodes instead of one merged blob.
          child: Semantics(
            container: true,
            explicitChildNodes: true,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: GestureDetector(
                onHorizontalDragEnd:
                    (enableSwipe && canNavigate) ? _handleSwipe : null,
                child: card,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Advances the tour one step. Bound to the right arrow key.
class _TourNextIntent extends Intent {
  const _TourNextIntent();
}

/// Moves the tour back one step. Bound to the left arrow key.
class _TourBackIntent extends Intent {
  const _TourBackIntent();
}

/// The tinted band above the copy: the skip control and the current step's
/// illustration on a token-tinted surface.
class _Frame extends StatelessWidget {
  const _Frame({
    required this.step,
    required this.stepIndex,
    required this.height,
    required this.skipLabel,
    required this.onSkip,
  });

  final DsTourStep step;
  final int stepIndex;
  final double height;
  final String skipLabel;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    Widget? illustration = step.illustration;
    if (illustration != null) {
      illustration = step.illustrationLabel == null
          // Decorative by default: the copy carries the meaning, so the
          // artwork stays silent for a screen reader.
          ? ExcludeSemantics(child: illustration)
          : Semantics(
              label: step.illustrationLabel,
              image: true,
              child: illustration,
            );
    }

    return Container(
      color: tokens.offsetBackgroundColor,
      padding: EdgeInsets.fromLTRB(
        tokens.spacingUnit * 2,
        tokens.spacingUnit,
        tokens.spacingUnit * 2,
        tokens.spacingUnit * 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (onSkip != null)
            Align(
              alignment: Alignment.centerRight,
              child: DsButton(
                label: skipLabel,
                onPressed: onSkip,
                variant: DsButtonVariant.tertiary,
              ),
            ),
          SizedBox(
            height: height,
            // A non-scrolling viewport absorbs any extra height a reflowing
            // illustration needs, so a tall child clips instead of throwing
            // an overflow.
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: height),
                child: _StepSwitcher(
                  stepIndex: stepIndex,
                  child: Center(
                    child: illustration ?? const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Cross-fades its child when the step index changes, sliding the incoming
/// content up a few pixels. Under reduced motion the swap is an instant still
/// frame.
class _StepSwitcher extends StatelessWidget {
  const _StepSwitcher({required this.stepIndex, required this.child});

  final int stepIndex;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: DsMotion.durationOf(context, DsMotion.base),
      switchInCurve: DsMotion.curveOf(context, DsMotion.emphasized),
      switchOutCurve: DsMotion.curveOf(context, DsMotion.standard),
      layoutBuilder: (currentChild, previousChildren) => Stack(
        alignment: Alignment.topLeft,
        children: [...previousChildren, ?currentChild],
      ),
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: KeyedSubtree(key: ValueKey<int>(stepIndex), child: child),
    );
  }
}

/// The progress bar and the Back and Next actions. On one row when the card
/// is wide enough; below [DsTourCard._stackBelow] the bar takes its own line
/// and the actions go full width beneath it.
class _Footer extends StatelessWidget {
  const _Footer({
    required this.stepIndex,
    required this.stepCount,
    required this.isLast,
    required this.canNavigate,
    required this.backLabel,
    required this.nextLabel,
    required this.doneLabel,
    required this.onBack,
    required this.onNext,
  });

  final int stepIndex;
  final int stepCount;
  final bool isLast;
  final bool canNavigate;
  final String backLabel;
  final String nextLabel;
  final String doneLabel;
  final VoidCallback? onBack;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    // The bar is decorative to a screen reader; the wrapping label announces
    // the position on every change instead, so it is never read twice.
    final progress = Semantics(
      label: 'Step ${stepIndex + 1} of $stepCount',
      liveRegion: true,
      child: DsProgressBar(
        value: (stepIndex + 1) / stepCount,
        minHeight: 6,
        animate: true,
        excludeSemantics: true,
      ),
    );

    Widget nextButton({required bool fullWidth}) => DsButton(
          label: isLast ? doneLabel : nextLabel,
          onPressed: onNext,
          fullWidth: fullWidth,
        );

    Widget backButton({required bool fullWidth}) => DsButton(
          label: backLabel,
          onPressed: onBack,
          variant: DsButtonVariant.tertiary,
          fullWidth: fullWidth,
        );

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        if (width < DsTourCard._stackBelow) {
          // Compact: the final call to action can be long, so it gets the
          // full width and Back sits beneath it.
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              progress,
              SizedBox(height: tokens.spacingUnit * 2),
              nextButton(fullWidth: true),
              if (stepIndex > 0) ...[
                SizedBox(height: tokens.spacingUnit / 2),
                backButton(fullWidth: true),
              ],
            ],
          );
        }
        // The actions take their natural width but never more than a share
        // of the row, so a long label ellipsizes inside its button instead
        // of pushing the progress bar out of the card. The keys stop the
        // forward button being reused as Back when Back appears, which would
        // morph one style into the other.
        return Row(
          children: [
            Expanded(child: progress),
            SizedBox(width: tokens.spacingUnit * 2),
            if (stepIndex > 0) ...[
              ConstrainedBox(
                key: const ValueKey('DsTourCard.back'),
                constraints: BoxConstraints(maxWidth: width * 0.25),
                child: backButton(fullWidth: false),
              ),
              SizedBox(width: tokens.spacingUnit),
            ],
            ConstrainedBox(
              key: const ValueKey('DsTourCard.next'),
              constraints: BoxConstraints(maxWidth: width * 0.5),
              child: nextButton(fullWidth: false),
            ),
          ],
        );
      },
    );
  }
}
