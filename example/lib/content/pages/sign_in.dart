// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Patterns → Sign in.
final PatternPage signInPage = PatternPage(
  id: 'sign-in',
  group: DocGroup.patterns,
  navTitle: 'Sign in',
  title: 'Sign in',
  description:
      'The sign-in view is the front door to your product — a single, centred '
      'card that welcomes people back and gets them in with as little friction '
      'as possible. `DsSignInView` leads with your brand mark and a warm '
      'greeting, then a compact `form` (a username and a password), a '
      'forgot-password link, and a full-width primary action. A footer offers '
      'the other path — creating an account — so returning and new people each '
      'land somewhere. The card owns none of the form\'s state or validation; '
      'you pass the fields in and handle submission, so the same view backs a '
      'password sign-in, a magic link, or an SSO hand-off just by changing what '
      'you put in `form` and `primaryAction`.',
  hasLiveDemo: true,
  blocks: const [
    ProseBlock(
      'Keep it to the two things people came to do: enter their details and get '
      'in. Lead with the brand so the card reads as yours the instant it '
      'appears, keep the greeting short and human, and let the primary button '
      'be the obvious next step. Put recovery (forgot password) next to the '
      'fields where people look for it, and the alternate path (sign up) in the '
      'footer. Surface a failed attempt with a `DsBanner` above the form rather '
      'than a bare sentence, and use the field labels and hints to guide, not '
      'to lecture.',
    ),
  ],
  dos: const [
    'Lead with the brand and a warm, one-line greeting so the card feels like '
        'yours and like a welcome, not a gate.',
    'Give people the two obvious paths: signing in (the primary action) and '
        'creating an account (the footer).',
    'Put the forgot-password link right by the password field, where people '
        'reach for it.',
    'Surface a failed sign-in clearly — a banner above the form — and keep the '
        'fields filled so they can correct one thing.',
  ],
  donts: const [
    "Don't crowd the card with links and options; the two paths and recovery "
        'are enough, everything else buries them.',
    "Don't hide which action signs in; the full-width primary button should be "
        'unmistakable.',
    "Don't scold in field copy — a hint guides, an error explains, neither "
        'blames.',
    "Don't reinvent the inputs; use `DsTextField` so the form matches every "
        'other form in the product.',
  ],
  code: '''
DsSignInView(
  brandIcon: Icons.workspaces_outline,
  title: 'Welcome back',
  description: 'Sign in to your Acme account to continue.',
  form: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const DsTextField(label: 'Username', hintText: 'Enter your username'),
      const SizedBox(height: DsSpacing.md),
      const DsTextField(
        label: 'Password',
        hintText: 'Enter your password',
        obscureText: true,
      ),
      const SizedBox(height: DsSpacing.sm),
      Align(
        alignment: Alignment.centerRight,
        child: DsLink(label: 'Forgot password?', onPressed: _recover),
      ),
    ],
  ),
  primaryAction: DsSignInAction(label: 'Sign in', onPressed: _submit),
  footer: DsLink(label: 'Create an account', onPressed: _goToSignUp),
)
''',
  shots: const [
    Shot(pageId: 'sign-in', size: ShotSize.desktop),
    Shot(pageId: 'sign-in', size: ShotSize.phone),
  ],
  related: ['sign-up', 'text-fields', 'communicating-state'],
);
