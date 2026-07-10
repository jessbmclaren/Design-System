// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Patterns → Setup guide.
final PatternPage setupGuidePage = PatternPage(
  id: 'setup-guide',
  group: DocGroup.patterns,
  navTitle: 'Setup guide',
  title: 'Setup guide',
  description:
      '`DsSetupGuide` is a collapsible checklist card for a product\'s '
      'first-run tasks: a disclosure header with a done count, an animated '
      'progress bar and the task list itself. Each `DsSetupTask` carries its '
      'own state flags, so the card is a pure readout of setup progress the '
      'caller owns. Collapsed, the list gives way to a "Next" line linking to '
      'the first task the user can act on, so even the slim bar points '
      'somewhere useful.',
  hasLiveDemo: true,
  blocks: const [
    ProseBlock(
      'Tasks come in four shapes. An open to-do is tappable at the full 48dp '
      'target and routes to the work through its `onTap`. A `pending` task '
      'shows a warning pill while an outcome is awaited. A `locked` task is '
      'dimmed and explains its gate in a tooltip, on hover and on tap; give '
      '`lockedMessage` the real blocker so the user knows what to do first. '
      'A `done` task shows a filled check, or, with `animateCrossOff`, '
      'strikes itself through and clears out of the list the moment it '
      'completes.',
    ),
    ProseBlock(
      'The card floats at 320dp by default. Set `fullWidth: true` for a '
      'bottom-docked bar on mobile, with `initiallyCollapsed: true` so '
      'expanding it over the page stays the user\'s choice. Give it a '
      '`maxHeight` on short viewports and the task list scrolls inside the '
      'card instead of clipping.',
    ),
  ],
  dos: const [
    'Order tasks the way you want them tackled; the collapsed Next line always points at the first actionable one.',
    'Give every locked task a lockedMessage naming the actual blocker, not a generic instruction.',
    'Use animateCrossOff for tasks that stop mattering once done, so the list keeps shrinking.',
    'Pass a collapsedSummary so the collapsed card still says something once nothing is actionable.',
  ],
  donts: const [
    'Don\'t mutate task state inside the card; complete tasks in your own state and rebuild with new flags.',
    'Don\'t go beyond a handful of tasks; a long checklist reads as a burden rather than a guide.',
    'Don\'t hide the card as soon as most tasks are done; the last steps are the ones that need the nudge.',
    'Don\'t use it for ordered wizard stages; that is DsProgressStepper\'s job.',
  ],
  code: '''
DsSetupGuide(
  title: 'Setup guide',
  fullWidth: isMobile,
  initiallyCollapsed: isMobile,
  tasks: [
    DsSetupTask(
      label: 'Verify your business',
      pending: submitted && !businessVerified,
      done: businessVerified,
      onTap: _openVerification,
    ),
    DsSetupTask(
      label: 'Verify your email',
      done: emailVerified,
      animateCrossOff: true,
      onTap: _openEmailVerification,
    ),
    DsSetupTask(
      label: 'Invite users',
      done: usersInvited,
      onTap: _openInvites,
    ),
    DsSetupTask(
      label: 'Go live',
      locked: !readyToGoLive,
      lockedMessage: 'Verify your business to go live',
      onTap: _goLive,
    ),
  ],
);
''',
  shots: const [
    Shot(pageId: 'setup-guide', size: ShotSize.desktop),
    Shot(pageId: 'setup-guide', size: ShotSize.phone),
  ],
  related: const ['onboarding-wizard', 'business-verification', 'progress-bar'],
);
