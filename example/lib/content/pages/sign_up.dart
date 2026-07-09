// Pure Dart — NO Flutter imports.
import '../pattern_page_content.dart';

/// Onboarding → Sign up.
final PatternPage signUpPage = PatternPage(
  id: 'sign-up',
  group: DocGroup.onboarding,
  navTitle: 'Sign up',
  title: 'Sign up',
  description:
      'The sign-up view turns a first visit into an account. `DsSignUpView` '
      'frames registration as one focused card — a branded glyph, a short title '
      'and description, your own form and a single full-width primary action — '
      'so the moment of commitment stays calm and unmistakable. The scaffold '
      'owns only the surrounding layout, spacing and responsive behaviour: you '
      'supply the `form` (typically a `DsFormFieldGroup`) and own its validation, '
      'while `onSubmit` does the work and, when `null`, disables the button until '
      'the form is ready. Pass an optional `aside` and the card grows a benefits '
      'panel beside it on wide screens, stacking it beneath on phones so nothing '
      'is ever lost.',
  hasLiveDemo: true,
  blocks: const [
    ProseBlock(
      'Lead with the value of creating an account, then ask for the fewest '
      'fields you truly need. Set `brandIcon` and `brandColor` so the card reads '
      'as yours the instant it appears, and reserve the `footer` for the '
      'returning-user path — an "Already have an account? Sign in" prompt. While '
      'the request is in flight, set `submitPending` to show a spinner and block '
      'repeat taps; the view never touches the network or a timer itself, so it '
      'renders identically in a screenshot and in production.',
    ),
  ],
  dos: const [
    'Ask for the fewest fields that let someone get started, then progressively collect the rest.',
    'Keep a single, unmistakable primary action and label it for the outcome, like "Create account".',
    'Brand the card with your own `brandIcon` and `brandColor` so it feels trustworthy.',
    'Use `submitPending` while the request is in flight to prevent duplicate submissions.',
    'Offer the returning-user path in the `footer` so existing accounts have a way in.',
    'Use `aside` to reinforce the value of signing up, not to add a second call to action.',
  ],
  donts: const [
    'Don\'t disable `onSubmit` silently — surface field errors on the `form` so people know what to fix.',
    'Don\'t crowd the card with links that pull people out before they finish.',
    'Don\'t bury the primary action beneath long terms copy or secondary options.',
    'Don\'t rely on the `aside` being visible on phones, where it stacks below the card.',
  ],
  code: '''
DsSignUpView(
  brandIcon: Icons.workspaces_outline,
  brandColor: const Color(0xFF6D28D9),
  title: 'Create your workspace',
  description: 'Start your 14-day trial. No card required.',
  form: DsFormFieldGroup(
    columns: 1,
    children: [
      DsTextField(
        label: 'Work email',
        hintText: 'you@company.com',
        keyboardType: TextInputType.emailAddress,
      ),
      DsTextField(label: 'Password', obscureText: true),
    ],
  ),
  primaryActionLabel: 'Create account',
  onSubmit: _formValid ? _handleSubmit : null,
  submitPending: _submitting,
  footer: Wrap(
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Text('Already have an account? ', style: DsTypography.bodySm.toTextStyle(
        color: DsTokens.of(context).colorSecondaryText,
      )),
      InkWell(
        onTap: _goToSignIn,
        child: Text('Sign in', style: DsTypography.labelMd.toTextStyle(
          color: DsTokens.of(context).actionPrimaryColorText,
        )),
      ),
    ],
  ),
)
''',
  shots: const [
    Shot(pageId: 'sign-up', size: ShotSize.desktop),
    Shot(pageId: 'sign-up', size: ShotSize.phone),
  ],
  related: const ['sign-in', 'onboarding'],
);
