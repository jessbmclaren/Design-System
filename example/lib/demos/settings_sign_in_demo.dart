import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Settings sign in page.
///
/// The settings surface is gated on the connection state. While [_signedIn]
/// is false a compact [DsSignInView] invites the user to connect; once true a
/// small settings panel appears. The toggle button flips the state so a single
/// captured frame reads as intentional. Initialises signed-out.
class SettingsSignInDemo extends StatefulWidget {
  const SettingsSignInDemo({super.key});

  @override
  State<SettingsSignInDemo> createState() => _SettingsSignInDemoState();
}

class _SettingsSignInDemoState extends State<SettingsSignInDemo> {
  bool _signedIn = false;

  @override
  Widget build(BuildContext context) {
    if (!_signedIn) {
      return DsSignInView(
        brandIcon: Icons.hub_outlined,
        title: 'Connect your account',
        description: 'Sign in to manage this integration\'s settings.',
        primaryAction: DsSignInAction(
          label: 'Connect account',
          onPressed: () => setState(() => _signedIn = true),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DsBadge(label: 'Connected', variant: DsBadgeVariant.success),
        const SizedBox(height: 16),
        const DsList(
          bordered: true,
          children: [
            DsListItem(
              leading: Icon(Icons.sync),
              title: 'Sync frequency',
              subtitle: 'Every 15 minutes',
            ),
            DsListItem(
              leading: Icon(Icons.notifications_none),
              title: 'Notifications',
              subtitle: 'Enabled',
            ),
          ],
        ),
        const SizedBox(height: 16),
        DsButton(
          label: 'Disconnect',
          variant: DsButtonVariant.secondary,
          onPressed: () => setState(() => _signedIn = false),
        ),
      ],
    );
  }
}
