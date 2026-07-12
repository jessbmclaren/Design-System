# Business verification

Business verification collects the facts you need to confirm an organisation and the person acting for it, split across four short, ordered steps: business type, business details, representative identity, then a review before submitting. `DsBusinessVerification` composes existing building blocks. The progress stepper, title and Back / Continue actions come from `DsOnboardingWizard`, and each step body is assembled from `DsFormFieldGroup`, `DsSelect`, `DsTextField`, `DsAddressFieldGroup` and `DsCheckbox`, so it stays visually consistent with the rest of your forms. It owns every entered value in local state, so moving back never loses input and the review step always reads back the latest answers. Advancing past the identity step is gated on an authorisation consent checkbox, and submitting swaps the flow for a static success confirmation and fires `onSubmitted`.

The flow extends without forking. `onClose` adds a takeover-style header above the wizard (a corner close affordance, a hairline divider and the flow title, the same pattern as the auth cards). `stepBodyBuilder` appends fields or validators to any step, or replaces a step body entirely. The identity step gains a `DsUploadField` document slot when `uploadState` is set, driven wholly by the caller. The registered address is structured through `DsAddressFieldGroup`, tuned per market with `addressCountries` and `addressConfig`. Finally, `showReceipt` swaps the immediate success confirmation for a receipt with a primary continue action, and `onSubmitted` then waits for that action (closing from the receipt also completes, since the submission has already happened).

The details step reframes itself for the selected type. List the types through `businessTypeOptions`, name the ones that verify on a personal identifier in `unregisteredValues`, and give `registeredCopy` and `unregisteredCopy` the wording each calls for. The flow relabels the name field, the identifier field and the address legend as the type changes, and clears the identifier when a change crosses the divide, since the number means something different on each side. The address block takes `addressRegionOptions` for a province or state picker and `addressCountryReadback` to state a single market rather than ask for it, while `roleOptions` adds a role select to the identity step. A `legalNameValidator`, and validators carried on the copy, hold Continue until the step is valid. The receipt badge is a green success by default; where verification runs on in the background, pass `receiptBadgeTone: DsIconBadgeTone.brandSoft` so it reads as work in progress rather than an approval.

![Desktop (1120dp)](img/business-verification_desktop.png)

*Desktop (1120dp)*

![Small phone (320dp)](img/business-verification_phone.png)

*Small phone (320dp)*

## Guidelines

**Do**

- Order steps from least to most sensitive: classify the business first, then details, then who is completing the check.
- Ask the user to enter names and numbers exactly as they appear on official registration so the values are verifiable.
- Gate the identity step on the authorisation checkbox so only someone confirming they can act for the business proceeds.
- Keep the review step honest: read back every entered value, including a clear "Not confirmed" when consent is missing.
- Give the flow a bounded height (the wizard fills the space it is given and scrolls its body when room is tight).
- Wire `onSubmitted` to your backend submission and `onCancel` to dismiss the flow from its first step.
- Prefer `showReceipt` when verification runs asynchronously; the receipt sets expectations before the user moves on.
- Keep market specifics (the types, provinces, validators and copy) in your app; the flow stays neutral and re-skins by theme.

**Don't**

- Don't ask for information you will not verify; every extra field slows the user and lowers completion.
- Don't let users submit before the authorisation consent is ticked; the identity step blocks advancing until it is.
- Don't rebuild the fields, stepper or action bar by hand; compose the flow so it inherits Design System behaviour.
- Don't place the flow in an unbounded-height parent; the wizard body is an `Expanded` scroll view and needs a bounded height.
- Don't run the document upload inside the organism; own the state machine in your app and pass it down.

## Example

```dart
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
```

## See also

- [Onboarding wizard](onboarding-wizard.md)
- [Sign up](sign-up.md)
- [Address field group](address-field-group.md)
- [Upload field](upload-field.md)
- [Verification rail](verification-rail.md)
