// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Onboarding → Sign in.
final PatternPage signInPage = PatternPage(
  id: 'sign-in',
  group: DocGroup.patterns,
  navTitle: 'Sign in',
  title: 'Sign in',
  description:
      'The sign-in view is the front door to your product: a single, focused '
      'card that welcomes people and sends them into authentication with one '
      'clear action. `DsSignInView` shows your brand mark, a short title and '
      'description, and a full-width primary button. It deliberately collects '
      'no passwords itself. Instead of embedding a credential form, the primary '
      'action hands off to your dedicated authentication flow, so the card stays '
      'lightweight, trustworthy and easy to brand.',
  hasLiveDemo: true,
  blocks: const [
    ProseBlock(
      'Give people a way both to sign in and to sign up. Put the primary action '
      'first and keep it unmistakable, then offer the secondary path (a '
      'sign-up prompt) in the `footer`. Set `brandIcon` and `brandColor` so '
      'the card reads as yours the moment it appears. If you need to surface '
      'terms, help text or an enterprise sign-in option, tuck it behind '
      '`additionalContextLabel` so the default view stays uncluttered.',
    ),
  ],
  dos: const [
    'Keep the view lightweight and focused on a single primary action.',
    'Offer both sign in and sign up so returning and new users each have a path.',
    'Use consistent action labels that match the flow you send people into.',
    'Brand the card with your own icon and colour so it feels trustworthy.',
  ],
  donts: const [
    'Don\'t ask people to enter full credentials into a surface you don\'t control.',
    'Don\'t add distracting links that pull people out of the flow before they start.',
    'Don\'t bury the primary action beneath secondary text or options.',
  ],
  code: '''
DsSignInView(
  brandIcon: Icons.hexagon_rounded,
  brandColor: const Color(0xFF6D28D9),
  title: 'Sign in to Acme',
  description:
      'Access your dashboards, records and reports. '
      'We\\'ll take you to a secure page to continue.',
  primaryAction: DsSignInAction(
    label: 'Sign in',
    onPressed: () {},
  ),
  footer: Wrap(
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Text('New here? ', style: DsTypography.bodySm.toTextStyle(
        color: DsTokens.of(context).colorSecondaryText,
      )),
      InkWell(
        onTap: () {},
        child: Text('Sign up', style: DsTypography.labelMd.toTextStyle(
          color: DsTokens.of(context).actionPrimaryColorText,
        )),
      ),
    ],
  ),
)
''',
  shots: const [
    Shot(pageId: 'sign-in', size: ShotSize.desktop),
    Shot(pageId: 'sign-in', size: ShotSize.phone),
  ],
  related: ['design-tokens', 'action-buttons', 'communicating-state'],
);
