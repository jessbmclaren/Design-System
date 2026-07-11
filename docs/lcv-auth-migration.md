# Host app auth to Design System: migration build-list

**Goal.** Rebuild the host app's sign-in and sign-up cards on the `Ds*` components instead of its local kit, keeping the host look. The host app is the **source of truth** for behaviour and design intent; the Design System grows to match it. The host appearance drives the DS through a `DsTokens` set, so "minus theming" means: same components, the host's tokens.

**Status, July 2026.** Every item on the original build-list has shipped in the Design System, verified against the working tree. The two open ends are host-side: wiring the appearance-to-tokens bridge and swapping the cards in the host repo.

## 1. Already mirrored (no build, just theme and swap). Done.

These host atoms map straight onto an existing `Ds*` component:

| Host component | DS component | Note |
|---|---|---|
| `PrimaryButton` | `DsButton` (primary) | direct |
| `SecondaryButton` | `DsButton` (secondary) | direct |
| `AppTextField` | `DsTextField` | direct |
| `LabeledField` | `DsTextField` (`label:`) | label is built in |
| `LabeledCheckbox` | `DsCheckbox` (`label:`) | label is built in |
| `LinkText` | `DsLink` | direct |
| `AdaptiveFieldRow` | `DsFormFieldGroup` | stacks compact, 2-col wide |
| `FieldLabel` | `DsFieldLabel` | a real atom; `DsTextField` reuses it |

All eight are present in `lib/src/components/`.

## 2. Build-list status

### 2a. `DsIconButton`, circular flat icon button. Done.

Shipped at `lib/src/components/atoms/ds_icon_button.dart` as specced: a flat circular button with a soft fill on hover, focus and press. `size` (default 40) and `iconSize` have sensible defaults and the hit area is padded out to the 48dp accessible minimum. `semanticLabel` is required and becomes the button's tooltip, which is also the name screen readers announce.

### 2b. `DsButton.social`, provider sign-in button. Done.

A factory on `DsButton`, as the atomic-design review asked: full-width with a leading provider `icon`, `onPressed` (null disables) and `pending`. One deviation from the spec: it returns the neutral variant rather than secondary, so provider buttons read as equals below the primary action. The glyph inherits the button text colour, so pass a monochrome mark.

### 2c. `DsWordmark`, two-tone product wordmark. Done, via the param-driven option.

`DsWordmark({required String primary, String? accent, double fontSize, Color? color})` sets the two parts at fixed weights and inherits family and colour from the active theme. The token-driven option was not taken: no wordmark tokens were added to `DsTokens`. A brand that keeps its name in its own theme builds the wordmark there and passes the parts down, so a re-brand still updates every mark at once.

### 2d. Password: input toggle + strength. Both done.

- **2d-i `DsPasswordField`. Done.** The show/hide eye toggle sits in the `DsTextField` suffix as planned, with no change to `DsTextField`. The API grew past the spec during hardening: `label`, `helperText`, `errorText`, `focusNode` and a `newPassword` flag that switches the autofill hint, with autocorrect and keyboard suggestions off so password managers stay in charge.
- **2d-ii `DsPasswordStrength`. Done.** The model is pure Dart and exported alongside the widgets: `dsPasswordRules` (the five rules), `dsPasswordMeetsAll`, `dsFirstUnmetPasswordRule` for one-error-at-a-time captions and `dsPasswordTier`, which grades into `DsPasswordTier` with the common-word and pattern downgrades plus a `brandWords` hook for product-specific terms. The rules are unicode-aware and length counts grapheme clusters. On top sit the meter, the checklist and `DsPasswordStrengthHint`.

## 3. Theming bridge. Partial: DS side ready, host wiring open.

The DS half is in place. The token tiers are complete (colour, shape, space, type, elevation and tracking), `DsTheme.light(tokens: ...)` and `DsTheme.dark(tokens: ...)` apply a set app-wide and `DsSkins` bundles a full partner skin in light and dark as proof that a re-skin needs no per-widget theming. The mapping itself, building a `DsTokens` from the host appearance (surface to `formBackgroundColor`, outline to `colorBorder`, brand ink to `buttonPrimaryColorBackground` and `formAccentColor`, radius and spacing steps, the type ramp), lives in the host repo and is not verifiable from this one.

## 4. Rebuild of the cards. Partial: DS side done, host swap open.

`DsSignInView` and `DsSignUpView` shipped as organisms and the docs demos are rebuilt on the full kit. The sign-in is form-led, with the forgot-password link on the password label row, a remember-me checkbox, social buttons behind a labelled divider and a tinted footer band. The sign-up card adds live validation, the strength meter and a pending submit. The host-side steps remain in the host repo: rebuild its two cards on `Ds*`, delete the superseded local atoms and update its kit matrix and components doc.

## 5. What shipped beyond the original list

The migration pulled in the surfaces around the two cards, so the kit now covers the whole onboarding journey:

- **Setup guide.** `DsSetupGuide`, a collapsible first-run checklist with a done count, an animated progress bar and per-task open, pending, locked and done states.
- **Auth shell.** `DsAuthShell`, the full-page frame for the flow: backdrop, pinned header, legal-link footer, a banner slot and a hero split-pane at the expanded breakpoint.
- **Takeover.** `DsTakeover`, one card over a blurred, scrimmed and fully inert copy of the page behind it, for gates such as email verification.
- **Waiting screen.** `DsWaitingScreen`, the provisioning moment: a large spinner, an animated-ellipsis headline, an optional header slot and a gradient backdrop, with no timers of its own.
- **Tour card.** `DsTourCard`, a controlled stepped walkthrough with per-step illustrations, keyboard navigation and optional swipe.
- **Cookie consent.** `DsCookieBanner`, the three-action consent bar announced as a polite live region, and `DsCookiePreferences`, the per-category surface usually hosted in a takeover.
- **Verification kit.** `DsBusinessVerification`, a four-step organisation and representative flow on the wizard chrome, and `DsVerificationRail`, the sectioned progress rail that summarises itself when narrow.
- **Footer actions.** `DsFooterActions`, the shared Back and Continue cluster used by the wizard and the onboarding surfaces, laid out as a row or a stack by its own measured width.
- **Expert-tester hardening.** A five-surface probe sweep (154 probes, kept under `test/probes/`) drove the kit through interrupted animations, unicode passwords, 2x text scale on a 320dp phone, keyboard-only runs and screen-reader traversal. The thirty-five confirmed defects are fixed and each probe now asserts the corrected behaviour.

## 6. Verify at each step

- `flutter analyze` and the component tests here, including the probe suites under `test/probes/`.
- On the host side, its kit-matrix, onboarding-flow smoke and components-doc guard tests stay green, with its components doc updated as atoms are retired.
