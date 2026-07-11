import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_breakpoints.dart';
import '../atoms/ds_button.dart';
import '../atoms/ds_divider.dart';
import '../molecules/ds_footer_actions.dart';
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
/// body holding the current step's [child] and a footer with **Back** and
/// **Next** actions above a hairline [DsDivider].
///
/// The wizard is deliberately *content-agnostic*: it owns the chrome (progress,
/// headings, navigation) while the caller supplies each step's body as [child]
/// and drives navigation via [onBack] / [onNext] and [currentIndex]. This lets a
/// single component back both an "onboarding wizard" and a "setup wizard".
///
/// It composes existing Design System components rather than re-implementing
/// them: [DsProgressStepper] for the header and [DsFooterActions] (a cluster
/// of [DsButton]s) for the footer actions, so it inherits their theming, 48dp
/// touch targets, reduced-motion behaviour and compact/responsive rendering.
///
/// The chrome bends where a flow needs it to: [header] slots custom content
/// (a wordmark, an illustration) above the progress stepper, and the stepper
/// itself can be dropped with [showStepper]. It also hides itself when there
/// is only one step, where progress has nothing to say.
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
    this.header,
    this.showStepper = true,
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
  /// When null the Back button is hidden entirely, typically on the first
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

  /// Optional content shown above the progress stepper, such as a brand
  /// wordmark or a step illustration. When null the header starts with the
  /// stepper, as before.
  final Widget? header;

  /// Whether to show the progress stepper. Defaults to true.
  ///
  /// The stepper also hides itself when [steps] has fewer than two entries,
  /// where there is no progress to show.
  final bool showStepper;

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
        final horizontalPadding =
            compact ? tokens.spacingUnit * 2 : tokens.spacingUnit * 3;
        final headerContent = _buildHeader(tokens);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: optional custom content and progress stepper plus
            // optional title and subtitle. Skipped entirely when every part
            // is absent, so a single-step wizard does not open with an empty
            // padded band.
            if (headerContent != null)
              _Constrained(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    tokens.spacingUnit * 3,
                    horizontalPadding,
                    tokens.spacingUnit * 2,
                  ),
                  child: headerContent,
                ),
              ),
            // Body: the current step, scrollable within the space that remains.
            Expanded(
              child: _Constrained(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: tokens.spacingUnit,
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
                  vertical: tokens.spacingUnit * 2,
                ),
                child: _buildFooter(compact),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Builds the header content, or returns null when there is none.
  Widget? _buildHeader(DsTokens tokens) {
    final title = this.title;
    final subtitle = this.subtitle;
    final header = this.header;
    // A single step has no progress to report, so the stepper hides itself.
    final bool stepperVisible = showStepper && steps.length > 1;

    final children = <Widget>[
      if (header != null) ...[
        header,
        if (stepperVisible || title != null || subtitle != null)
          SizedBox(height: tokens.spacingUnit * 2),
      ],
      if (stepperVisible)
        DsProgressStepper(steps: _dsSteps, currentIndex: currentIndex),
      if (title != null) ...[
        if (stepperVisible) SizedBox(height: tokens.spacingUnit * 3),
        Semantics(
          header: true,
          child: Text(
            title,
            style: tokens.headingLg.toTextStyle(color: tokens.colorText),
          ),
        ),
      ],
      if (subtitle != null) ...[
        SizedBox(height: tokens.spacingUnit / 2),
        Text(
          subtitle,
          style: tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText),
        ),
      ],
    ];
    if (children.isEmpty) return null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  Widget _buildFooter(bool compact) {
    // Composed on DsFooterActions, the shared footer cluster. The wizard has
    // already decided its layout from its own width, so it forces the
    // cluster's mode rather than letting it re-measure: stacked (primary
    // first, full-width) on compact, a trailing row otherwise. The Back
    // action keeps its secondary emphasis, so the footer renders exactly as
    // it did before the cluster was extracted.
    return DsFooterActions(
      primaryLabel: nextLabel,
      onPrimary: nextEnabled ? onNext : null,
      primaryPending: nextPending,
      backLabel: onBack == null ? null : backLabel,
      onBack: onBack,
      backVariant: DsButtonVariant.secondary,
      leading: footerLeading,
      minRowWidth: compact ? double.infinity : 0,
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
