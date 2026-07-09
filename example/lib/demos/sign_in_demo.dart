import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Sign in page: a branded [DsSignInView] with a single
/// primary action and a sign-up prompt in the footer.
class SignInDemo extends StatelessWidget {
  const SignInDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    return DsSignInView(
      brandIcon: Icons.hexagon_rounded,
      brandColor: const Color(0xFF6D28D9),
      title: 'Sign in to Acme',
      description:
          'Access your dashboards, records and reports. '
          "We'll take you to a secure page to continue.",
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
          InkWell(
            onTap: () {},
            child: Text(
              'Sign up',
              style: DsTypography.labelMd.toTextStyle(
                color: tokens.actionPrimaryColorText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
