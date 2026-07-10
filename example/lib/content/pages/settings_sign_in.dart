// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Onboarding → Settings sign in.
final PatternPage settingsSignInPage = PatternPage(
  id: 'settings-sign-in',
  group: DocGroup.patterns,
  navTitle: 'Settings sign in',
  title: 'Settings sign in',
  description:
      'Some settings surfaces manage a connection to an external service, and '
      'those controls only make sense once the connection is authenticated. '
      'Gate the panel on the connection state: while the account is not '
      'connected, render a compact `DsSignInView` in place of the settings; '
      'once it is connected, swap in the settings themselves. The settings '
      'surface is the entry point, so the user authenticates exactly where the '
      'controls they came to change will appear.',
  blocks: const [
    ProseBlock(
      'Keep the signed-out state minimal: a short title, one line of context '
      'and a single primary action are enough to start the connection. Reserve '
      'the settings controls (toggles, credentials, disconnect) for the '
      'authenticated state so nothing appears actionable before it can be '
      'acted on. When the sign-in genuinely needs more explanation, move it '
      'into the view\'s additional-context reveal rather than crowding the '
      'card.',
    ),
  ],
  dos: const [
    'Use the settings surface itself as the entry point, so users connect '
        'exactly where the controls live.',
    'Keep the signed-out view minimal: a clear title, one line of context and '
        'a single primary action.',
    'Move any extra explanation into a focused reveal or panel instead of the '
        'sign-in card.',
    'Confirm the connected state plainly (a status badge and a way to '
        'disconnect) before showing detailed controls.',
  ],
  donts: const [
    'Don\'t clutter the sign-in with non-essential context, marketing copy or '
        'multiple competing actions.',
    'Don\'t show settings controls before the connection is authenticated.',
    'Don\'t collect credentials inline; the primary action should hand off to '
        'a dedicated authentication flow.',
  ],
  code: '''
bool signedIn = false;

// Gate the settings surface on the connection state.
if (!signedIn) {
  return DsSignInView(
    brandIcon: Icons.hub_outlined,
    title: 'Connect your account',
    description:
        'Sign in to manage this integration\\'s settings.',
    primaryAction: DsSignInAction(
      label: 'Connect account',
      onPressed: () => setState(() => signedIn = true),
    ),
  );
}

// Authenticated: show the settings panel.
return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const DsBadge(label: 'Connected', variant: DsBadgeVariant.success),
    DsList(
      bordered: true,
      children: const [
        DsListItem(title: 'Sync frequency', subtitle: 'Every 15 minutes'),
        DsListItem(title: 'Notifications', subtitle: 'Enabled'),
      ],
    ),
    DsButton(
      label: 'Disconnect',
      variant: DsButtonVariant.secondary,
      onPressed: () => setState(() => signedIn = false),
    ),
  ],
);
''',
  shots: const [
    Shot(pageId: 'settings-sign-in', size: ShotSize.desktop),
    Shot(pageId: 'settings-sign-in', size: ShotSize.phone),
  ],
  hasLiveDemo: true,
  related: ['sign-in', 'additional-context'],
);
