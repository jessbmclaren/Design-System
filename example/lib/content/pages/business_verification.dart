// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Onboarding → Business verification.
final PatternPage businessVerificationPage = PatternPage(
  id: 'business-verification',
  group: DocGroup.patterns,
  navTitle: 'Business verification',
  title: 'Business verification',
  description:
      'Business verification collects the facts you need to confirm an '
      'organisation and the person acting for it, split across four short, '
      'ordered steps: business type, business details, representative '
      'identity, then a review before submitting. `DsBusinessVerification` '
      'composes existing building blocks. The progress stepper, title and '
      'Back / Continue actions come from `DsOnboardingWizard`, and each step '
      'body is assembled from `DsFormFieldGroup`, `DsSelect`, `DsTextField`, '
      '`DsAddressFieldGroup` and `DsCheckbox`, so it stays visually '
      'consistent with the rest of your forms. It owns every entered value '
      'in local state, so moving back never loses input and the review step '
      'always reads back the latest answers. Advancing past the identity '
      'step is gated on an authorisation consent checkbox, and submitting '
      'swaps the flow for a static success confirmation and fires '
      '`onSubmitted`.',
  hasLiveDemo: true,
  blocks: const [
    ProseBlock(
      'The flow extends without forking. `onClose` adds a takeover-style '
      'header above the wizard (a corner close affordance, a hairline '
      'divider and the flow title, the same pattern as the auth cards). '
      '`stepBodyBuilder` appends fields or validators to any step, or '
      'replaces a step body entirely. The identity step gains a '
      '`DsUploadField` document slot when `uploadState` is set, driven '
      'wholly by the caller. The registered address is structured through '
      '`DsAddressFieldGroup`, tuned per market with `addressCountries` and '
      '`addressConfig`. Finally, `showReceipt` swaps the immediate success '
      'confirmation for a receipt with a primary continue action, and '
      '`onSubmitted` then waits for that action (closing from the receipt '
      'also completes, since the submission has already happened).',
    ),
  ],
  dos: const [
    'Order steps from least to most sensitive: classify the business first, then details, then who is completing the check.',
    'Ask the user to enter names and numbers exactly as they appear on official registration so the values are verifiable.',
    'Gate the identity step on the authorisation checkbox so only someone confirming they can act for the business proceeds.',
    'Keep the review step honest: read back every entered value, including a clear "Not confirmed" when consent is missing.',
    'Give the flow a bounded height (the wizard fills the space it is given and scrolls its body when room is tight).',
    'Wire `onSubmitted` to your backend submission and `onCancel` to dismiss the flow from its first step.',
    'Prefer `showReceipt` when verification runs asynchronously; the receipt sets expectations before the user moves on.',
  ],
  donts: const [
    'Don\'t ask for information you will not verify; every extra field slows the user and lowers completion.',
    'Don\'t let users submit before the authorisation consent is ticked; the identity step blocks advancing until it is.',
    'Don\'t rebuild the fields, stepper or action bar by hand; compose the flow so it inherits Design System behaviour.',
    'Don\'t place the flow in an unbounded-height parent; the wizard body is an `Expanded` scroll view and needs a bounded height.',
    'Don\'t run the document upload inside the organism; own the state machine in your app and pass it down.',
  ],
  code: '''
DsBusinessVerification(
  onClose: () => Navigator.of(context).maybePop(),
  addressCountries: const [
    DsSelectOption(value: 'BE', label: 'Belgium'),
    DsSelectOption(value: 'NL', label: 'Netherlands'),
  ],
  uploadState: _uploadState,
  uploadProgress: _uploadProgress,
  uploadFileName: _fileName,
  onUploadPick: _pickDocument,
  onUploadRetry: _pickDocument,
  onUploadRemove: _removeDocument,
  showReceipt: true,
  onSubmitted: () {
    // Fires when the user continues from the receipt.
    _finishVerification();
  },
  onCancel: () {
    // Backing out of the first step dismisses the flow.
    Navigator.of(context).maybePop();
  },
);
''',
  shots: const [
    Shot(pageId: 'business-verification', size: ShotSize.desktop),
    Shot(pageId: 'business-verification', size: ShotSize.phone),
  ],
  related: [
    'onboarding-wizard',
    'sign-up',
    'address-field-group',
    'upload-field',
    'verification-rail',
  ],
);
