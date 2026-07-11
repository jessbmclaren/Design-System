// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Overlays → Takeover.
final PatternPage takeoverPage = PatternPage(
  id: 'takeover',
  group: DocGroup.overlays,
  navTitle: 'Takeover',
  title: 'Takeover',
  description:
      'A takeover hosts one card over a blurred, scrimmed and fully inert '
      'copy of the page behind it: verifying an email over the dashboard, '
      'say, or a gate the user must clear before continuing. `DsTakeover` '
      'wraps the background in the pointer, semantics and focus exclusions '
      'so it cannot be tapped, read or reached by keyboard, and centres the '
      'card in a safe area and scroll view so a tall card scrolls instead '
      'of overflowing.',
  hasLiveDemo: false,
  blocks: const [
    ProseBlock(
      'The background stays recognisable on purpose. A light blur (3 by '
      'default) and the theme\'s `overlayBackdropColor` scrim tell the user '
      'where they are without washing the page out. The takeover holds no '
      'route or state of its own: the caller shows it, handles `onDismiss` '
      'and removes it, typically by swapping the page body.',
    ),
    ProseBlock(
      'By default a tap outside the card does nothing, because a takeover '
      'usually gates a step the user must finish or close explicitly. Set '
      '`barrierDismissible` with an `onDismiss` when tapping away should '
      'close it, and keep a visible close affordance on the card either '
      'way.',
    ),
  ],
  dos: const [
    'Use it for a single focused step over a page the user will return to.',
    'Keep an explicit close or cancel affordance on the card itself.',
    'Pass the real page as the background so the context stays honest.',
  ],
  donts: const [
    'Don\'t run a multi-step flow inside one; use the onboarding wizard or '
        'a full page.',
    'Don\'t stack takeovers; finish or dismiss one before opening the next.',
    'Don\'t rely on the barrier as the only way out.',
  ],
  code: '''
DsTakeover(
  background: dashboard,
  barrierDismissible: true,
  onDismiss: () => setState(() => _verifying = false),
  child: verifyEmailCard,
);
''',
  related: ['focus-view', 'waiting-screens', 'coachmark'],
);
