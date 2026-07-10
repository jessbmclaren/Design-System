import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Settings view page.
///
/// Renders a real [DsSettingsView] built from three titled
/// [DsSettingsSection]s: an account section with static value rows, a
/// notifications section whose rows carry [DsSwitch] controls, and a security
/// section with a navigational row and a destructive footer action. The
/// toggles start in a meaningful mixed state and flip via [setState], so a
/// single captured frame reads as an intentional, configured page.
class SettingsViewDemo extends StatefulWidget {
  const SettingsViewDemo({super.key});

  @override
  State<SettingsViewDemo> createState() => _SettingsViewDemoState();
}

class _SettingsViewDemoState extends State<SettingsViewDemo> {
  bool _productUpdates = true;
  bool _weeklyDigest = false;
  bool _securityAlerts = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 460,
      child: DsSettingsView(
        header: const Text(
          'Settings',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        sections: [
          const DsSettingsSection(
            title: 'Account',
            description: 'Manage how your team signs in and gets reached.',
            children: [
              DsListItem(
                leading: Icon(DsIcons.mail),
                title: 'Email',
                subtitle: 'avery@northwind.io',
              ),
              DsListItem(
                leading: Icon(DsIcons.workspace),
                title: 'Workspace',
                subtitle: 'Northwind Labs',
              ),
            ],
          ),
          DsSettingsSection(
            title: 'Notifications',
            description: 'Choose which updates land in your inbox.',
            children: [
              DsListItem(
                leading: const Icon(DsIcons.announcement),
                title: 'Product updates',
                subtitle: 'New features and improvements',
                trailing: DsSwitch(
                  value: _productUpdates,
                  onChanged: (v) => setState(() => _productUpdates = v),
                ),
              ),
              DsListItem(
                leading: const Icon(DsIcons.report),
                title: 'Weekly digest',
                subtitle: 'A Monday summary of activity',
                trailing: DsSwitch(
                  value: _weeklyDigest,
                  onChanged: (v) => setState(() => _weeklyDigest = v),
                ),
              ),
              DsListItem(
                leading: const Icon(DsIcons.security),
                title: 'Security alerts',
                subtitle: 'Sign-ins from new devices',
                trailing: DsSwitch(
                  value: _securityAlerts,
                  onChanged: (v) => setState(() => _securityAlerts = v),
                ),
              ),
            ],
          ),
          DsSettingsSection(
            title: 'Security',
            children: [
              DsListItem(
                leading: const Icon(DsIcons.password),
                title: 'Password',
                subtitle: 'Last changed 3 months ago',
                onTap: () {},
              ),
              DsListItem(
                leading: const Icon(DsIcons.verified),
                title: 'Two-factor authentication',
                subtitle: 'Authenticator app',
                onTap: () {},
              ),
            ],
          ),
        ],
        footer: DsButton(
          label: 'Sign out',
          variant: DsButtonVariant.secondary,
          onPressed: () {},
        ),
      ),
    );
  }
}
