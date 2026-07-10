# LCV auth → Design System: migration build-list

**Goal.** Rebuild the LCV sign-in and sign-up cards on the `Ds*` components instead of the LCV-local kit, keeping the LCV look. LCV is the **source of truth** for behaviour and design intent; the Design System grows to match it. The LCV appearance drives the DS through a `DsTokens` set, so "minus theming" means: same components, LCV's tokens.

## 1. Already mirrored (no build, just theme and swap)

These LCV atoms map straight onto an existing `Ds*` component:

| LCV component | DS component | Note |
|---|---|---|
| `PrimaryButton` | `DsButton` (primary) | direct |
| `SecondaryButton` | `DsButton` (secondary) | direct |
| `AppTextField` | `DsTextField` | direct |
| `LabeledField` | `DsTextField` (`label:`) | label is built in |
| `LabeledCheckbox` | `DsCheckbox` (`label:`) | label is built in |
| `LinkText` | `DsLink` | direct |
| `AdaptiveFieldRow` | `DsFormFieldGroup` | stacks compact, 2-col wide |
| `FieldLabel` | `DsFieldLabel` | now a real atom; `DsTextField` reuses it |

## 2. Build-list (the real gaps)

Four things LCV has and the DS does not. Each is specced from its LCV source.

### 2a. `DsIconButton` — circular flat icon button  ·  new atom
- **Source of truth:** `lib/screens/lcv/atoms/circle_icon_button.dart`
- **Contract:** flat circular `IconButton`; soft fill on hover/focus/press (LCV: `surfaceMuted`); keyboard-focusable; `tooltip` = accessible name; diameter and glyph size default to skin (`controlDiameterMd` / `iconMd`).
- **Build:** `DsIconButton({required IconData icon, required VoidCallback onPressed, required String semanticLabel, double? size, double? iconSize})`. Fill colour from a token (`offsetBackgroundColor` or a new `controlHoverColor`); shape `CircleBorder`; ≥48dp tap target.
- **Effort:** S. Genuinely new, but small and self-contained.

### 2b. `DsButton.social` — provider sign-in button  ·  button variant
- **Source of truth:** `lib/screens/lcv/atoms/social_button.dart`
- **Contract:** full-width neutral-outline button with a **leading provider icon**, label, `onPressed` (null = disabled), optional `iconColor`, `loading`.
- **Build:** a **factory on `DsButton`** (`DsButton.social(icon:, label:, onPressed:, pending:)`) returning a full-width secondary button. It is a variant of the button atom, not a new atom (per the atomic-design review). The glyph inherits the button text colour, so pass a monochrome mark; a brand-coloured logo would need a `leading`-widget slot on `DsButton`.
- **Effort:** XS. No enabling change needed.

### 2c. `DsWordmark` — two-tone product wordmark  ·  new atom + tokens
- **Source of truth:** `lib/screens/lcv/atoms/brand_wordmark.dart`
- **Contract:** `Text.rich` of a primary part + accent suffix at different weights; **all strings, colour, weights come from the skin** (`wordmarkPrimary`, `wordmarkAccent`, `wordmarkWeightPrimary/Accent`, `brandInk`, `trackingTight`).
- **Build:** this is the most theme-bound. Two options:
  - **Token-driven (matches DS philosophy):** add wordmark tokens to `DsTokens` (`wordmarkPrimary`, `wordmarkAccent`, two weights, tracking) and `DsWordmark({double fontSize})` reads them. A re-brand re-marks everywhere.
  - **Param-driven (simpler):** `DsWordmark({required String primary, required String accent, ...})`. Less "white-label", more portable.
- **Effort:** M (mostly the token additions + light/dark defaults).

### 2d. Password: input toggle + strength  ·  split into two
- **Source of truth:** `lib/screens/lcv/molecules/password_field.dart` and `password_strength.dart`
- **2d-i · `DsPasswordField`** — `DsTextField` with a show/hide **eye toggle** in the suffix. **Verified:** `DsTextField` already has a `suffixIcon` slot, so this just drops an eye `IconButton` in — no change to `DsTextField`. API mirrors LCV: `controller, hintText, validator, textInputAction, onChanged, onSubmitted, autofocus, enabled, autovalidateMode`. **Effort:** S.
- **2d-ii · `DsPasswordStrength`** — the rules + meter the DS has no answer for today. Port `checkPassword` (5 rules), `passwordMeetsAll`, and `PasswordTier` (with the common-word / pattern downgrade heuristics) as a pure model, plus a checklist/meter widget. **Effort:** M. Keep the model Flutter-free so it's testable and reusable.

## 3. Theming bridge (the "minus theming" part)

The DS is white-label; LCV re-skins it by building a `DsTokens` from `LcvAppearance`:

- colours: `a.surface → formBackgroundColor`, `a.outlineVariant → colorBorder`, `a.brandInk`/primary → `buttonPrimaryColorBackground` + `formAccentColor`, `a.onSurface → colorText`, etc.
- shape/space: `a.borderRadius → borderRadius`/`formBorderRadius`, spacing steps → `spacingUnit`.
- type: `a.fontFamily`, the heading/body/label ramps → the `Ds*` type tokens.
- new for the build-list: wordmark tokens (2c).

Wire it once as `DsTheme.light(tokens: lcvTokens(appearance))`; every migrated card then reads LCV's look with zero per-widget theming.

## 4. Suggested order

1. Theming bridge (`lcvTokens`) + prove one migrated field renders in LCV skin.
2. `DsButton` audit → leading-icon + pending (enables `DsSocialButton`).
3. `DsTextField` suffix slot → `DsPasswordField`.
4. `DsIconButton`, `DsSocialButton` (small).
5. `DsWordmark` + wordmark tokens.
6. `DsPasswordStrength` model + meter.
7. Rebuild `SignInCard` / `SignUpCard` on `Ds*`; delete the superseded LCV atoms; update the LCV kit-matrix + `COMPONENTS.md`.

## 5. Verify at each step
- `flutter analyze` (both packages) + the DS atom tests.
- LCV `lcv_kit_matrix_test`, `lcv_onboarding_flow_smoke_test`, `lcv_components_doc_guard_test` stay green (update `COMPONENTS.md` as atoms are retired).
