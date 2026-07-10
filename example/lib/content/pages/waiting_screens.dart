// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Status → Waiting screens.
final PatternPage waitingScreensPage = PatternPage(
  id: 'waiting-screens',
  group: DocGroup.feedback,
  navTitle: 'Waiting screens',
  title: 'Waiting screens',
  description:
      'A waiting screen holds attention while a long-running operation finishes '
      'in the background: generating a report, syncing a large data set, '
      'provisioning a new environment. Unlike an inline spinner, it takes over '
      'the region a person is looking at, so it must earn that space: name the '
      'work in progress, set a realistic expectation for how long it will take '
      'and offer a way forward. Centre a large `DsSpinner` above a short title '
      'and a supporting line, and pair it with an action that either advances '
      'the task, gives context or lets the person step away and be notified '
      'when it is done.',
  hasLiveDemo: true,
  blocks: const [
    ProseBlock(
      'Wherever the outcome is delivered asynchronously, let people leave. If '
      'the work continues on the server and you can notify them on completion, '
      'say so plainly and keep the rest of the product usable. A waiting screen '
      'should rarely be a dead end. Reserve a blocking, full-region wait for the '
      'cases where continuing without the result genuinely is not possible.',
    ),
  ],
  dos: const [
    'State clearly what is happening and roughly how long it will take.',
    'Only offer actions that move the task forward or give useful context.',
    'Let people leave and come back when the result can be delivered later.',
    'Tell people when they will be notified so they know they can stop watching.',
    'Match the spinner size to the scope: use a large spinner for a full region.',
  ],
  donts: const [
    'Don\'t leave a bare spinner on screen with no title or explanation.',
    'Don\'t add actions that have nothing to do with advancing the task.',
    'Don\'t imply someone must sit and wait when the work runs in the background.',
    'Don\'t promise a precise duration you cannot reliably meet.',
  ],
  code: '''
Container(
  padding: const EdgeInsets.all(32),
  decoration: BoxDecoration(
    color: tokens.formBackgroundColor,
    border: Border.all(color: tokens.colorBorder),
    borderRadius: BorderRadius.circular(tokens.overlayBorderRadius),
  ),
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const DsSpinner(size: DsSpinnerSize.large),
      const SizedBox(height: 20),
      Text('Preparing your report',
          style: DsTypography.headingSm.toTextStyle(color: tokens.colorText)),
      const SizedBox(height: 8),
      Text(
        'This can take up to a minute. You can keep working and '
        'we\\'ll notify you when it\\'s ready.',
        textAlign: TextAlign.center,
        style: DsTypography.bodySm.toTextStyle(
          color: tokens.colorSecondaryText,
        ),
      ),
      const SizedBox(height: 24),
      DsButton(
        label: 'Cancel',
        variant: DsButtonVariant.secondary,
        onPressed: () {},
      ),
    ],
  ),
);
''',
  shots: const [
    Shot(pageId: 'waiting-screens', size: ShotSize.desktop),
    Shot(pageId: 'waiting-screens', size: ShotSize.phone),
  ],
  related: ['loading', 'onboarding', 'redirects'],
);
