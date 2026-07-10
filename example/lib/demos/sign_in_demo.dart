import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Sign in page: a branded, form-based [DsSignInView] with
/// username and password fields, a forgot-password link, a full-width primary
/// action and a sign-up prompt in the footer.
class SignInDemo extends StatelessWidget {
  const SignInDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    return DsSignInView(
      brandIcon: Icons.workspaces_outline,
      title: 'Welcome back',
      description: 'Sign in to your Acme account to continue.',
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const DsTextField(
            label: 'Username',
            hintText: 'Enter your username',
          ),
          const SizedBox(height: DsSpacing.md),
          const DsTextField(
            label: 'Password',
            hintText: 'Enter your password',
            obscureText: true,
          ),
          const SizedBox(height: DsSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: DsLink(label: 'Forgot password?', onPressed: () {}),
          ),
        ],
      ),
      primaryAction: DsSignInAction(label: 'Sign in', onPressed: () {}),
      footer: Wrap(
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
