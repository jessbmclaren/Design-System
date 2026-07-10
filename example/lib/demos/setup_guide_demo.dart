import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Setup guide page.
///
/// A floating [DsSetupGuide] caught mid-journey. Business verification has
/// been submitted and sits pending, two tasks are already done, two open
/// to-dos flip done on tap so the cross-off animation plays, and the final
/// task is locked behind verification with a tooltip naming the blocker. The
/// first frame shows the expanded checklist with every state visible; no
/// timers run.
class SetupGuideDemo extends StatefulWidget {
  const SetupGuideDemo({super.key});

  @override
  State<SetupGuideDemo> createState() => _SetupGuideDemoState();
}

class _SetupGuideDemoState extends State<SetupGuideDemo> {
  bool _usersInvited = false;
  bool _rulesSetUp = false;

  @override
  Widget build(BuildContext context) {
    // Align gives the card loose constraints, so it keeps its floating 320dp
    // width instead of stretching to the page.
    return Align(
      alignment: Alignment.topLeft,
      child: DsSetupGuide(
        title: 'Setup guide',
        collapsedSummary: 'Verifying your business',
        tasks: [
          const DsSetupTask(label: 'Verify your business', pending: true),
          const DsSetupTask(label: 'Verify your email', done: true),
          const DsSetupTask(label: 'Add your vehicles', done: true),
          DsSetupTask(
            label: 'Invite users',
            done: _usersInvited,
            animateCrossOff: true,
            onTap: () => setState(() => _usersInvited = true),
          ),
          DsSetupTask(
            label: 'Set up your rules',
            done: _rulesSetUp,
            animateCrossOff: true,
            onTap: () => setState(() => _rulesSetUp = true),
          ),
          const DsSetupTask(
            label: 'Go live',
            locked: true,
            lockedMessage: 'Verify your business to go live',
          ),
        ],
      ),
    );
  }
}
