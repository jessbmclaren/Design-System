import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Additional context page: a sign-in view whose supporting
/// explanation is tucked behind a "How this works" reveal, keeping the primary
/// action front and centre.
class AdditionalContextDemo extends StatelessWidget {
  const AdditionalContextDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final lineStyle = Theme.of(context)
        .textTheme
        .bodyMedium
        ?.copyWith(color: tokens.colorSecondaryText);

    return DsSignInView(
      title: 'Sign in to your workspace',
      description:
          'Use your work account to access your dashboards and reports.',
      primaryAction: DsSignInAction(label: 'Continue', onPressed: () {}),
      additionalContextLabel: 'How this works',
      additionalContext: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'We verify your identity through your organisation\'s provider.',
            style: lineStyle,
          ),
          const SizedBox(height: 8),
          Text(
            'Your permissions decide which records and settings you can see.',
            style: lineStyle,
          ),
          const SizedBox(height: 8),
          Text(
            'You can switch workspaces at any time from your profile menu.',
            style: lineStyle,
          ),
        ],
      ),
    );
  }
}
