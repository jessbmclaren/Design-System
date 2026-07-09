import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Onboarding wizard page: a three-step account setup flow
/// built with `DsOnboardingWizard`. It starts on the middle "Team" step so a
/// single captured frame shows a completed step behind, an upcoming step
/// ahead, both Back and Next actions, and a "Step X of N" footer caption.
///
/// The wizard is a controlled component, so this demo keeps `currentIndex` in
/// local state and advances or retreats via `setState`. The fields are seeded
/// with realistic values; nothing here uses timers, animation or the network.
class OnboardingWizardDemo extends StatefulWidget {
  const OnboardingWizardDemo({super.key});

  @override
  State<OnboardingWizardDemo> createState() => _OnboardingWizardDemoState();
}

class _OnboardingWizardDemoState extends State<OnboardingWizardDemo> {
  static const _lastStep = 2;

  // Start mid-flow so the header shows a done, current and upcoming step.
  int _step = 1;

  // Seed the fields so a captured frame shows meaningful content.
  final _legalName = TextEditingController(text: 'Northwind Analytics Ltd');
  final _website = TextEditingController(text: 'northwind.co');
  final _teamSize = TextEditingController(text: '12');
  final _inviteEmail = TextEditingController(text: 'ops@northwind.co');
  final _workspace = TextEditingController(text: 'Northwind');
  final _timezone = TextEditingController(text: 'Europe/London');

  @override
  void dispose() {
    _legalName.dispose();
    _website.dispose();
    _teamSize.dispose();
    _inviteEmail.dispose();
    _workspace.dispose();
    _timezone.dispose();
    super.dispose();
  }

  void _back() => setState(() => _step -= 1);

  void _next() => setState(() => _step = (_step + 1).clamp(0, _lastStep));

  @override
  Widget build(BuildContext context) {
    const steps = [
      DsWizardStep(label: 'Company'),
      DsWizardStep(label: 'Team'),
      DsWizardStep(label: 'Preferences'),
    ];

    return SizedBox(
      height: 460,
      child: DsOnboardingWizard(
        steps: steps,
        currentIndex: _step,
        title: _titles[_step],
        subtitle: _subtitles[_step],
        onBack: _step == 0 ? null : _back,
        onNext: _step == _lastStep ? () {} : _next,
        nextLabel: _step == _lastStep ? 'Finish' : 'Continue',
        footerLeading: Text(
          'Step ${_step + 1} of ${steps.length}',
          style: DsTokens.of(context).bodySm.toTextStyle(
                color: DsTokens.of(context).colorSecondaryText,
              ),
        ),
        child: _buildStep(),
      ),
    );
  }

  static const _titles = [
    'Tell us about your company',
    'Invite your team',
    'Set your preferences',
  ];

  static const _subtitles = [
    'We use this to set up your workspace.',
    'Add the people who will work alongside you.',
    'You can change any of this later in Settings.',
  ];

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return DsFormFieldGroup(
          legend: 'Company details',
          columns: 1,
          children: [
            DsTextField(label: 'Legal name', controller: _legalName),
            DsTextField(
              label: 'Website',
              hintText: 'company.com',
              controller: _website,
            ),
          ],
        );
      case 1:
        return DsFormFieldGroup(
          legend: 'Team',
          description: 'We only use this to size your plan.',
          columns: 1,
          children: [
            DsTextField(
              label: 'Team size',
              keyboardType: TextInputType.number,
              controller: _teamSize,
            ),
            DsTextField(
              label: 'Invite by email',
              hintText: 'name@company.com',
              keyboardType: TextInputType.emailAddress,
              controller: _inviteEmail,
            ),
          ],
        );
      default:
        return DsFormFieldGroup(
          legend: 'Preferences',
          columns: 1,
          children: [
            DsTextField(label: 'Workspace name', controller: _workspace),
            DsTextField(label: 'Time zone', controller: _timezone),
          ],
        );
    }
  }
}
