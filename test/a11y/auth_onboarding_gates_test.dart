import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// Systematic gates over the auth and onboarding surface.
///
/// One shared list of named builders feeds two sweeps:
///
/// 1. **Text-scale gate**: every surface renders at 320dp under a 1.3x
///    [TextScaler] with zero overflow exceptions. Surfaces with their own
///    1.3x tests are still swept here, so a regression introduced by
///    composition is caught in one place.
/// 2. **Reduce-motion gate**: the same surfaces pumped with
///    `disableAnimations: true` must settle to a still frame (no transient
///    frame callbacks) within a bounded budget, both on first build and
///    after the surface's single state interaction where it has one.
///
/// Every case is deterministic: no timers, no network, no randomness.
void main() {
  const settleStep = Duration(milliseconds: 100);
  const settleBudget = Duration(seconds: 5);

  // --- Text-scale gate ------------------------------------------------------

  for (final gate in _cases()) {
    testWidgets('${gate.name} survives 1.3x text scale at 320dp',
        (tester) async {
      await pumpDs(
        tester,
        SizedBox(width: 320, child: gate.build()),
        surfaceSize: const Size(320, 1200),
        textScale: 1.3,
      );
      await tester.pump();
      if (gate.interact != null) {
        await gate.interact!(tester);
        // Let any transition run out so the post-interaction state is the
        // one measured for overflow.
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
      }
      expect(tester.takeException(), isNull, reason: gate.name);
    });
  }

  // --- Reduce-motion gate ---------------------------------------------------

  for (final gate in _cases()) {
    testWidgets('${gate.name} settles under reduced motion', (tester) async {
      await pumpDs(
        tester,
        MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: SizedBox(width: 320, child: gate.build()),
        ),
        surfaceSize: const Size(320, 1200),
      );
      await tester.pumpAndSettle(
        settleStep,
        EnginePhase.sendSemanticsUpdate,
        settleBudget,
      );
      expect(
        tester.binding.transientCallbackCount,
        0,
        reason: '${gate.name} is still animating after its first frame',
      );
      if (gate.interact != null) {
        await gate.interact!(tester);
        await tester.pumpAndSettle(
          settleStep,
          EnginePhase.sendSemanticsUpdate,
          settleBudget,
        );
        expect(
          tester.binding.transientCallbackCount,
          0,
          reason: '${gate.name} is still animating after its interaction',
        );
      }
      expect(tester.takeException(), isNull, reason: gate.name);
    });
  }
}

/// One auth or onboarding surface swept by both gates.
///
/// [build] returns a fresh tree on every call so no state leaks between the
/// sweeps, and [interact] performs the surface's single state interaction
/// where it has one (expanding a reveal, advancing a step, toggling a
/// switch). Controlled components get a tiny [StatefulBuilder] harness so the
/// interaction really changes state.
class _GateCase {
  const _GateCase(this.name, this.build, {this.interact});

  final String name;
  final Widget Function() build;
  final Future<void> Function(WidgetTester tester)? interact;
}

