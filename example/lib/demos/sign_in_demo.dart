import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Sign in page.
///
/// Renders a real [DsSignInView] in its form-led composition: a left-aligned
/// heading, an email field, a password block whose label row carries the
/// forgot-password link, a remember-me [DsCheckbox], the full-width primary
/// action, a labelled divider above the alternative providers and a
/// create-account prompt in the tinted footer band. A failed sign-in surfaces
/// a `DsBanner` above the form — the pattern the page prescribes — cleared the
/// moment either field is edited. The fields start pre-filled so the first
/// frame is complete. No timers, network or randomness.
class SignInDemo extends StatefulWidget {
  const SignInDemo({super.key});

  @override
  State<SignInDemo> createState() => _SignInDemoState();
}

class _SignInDemoState extends State<SignInDemo> {
  final TextEditingController _email =
      TextEditingController(text: 'jordan@northwind.io');
  final TextEditingController _password =
      TextEditingController(text: 'correct-horse-battery');
  bool _remember = true;
  bool _error = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  /// A returning-user check stands in for the real auth call: an address and an
  /// 8+ character password pass, anything else is rejected with the one message
  /// the best sign-in forms show rather than naming which half was wrong.
  void _trySignIn() {
    final ok =
        _email.text.contains('@') && _password.text.trim().length >= 8;
    setState(() => _error = !ok);
  }

  /// Clear the failed-sign-in banner the instant either field is edited, so it
  /// never lingers over input the user has already started to fix.
  void _clearError(String _) {
    setState(() => _error = false);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    return DsSignInView(
      title: 'Sign in to your account',
      headingAlignment: DsHeadingAlignment.start,
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error) ...[
            const DsBanner(
              variant: DsBannerVariant.danger,
              title: 'Incorrect email or password.',
            ),
            const SizedBox(height: DsSpacing.lg),
          ],
          DsTextField(
            label: 'Email',
            hintText: 'you@company.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            controller: _email,
            onChanged: _clearError,
          ),
          const SizedBox(height: DsSpacing.lg),
          // The label takes its natural width and the link claims the rest,
          // right-aligned, so "Forgot your password?" shows in full while the
          // link still ellipsizes rather than overflowing on a 320dp viewport.
          Row(
            children: [
              const DsFieldLabel(label: 'Password'),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: DsLink(
                    label: 'Forgot your password?',
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DsSpacing.xs),
          DsPasswordField(
            controller: _password,
            textInputAction: TextInputAction.done,
            onChanged: _clearError,
            onSubmitted: (_) => _trySignIn(),
          ),
          const SizedBox(height: DsSpacing.md),
          DsCheckbox(
            value: _remember,
            onChanged: (v) => setState(() => _remember = v),
            label: 'Remember me on this device',
          ),
        ],
      ),
      primaryAction: DsSignInAction(label: 'Sign in', onPressed: _trySignIn),
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const DsLabeledDivider(label: 'Or sign in with'),
          const SizedBox(height: DsSpacing.lg),
          DsButton.social(
            icon: DsIcons.web,
            label: 'Google',
            onPressed: () {},
          ),
          const SizedBox(height: DsSpacing.md),
          DsButton.social(
            icon: DsIcons.key,
            label: 'Passkey',
            onPressed: () {},
          ),
          const SizedBox(height: DsSpacing.md),
          DsButton.social(
            icon: DsIcons.verified,
            label: 'SSO',
            onPressed: () {},
          ),
        ],
      ),
      footerBand: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'New here? ',
            style: tokens.bodySm.toTextStyle(
              color: tokens.colorSecondaryText,
            ),
          ),
          DsLink(label: 'Create an account', onPressed: () {}),
        ],
      ),
    );
  }
}
