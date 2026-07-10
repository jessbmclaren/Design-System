// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Onboarding → Onboarding wizard.
final PatternPage onboardingWizardPage = PatternPage(
  id: 'onboarding-wizard',
  group: DocGroup.patterns,
  navTitle: 'Onboarding wizard',
  title: 'Onboarding wizard',
  description:
      'The onboarding wizard frames a multi-step setup flow in a single, '
      'predictable container: a progress header that shows where the user is, '
      'an optional title and subtitle, a scrollable body for the current '
      'step and a footer that pairs a secondary Back action with a primary '
      'Next action above a hairline divider. It is deliberately '
      'content-agnostic: `DsOnboardingWizard` owns the chrome while you '
      'supply each step\'s body as `child` and drive navigation yourself with '
      '`currentIndex`, `onBack` and `onNext`. Because it composes '
      '`DsProgressStepper` and `DsButton`, it inherits their theming, 48dp '
      'touch targets, reduced-motion behaviour and compact rendering, so one '
      'component backs everything from account setup to guided configuration.',
  hasLiveDemo: true,
  blocks: const [
    ProseBlock(
      'The wizard is a controlled component: it holds no step state of its '
      'own. Keep `currentIndex` and the collected values in your own model, '
      'advance on `onNext`, retreat on `onBack` and swap the `child` for the '
      'active step. Gate progress with `nextEnabled` while a step is '
      'incomplete, and set `nextPending` to show a spinner and block '
      'double-submits while a step is saving. Hide Back on the first step by '
      'leaving `onBack` null, and rename the final action with `nextLabel` '
      '(for example "Finish"). The body lives inside an `Expanded` scroll '
      'view, so give the wizard a bounded height (a page body or an '
      '`Expanded`) and it fills the space and scrolls long steps.',
    ),
  ],
  dos: const [
    'Keep the wizard to the few steps that genuinely need to be sequential, and label each step for what the user provides there.',
    'Hold currentIndex and step values in your own state; advance on onNext and retreat on onBack.',
    'Disable Next with nextEnabled while the current step is incomplete, so the user cannot skip required input.',
    'Set nextPending while a step saves to show a spinner and prevent double submission.',
    'Leave onBack null on the first step and rename the final action with nextLabel, e.g. "Finish".',
    'Give the wizard a bounded height so its scrollable body can expand and scroll long steps.',
  ],
  donts: const [
    'Don\'t force a linear wizard on tasks the user could complete in any order; a single form or settings view may fit better.',
    'Don\'t reorder or renumber steps mid-flow; the progress header should stay stable as the user moves through it.',
    'Don\'t advance past an invalid step; keep Next disabled rather than letting the user continue and fail later.',
    'Don\'t place the wizard in an unbounded-height context, where its Expanded body cannot lay out.',
  ],
  code: '''
DsOnboardingWizard(
  steps: const [
    DsWizardStep(label: 'Company'),
    DsWizardStep(label: 'Team'),
    DsWizardStep(label: 'Preferences'),
  ],
  currentIndex: _step,
  title: 'Tell us about your company',
  subtitle: 'This helps us tailor your workspace.',
  onBack: _step == 0 ? null : () => setState(() => _step -= 1),
  onNext: _canContinue
      ? () => setState(() => _step = (_step + 1).clamp(0, 2))
      : null,
  nextLabel: _step == 2 ? 'Finish' : 'Continue',
  nextEnabled: _canContinue,
  footerLeading: Text('Step \${_step + 1} of 3'),
  child: _StepBody(step: _step),
);
''',
  shots: const [
    Shot(pageId: 'onboarding-wizard', size: ShotSize.desktop),
    Shot(pageId: 'onboarding-wizard', size: ShotSize.phone),
  ],
  related: const ['progress-stepping', 'business-verification'],
);
