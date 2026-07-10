import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Redirects page: a compact, centred return panel shown
/// after a user comes back from an external identity provider. It sets
/// expectations and offers a single, same-tab call to action to continue.
class RedirectsDemo extends StatelessWidget {
  const RedirectsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    return DsFocusView(
      title: 'Almost done',
      footer: DsButton(
        label: 'Return to Acme',
        icon: DsIcons.arrowForward,
        onPressed: () {},
      ),
      child: Text(
        "You'll return here after signing in with your identity provider. "
        'Your session stays open in this tab, so nothing is lost.',
        style: TextStyle(
          fontSize: 16,
          height: 1.5,
          color: tokens.colorSecondaryText,
        ),
      ),
    );
  }
}
