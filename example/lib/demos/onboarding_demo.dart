import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Onboarding page: a `DsSignInView` framed as the opening
/// step of setup, with a brand mark, a single primary action and a secondary
/// sign-in link in the footer.
class OnboardingDemo extends StatelessWidget {
  const OnboardingDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    return DsSignInView(
      brandIcon: Icons.dashboard_rounded,
      brandColor: tokens.buttonPrimaryColorBackground,
      title: 'Set up your workspace',
      description:
          'Add your team details and preferences to get your dashboard ready.',
      primaryAction: DsSignInAction(
        label: 'Continue',
        onPressed: () {},
      ),
      footer: TextButton(
        onPressed: () {},
        child: const Text('Already have an account? Sign in'),
      ),
    );
  }
}
