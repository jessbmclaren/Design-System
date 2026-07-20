import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Sign out page.
///
/// A compact account footer, as it would sit at the foot of a settings panel:
/// a leading avatar, the signed-in name and email, and a trailing secondary
/// "Sign out" button so the action is labelled and easy to find.
class SignOutDemo extends StatelessWidget {
  const SignOutDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    return Row(
      children: [
        const DsAvatar(icon: DsIcons.user),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Jordan Avery',
                style: DsTypography.labelMd.toTextStyle(
                  color: tokens.colorText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'jordan.avery@example.com',
                style: DsTypography.bodySm.toTextStyle(
                  color: tokens.colorSecondaryText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        DsButton(
          label: 'Sign out',
          variant: DsButtonVariant.secondary,
          icon: DsIcons.signOut,
          onPressed: () {},
        ),
      ],
    );
  }
}
