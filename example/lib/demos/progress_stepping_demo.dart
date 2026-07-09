import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Progress stepping page: a four-stage `DsProgressStepper`
/// paused on the second step, with a footer that carries a secondary "Back"
/// and a primary "Continue".
///
/// The demo is stateful only so the footer buttons can move between stages;
/// it initialises on the "Billing" step so a single captured frame shows one
/// completed stage, the current stage and two upcoming ones.
class ProgressSteppingDemo extends StatefulWidget {
  const ProgressSteppingDemo({super.key});

  @override
  State<ProgressSteppingDemo> createState() => _ProgressSteppingDemoState();
}

class _ProgressSteppingDemoState extends State<ProgressSteppingDemo> {
  static const _steps = [
    DsStep(label: 'Details'),
    DsStep(label: 'Billing'),
    DsStep(label: 'Review'),
    DsStep(label: 'Done'),
  ];

  int _currentIndex = 1;

  void _goTo(int index) {
    setState(() => _currentIndex = index.clamp(0, _steps.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentIndex == _steps.length - 1;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DsProgressStepper(steps: _steps, currentIndex: _currentIndex),
        const SizedBox(height: 24),
        Row(
          children: [
            DsButton(
              label: 'Back',
              variant: DsButtonVariant.secondary,
              onPressed: _currentIndex == 0 ? null : () => _goTo(_currentIndex - 1),
            ),
            const Spacer(),
            DsButton(
              label: isLast ? 'Finish' : 'Continue',
              onPressed: isLast ? () {} : () => _goTo(_currentIndex + 1),
            ),
          ],
        ),
      ],
    );
  }
}
