import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Sign in page.
///
/// Renders a real [DsSignInView] in its form-led composition: a left-aligned
/// heading, an email field, a password block whose label row carries the
/// forgot-password link, a remember-me [DsCheckbox], the full-width primary
/// action, a labelled divider above the alternative providers and a
/// create-account prompt in the tinted footer band. The fields start
/// pre-filled so the first frame is complete; emptying a field surfaces its
/// error via [setState]. No timers, network or randomness.
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

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
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
          DsTextField(
            label: 'Email',
            hintText: 'you@company.com',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            controller: _email,
            errorText: _email.text.trim().isEmpty ? 'Enter your email.' : null,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: DsSpacing.lg),
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
            errorText: _password.text.isEmpty ? 'Enter your password.' : null,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: DsSpacing.md),
          DsCheckbox(
            value: _remember,
            onChanged: (v) => setState(() => _remember = v),
            label: 'Remember me on this device',
          ),
        ],
      ),
      primaryAction: DsSignInAction(label: 'Sign in', onPressed: () {}),
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
            style: DsTypography.bodySm.toTextStyle(
              color: tokens.colorSecondaryText,
            ),
          ),
          DsLink(label: 'Create an account', onPressed: () {}),
        ],
      ),
    );
  }
}
