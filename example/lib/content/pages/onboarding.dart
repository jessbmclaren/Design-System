// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Onboarding → Onboarding.
final PatternPage onboardingPage = PatternPage(
  id: 'onboarding',
  group: DocGroup.patterns,
  navTitle: 'Onboarding',
  title: 'Onboarding',
  description:
      'Onboarding is the journey from a first visit to productive use, and '
      'the kit covers it as stages you compose rather than a single screen. '
      'A visitor arrives on a page framed by the auth shell, creates an '
      'account or signs back in, waits out provisioning on a waiting screen, '
      'clears the setup that blocks first use in a wizard and finishes the '
      'rest from a setup guide inside the product. Each stage has its own '
      'pattern page; this one maps the journey and shows the opening moment, '
      'a welcome card built with `DsSignInView`.',
  hasLiveDemo: true,
  blocks: const [
    ProseBlock(
      'The flow opens on public pages framed by `DsAuthShell`: a decorative '
      'backdrop, a wordmark pinned to the top corner, a line of legal links '
      'along the bottom and a banner slot that hosts the `DsCookieBanner` '
      'consent bar. Inside the shell sits one card at a time. `DsSignUpView` '
      'frames registration and `DsSignInView` the return visit; both '
      'scaffold the card while you own the form and its validation. The '
      'sign-up and sign-in pages cover their composition in detail, down to '
      'the password strength meter and the provider buttons.',
    ),
    ProseBlock(
      'Two surfaces bridge the gap between submitting credentials and '
      'standing in the product. `DsWaitingScreen` holds a brief provisioning '
      'moment with a large spinner, an animated headline and the same '
      'gradient backdrop as the shell; it holds no timers, so you swap it '
      'out when the work completes. The welcome card in the live demo is '
      '`DsSignInView` with no form: a brand mark, one line of value and a '
      'single full-width Continue action. Keep this first signed-in moment '
      'to the one step that matters and defer everything else.',
    ),
    ProseBlock(
      'When setup needs real answers, run it as steps. `DsOnboardingWizard` '
      'owns the chrome of a multi-step flow (progress header, scrollable '
      'body, Back and Next actions) while you keep the state and swap the '
      'body per step. `DsBusinessVerification` is the worked example: four '
      'short steps that collect and review an organisation\'s details on '
      'that chrome. A step the user must clear before continuing, such as '
      'verifying an email, runs as a card in a `DsTakeover` over a blurred, '
      'inert copy of the page behind it.',
    ),
    ProseBlock(
      'Onboarding does not end at the last wizard step. `DsSetupGuide` '
      'carries the remaining tasks into the product as a collapsible '
      'checklist that reads out progress and always points at the next '
      'actionable item. `DsTourCard` gives the short illustrated walkthrough '
      'after sign-up; it steps through a few ideas on its own card and '
      'points at nothing. Both are controlled components, so you decide '
      'when they appear and what progress they show.',
    ),
  ],
  dos: const [
    'Put only the steps that block first use in the wizard; hand the rest to a setup guide inside the product.',
    'Frame every page of the flow in the same auth shell so the journey reads as one place.',
    'Keep the opening card to one primary action and state the value of taking it.',
    'Show a waiting screen that names the work and sets an expectation when provisioning takes more than a moment.',
    'Collect sensitive credentials on a flow you control, then return the user to where they left off.',
  ],
  donts: const [
    'Don\'t use onboarding for promotions, cross-sells or unrelated announcements.',
    'Don\'t front-load a long form when a checklist can carry the tasks into the product.',
    'Don\'t make the tour a gate; the user closes it when they choose.',
    'Don\'t bury the primary action beneath competing links or dense copy.',
  ],
  code: '''
DsSignInView(
  brandIcon: DsIcons.dashboard,
  brandColor: DsTokens.of(context).buttonPrimaryColorBackground,
  title: 'Set up your workspace',
  description:
      'Add your team details and preferences to get your dashboard ready.',
  primaryAction: DsSignInAction(
    label: 'Continue',
    onPressed: () => _startSetup(),
  ),
  footer: TextButton(
    onPressed: () => _signInInstead(),
    child: const Text('Already have an account? Sign in'),
  ),
);
''',
  shots: const [
    Shot(pageId: 'onboarding', size: ShotSize.desktop),
    Shot(pageId: 'onboarding', size: ShotSize.phone),
  ],
  related: [
    'auth-shell',
    'cookie-banner',
    'sign-up',
    'sign-in',
    'waiting-screens',
    'onboarding-wizard',
    'business-verification',
    'takeover',
    'setup-guide',
    'tour-card',
  ],
);
