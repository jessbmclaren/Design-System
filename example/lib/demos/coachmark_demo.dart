import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Coachmark page: a short three-step guided tour rendered
/// with [DsCoachmark]. The primary action moves the tour forward, the
/// secondary skips it, and the header close dismisses it. When the tour ends
/// or is dismissed a compact button restarts it, so the demo always shows a
/// meaningful state and never leaves an empty frame.
class CoachmarkDemo extends StatefulWidget {
  const CoachmarkDemo({super.key});

  @override
  State<CoachmarkDemo> createState() => _CoachmarkDemoState();
}

class _CoachmarkDemoState extends State<CoachmarkDemo> {
  static const _steps = <_TourStep>[
    _TourStep(
      title: 'Filter your results',
      body: 'Narrow the list to just what you need before you export.',
    ),
    _TourStep(
      title: 'Save a view',
      body: 'Keep a set of filters as a named view you can return to.',
    ),
    _TourStep(
      title: 'Export in one tap',
      body: 'Send the filtered view to a report whenever you are ready.',
    ),
  ];

  int _step = 0;
  bool _dismissed = false;

  void _next() {
    setState(() {
      if (_step < _steps.length - 1) {
        _step++;
      } else {
        _dismissed = true;
      }
    });
  }

  void _dismiss() => setState(() => _dismissed = true);

  void _restart() => setState(() {
        _step = 0;
        _dismissed = false;
      });

  @override
  Widget build(BuildContext context) {
    if (_dismissed) {
      return Align(
        alignment: Alignment.centerLeft,
        child: DsButton(
          label: 'Show me around',
          onPressed: _restart,
          variant: DsButtonVariant.secondary,
        ),
      );
    }

    final isLast = _step == _steps.length - 1;
    final step = _steps[_step];

    return Align(
      alignment: Alignment.centerLeft,
      child: DsCoachmark(
        title: step.title,
        body: step.body,
        stepIndex: _step,
        stepCount: _steps.length,
        primaryActionLabel: isLast ? 'Got it' : 'Next',
        onPrimary: _next,
        secondaryActionLabel: 'Skip',
        onSecondary: _dismiss,
        onDismiss: _dismiss,
      ),
    );
  }
}

class _TourStep {
  const _TourStep({required this.title, required this.body});

  final String title;
  final String body;
}
