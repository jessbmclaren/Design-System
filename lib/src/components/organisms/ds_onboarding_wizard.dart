import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_breakpoints.dart';
import '../../tokens/ds_spacing.dart';
import '../atoms/ds_button.dart';
import '../atoms/ds_divider.dart';
import 'ds_progress_stepper.dart';

/// A single step within a [DsOnboardingWizard].
///
/// A step carries only a human-readable [label]; the wizard forwards it to a
/// [DsProgressStepper], which derives each step's visual state (completed,
/// current or upcoming) from its position relative to
/// [DsOnboardingWizard.currentIndex].
@immutable
class DsWizardStep {
  /// Creates a wizard step described by [label].
  const DsWizardStep({required this.label});

  /// The short, human-readable name of the step, shown in the progress header.
  final String label;
}

/// A stepped onboarding / setup wizard container.
///
/// [DsOnboardingWizard] frames a multi-step flow: a progress header built from
/// [steps] and [currentIndex], an optional [title] and [subtitle], a scrollable
/// body holding the current step's [child], and a footer with **Back** and
/// **Next** actions above a hairline [DsDivider].
///
/// The wizard is deliberately *content-agnostic* — it owns the chrome (progress,
/// headings, navigation) while the caller supplies each step's body as [child]
/// and drives navigation via [onBack] / [onNext] and [currentIndex]. This lets a
/// single component back both an "onboarding wizard" and a "setup wizard".
///
/// It composes existing Design System components rather than re-implementing
/// them: [DsProgressStepper] for the header and [DsButton] for the footer
/// actions, so it inherits their theming, 48dp touch targets, reduced-motion
/// behaviour and compact/responsive rendering.
///
/// ## Layout & responsiveness
///
/// The content (header, body and footer) is constrained to a comfortable
/// reading width (~640dp) and centred on wide screens; on compact screens it
/// spans the full width with tighter horizontal padding. The
/// [DsProgressStepper] collapses to its own compact "Step X of N" form on narrow
/// viewports, so the header never overflows down to a 320dp phone. The footer
/// actions stack full-width on compact screens and sit on a single row on wider
/// ones.
///
/// The body is an [Expanded] [SingleChildScrollView], so the wizard expands to
/// fill the height it is given and scrolls its step content when space is tight.
/// Place it somewhere with a bounded height (for example the body of a page, or
/// inside an [Expanded]).
///
/// ## First frame & screenshots
///
/// The wizard renders no timers or indefinite animation and is safe to capture
/// in a screenshot. A caller that starts it at `currentIndex: 0` with an empty
/// step body gets a sensible, stable first frame.
class DsOnboardingWizard extends StatelessWidget {
  /// Creates a stepped onboarding / setup wizard.
  ///
  /// [steps] describes the ordered stages shown in the progress header, and
  /// [currentIndex] is the zero-based index of the active stage. [child] is the
  /// body of that active stage.
  const DsOnboardingWizard({
    super.key,
    required this.steps,
    required this.currentIndex,
    required this.child,
    this.title,
    this.subtitle,
    this.onBack,
    this.onNext,
    this.nextLabel = 'Continue',
    this.backLabel = 'Back',
    this.nextEnabled = true,
    this.nextPending = false,
    this.footerLeading,
  });

  /// The ordered steps shown in the progress header.
  final List<DsWizardStep> steps;

  /// The zero-based index of the step currently in progress.
  ///
  /// Steps before this index are treated as completed and steps after it as
  /// upcoming by the underlying [DsProgressStepper].
  final int currentIndex;

  /// The body of the current step, supplied by the caller.
  final Widget child;

  /// An optional prominent heading shown above the step body.
  final String? title;

  /// Optional supporting copy shown beneath [title].
  final String? subtitle;

  /// Called when the **Back** action is tapped.
  ///
  /// When null the Back button is hidden entirely — typically on the first
  /// step, where there is nowhere to go back to.
  final VoidCallback? onBack;

  /// Called when the **Next** action is tapped.
  ///
  /// Only invoked while [nextEnabled] is true and [nextPending] is false.
  final VoidCallback? onNext;