List<_GateCase> _cases() => <_GateCase>[
      _GateCase(
        'DsSignUpView',
        () => DsSignUpView(
          header: const DsWordmark(primary: 'acme', accent: 'id'),
          title: 'Create your account',
          description: 'Start your 14-day trial. No card required.',
          onClose: () {},
          aboveForm: const Text('Already have an account? Sign in instead.'),
          form: const DsFormFieldGroup(
            columns: 1,
            children: <Widget>[
              DsTextField(label: 'Full name'),
              DsTextField(label: 'Work email address'),
              DsTextField(label: 'Password', obscureText: true),
            ],
          ),
          primaryActionLabel: 'Create account',
          onSubmit: () {},
          footer: const Text('By continuing you accept the terms of use.'),
        ),
      ),
      _GateCase(
        'DsSignInView',
        () => DsSignInView(
          title: 'Welcome back',
          description: 'Sign in to continue to your workspace.',
          form: const Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              DsTextField(label: 'Work email address'),
              SizedBox(height: 12),
              DsTextField(label: 'Password', obscureText: true),
            ],
          ),
          primaryAction: DsSignInAction(label: 'Sign in', onPressed: () {}),
          footerBand: const Text('New here? Create an account.'),
          additionalContextLabel: 'More ways to sign in',
          additionalContext: const Text(
            'Single sign-on is available on the Business plan. Ask your '
            'administrator for your workspace address.',
          ),
        ),
        // Expand the additional-context reveal.
        interact: (tester) => tester.tap(find.byIcon(DsIcons.expandMore)),
      ),
      _GateCase(
        'DsSetupGuide',
        () => DsSetupGuide(
          title: 'Setup guide',
          tasks: <DsSetupTask>[
            const DsSetupTask(label: 'Verify your email address', done: true),
            const DsSetupTask(
              label: 'Set a strong password',
              done: true,
              animateCrossOff: true,
            ),
            const DsSetupTask(
              label: 'Submit your business details',
              pending: true,
            ),
            DsSetupTask(label: 'Add your first vehicle', onTap: () {}),
            const DsSetupTask(label: 'Invite a teammate'),
            const DsSetupTask(
              label: 'Go live',
              locked: true,
              lockedMessage: 'Verify your business to go live',
            ),
          ],
        ),
        // Toggle the disclosure header.
        interact: (tester) => tester.tap(find.text('Setup guide')),
      ),
      _GateCase(
        'DsPasswordStrength with hint',
        () => const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            DsPasswordStrength(value: 'summer'),
            SizedBox(height: 8),
            DsPasswordStrengthHint(value: 'summer'),
          ],
        ),
      ),
      _GateCase(
        'DsFooterActions',
        () => DsFooterActions(
          backLabel: 'Back to the previous step',
          onBack: () {},
          primaryLabel: 'Continue to business verification',
          onPrimary: () {},
          tertiaryLabel: 'Save your progress and finish later',
          onTertiary: () {},
        ),
      ),
      _GateCase(
        'DsUploadField (error)',
        () => DsUploadField(
          state: DsUploadFieldState.error,
          errorText: 'The file is larger than 10 MB. Choose a smaller scan '
              'and try again.',
          onRetry: () {},
        ),
      ),
      _GateCase(
        'DsAddressFieldGroup',
        () => DsAddressFieldGroup(
          legend: 'Registered address',
          countries: const <DsSelectOption<String>>[
            DsSelectOption(value: 'BE', label: 'Belgium'),
            DsSelectOption(value: 'NL', label: 'Netherlands'),
          ],
          onChanged: (_) {},
        ),
      ),
      _GateCase(
        'DsVerificationRail (5 sections)',
        () => const DsVerificationRail(
          sections: <DsVerificationSection>[
            DsVerificationSection(
              label: 'Business type',
              state: DsVerificationSectionState.done,
            ),
            DsVerificationSection(
              label: 'Business details',
              state: DsVerificationSectionState.done,
            ),
            DsVerificationSection(
              label: 'Verify identity',
              state: DsVerificationSectionState.active,
              subSteps: <String>['Representative', 'Documents'],
            ),
            DsVerificationSection(label: 'Bank account'),
            DsVerificationSection(label: 'Review and submit'),
          ],
          activeSubStep: 1,
        ),
      ),
      _GateCase(
        'DsBusinessVerification (first step)',
        () => const SizedBox(height: 560, child: DsBusinessVerification()),
        // Advance from the business-type step to business details.
        interact: (tester) => tester.tap(find.text('Continue')),
      ),
      _GateCase(
        'DsOnboardingWizard (two steps)',
        () {
          var step = 0;
          return StatefulBuilder(
            builder: (context, setState) => SizedBox(
              height: 560,
              child: DsOnboardingWizard(
                title: 'Set up your account',
                subtitle: 'A couple of details and you are in.',
                steps: const <DsWizardStep>[
                  DsWizardStep(label: 'Your details'),
                  DsWizardStep(label: 'Confirm'),
                ],
                currentIndex: step,
                onBack: step == 0 ? null : () => setState(() => step -= 1),
                onNext: () => setState(() => step = (step + 1).clamp(0, 1)),
                child: Text('Step ${step + 1} content'),
              ),
            ),
          );
        },
        // Advance to the second step.
        interact: (tester) => tester.tap(find.text('Continue')),
      ),
      _GateCase(
        'DsTourCard (long copy)',
        () {
          var step = 0;
          return StatefulBuilder(
            builder: (context, setState) => DsTourCard(
              steps: const <DsTourStep>[
                DsTourStep(
                  title: 'Import your fleet in one pass',
                  body: 'Upload the spreadsheet you already keep and we match '
                      'each column for you. Nothing is saved until you '
                      'confirm the mapping, so you can try it as often as '
                      'you like without touching your records.',
                ),
                DsTourStep(
                  title: 'Invite the rest of your team',
                  body: 'Everyone you invite sees the same live picture of '
                      'the fleet, and their access is scoped by role, so the '
                      'workshop sees the jobs while the office sees the '
                      'costs.',
                ),
              ],
              currentStep: step,
              onStepChanged: (value) => setState(() => step = value),
              onSkip: () {},
              onDone: () {},
            ),
          );
        },
        // Advance the tour.
        interact: (tester) => tester.tap(find.text('Next')),
      ),
      _GateCase(
        'DsWaitingScreen',
        () => const SizedBox(
          height: 640,
          child: DsWaitingScreen(
            header: DsWordmark(primary: 'acme', accent: 'id'),
            headline: 'Signing you in',
            supportingText: 'This will only take a moment.',
          ),
        ),
      ),
      _GateCase(
        'DsCookieBanner',
        () => DsCookieBanner(
          message: 'We use cookies to keep your account secure and to '
              'understand how the product is used.',
          onAcceptAll: () {},
          onRejectNonEssential: () {},
          onManagePreferences: () {},
        ),
      ),
      _GateCase(
        'DsCookiePreferences (three categories)',
        () {
          var analytics = false;
          var marketing = false;
          return StatefulBuilder(
            builder: (context, setState) => DsCookiePreferences(
              categories: <DsCookieCategory>[
                const DsCookieCategory(
                  id: 'essential',
                  title: 'Essential',
                  description: 'Required to keep you signed in and your '
                      'session secure.',
                  enabled: true,
                  locked: true,
                ),
                DsCookieCategory(
                  id: 'analytics',
                  title: 'Analytics',
                  description: 'Helps us understand which features are used.',
                  enabled: analytics,
                ),
                DsCookieCategory(
                  id: 'marketing',
                  title: 'Marketing',
                  description: 'Lets us tailor messages about new features.',
                  enabled: marketing,
                ),
              ],
              onChanged: (id, enabled) => setState(() {
                if (id == 'analytics') analytics = enabled;
                if (id == 'marketing') marketing = enabled;
              }),
              onSave: () {},
              onAcceptAll: () {},
            ),
          );
        },
        // Toggle the first unlocked category switch.
        interact: (tester) => tester.tap(find.byType(DsSwitch).first),
      ),
      _GateCase(
        'DsAuthShell (hosting a small card)',
        () => SizedBox(
          height: 640,
          child: DsAuthShell(
            header: const DsWordmark(primary: 'acme', accent: 'id'),
            onBack: () {},
            footer: const Text('Terms and privacy'),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Text('Sign in to continue'),
                const SizedBox(height: 16),
                DsButton(label: 'Continue', onPressed: () {}, fullWidth: true),
              ],
            ),
          ),
        ),
      ),
    ];