  /// The label of the primary **Next** action. Defaults to `'Continue'`.
  final String nextLabel;

  /// The label of the secondary **Back** action. Defaults to `'Back'`.
  final String backLabel;

  /// Whether the **Next** action is enabled.
  ///
  /// When false the primary button is disabled (for example while the current
  /// step's form is incomplete). Defaults to true.
  final bool nextEnabled;

  /// Whether the **Next** action is in flight.
  ///
  /// When true the primary button shows a spinner and is disabled, so the
  /// action cannot be triggered twice. Defaults to false.
  final bool nextPending;

  /// Optional content pinned to the leading (start) edge of the footer, such as
  /// a "Step 2 of 4" caption or a "Skip" link. It shares the footer row with the
  /// Back and Next actions on wide screens and sits beneath them on compact
  /// ones.
  final Widget? footerLeading;

  /// The maximum width the wizard content is constrained to on wide screens.
  static const double _maxContentWidth = 640;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Resolve a finite width so downstream flex layouts never receive
        // unbounded horizontal constraints.
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final compact = width < DsBreakpoints.medium;
        final horizontalPadding = compact ? DsSpacing.lg : DsSpacing.xl;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: progress stepper plus optional title and subtitle.
            _Constrained(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  DsSpacing.xl,
                  horizontalPadding,
                  DsSpacing.lg,
                ),
                child: _buildHeader(tokens),
              ),
            ),
            // Body: the current step, scrollable within the space that remains.
            Expanded(
              child: _Constrained(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: DsSpacing.sm,
                  ),
                  child: child,
                ),
              ),
            ),
            // Footer: a hairline divider above the navigation actions.
            const DsDivider(),
            _Constrained(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: DsSpacing.lg,
                ),
                child: _buildFooter(compact),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(DsTokens tokens) {
    final title = this.title;
    final subtitle = this.subtitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        DsProgressStepper(steps: _dsSteps, currentIndex: currentIndex),
        if (title != null) ...[
          const SizedBox(height: DsSpacing.xl),
          Semantics(
            header: true,
            child: Text(
              title,
              style: tokens.headingLg.toTextStyle(color: tokens.colorText),
            ),
          ),
        ],
        if (subtitle != null) ...[
          const SizedBox(height: DsSpacing.xs),
          Text(
            subtitle,
            style: tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText),
          ),
        ],
      ],
    );
  }

  Widget _buildFooter(bool compact) {
    final back = onBack == null
        ? null
        : DsButton(
            label: backLabel,
            onPressed: onBack,
            variant: DsButtonVariant.secondary,
            fullWidth: compact,
          );
    final next = DsButton(
      label: nextLabel,
      onPressed: nextEnabled ? onNext : null,
      pending: nextPending,
      fullWidth: compact,
    );
    final footerLeading = this.footerLeading;

    if (compact) {
      // Stack full-width so nothing overflows on a 320dp phone; the primary
      // action leads visually.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          next,
          if (back != null) ...[
            const SizedBox(height: DsSpacing.sm),
            back,
          ],
          if (footerLeading != null) ...[
            const SizedBox(height: DsSpacing.md),
            Align(alignment: Alignment.center, child: footerLeading),
          ],
        ],
      );
    }

    return Row(
      children: [
        // Consume the leading space so the actions sit on the trailing edge;
        // Expanded also bounds any wide leading content so it cannot overflow.
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: footerLeading ?? const SizedBox.shrink(),
          ),
        ),
        if (back != null) ...[
          back,
          const SizedBox(width: DsSpacing.md),
        ],
        next,
      ],
    );
  }

  /// Maps the wizard's [steps] onto the [DsStep] type the stepper consumes.
  List<DsStep> get _dsSteps =>
      steps.map((step) => DsStep(label: step.label)).toList(growable: false);
}

/// Centres and width-limits the wizard's sections so they align to a single
/// column on wide screens while spanning the full width on narrow ones.
class _Constrained extends StatelessWidget {
  const _Constrained({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: DsOnboardingWizard._maxContentWidth,
        ),
        child: child,
      ),
    );
  }
}
