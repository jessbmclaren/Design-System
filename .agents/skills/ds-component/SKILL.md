---
name: ds-component
description: Scaffold or finish a Design System component to this repo's definition of done — the component file, its tests, a content-model doc page, the barrel export, the README table row and regenerated docs. Use when adding a new Ds* component or bringing an existing one up to standard.
---

# Add or finish a Ds component

Follow every step. A component is not done until all of them pass. See `AGENTS.md` for the atomic-design, token, accessibility and writing-style rules this depends on.

## 1. Place it (atomic design)

Decide the level first: an **atom** is an indivisible control, a **molecule** is a small bond of atoms with one job, an **organism** is a standalone section. A preset of an existing atom is a **variant** (a factory such as `DsButton.social`), not a new atom. The file lives at `lib/src/components/<layer>/ds_<name>.dart`.

## 2. Write the component

- `Ds` prefix, one component per file, a `const` constructor where possible.
- Read all appearance from `DsTokens.of(context)`: colours, `spacingUnit`, `shadowLow` / `shadowMedium` / `shadowHigh`, the type ramp (`headingLg`, `bodyMd`, …). Never hardcode a colour, size or shadow, and never read a primitive (`DsColors`, `DsElevation`) directly.
- Controlled: state is the caller's, passed as `value` with `onChanged`; a `null` callback disables the control and drops it from the focus order.
- A `///` doc comment on the class and every public member, in the house style (UK English, no em dashes, no serial comma, no AI tells).
- Accessibility: a semantic label for icon-only controls, tap targets of at least 48dp, keyboard-activatable, AA contrast.
- Responsive to its own width via `LayoutBuilder`, never overflowing down to a 320dp phone.

## 3. Export it

Add `export 'src/components/<layer>/ds_<name>.dart';` to `lib/design_system.dart`, in that layer's group.

## 4. Test it (as an expert tester)

Add `test/<layer>/ds_<name>_test.dart` covering: it renders, its interaction fires, its disabled and pending states, no overflow at 320dp and at a wide width, and its semantic label. If the component has a docs demo, `example/test/device_matrix_test.dart` also sweeps it from 320dp to 1920dp. Atoms also get a golden test across the light, dark and skinned themes. Run `flutter analyze` and `flutter test` clean.

## 5. Document it

- Add `example/lib/content/pages/<id>.dart` that builds a `PatternPage` (`id`, `group`, `navTitle`, `title`, `description`, `dos`, `donts`, `code`, `related`). Prose follows the house style. Omit `shots` and set `hasLiveDemo: false` until a live demo and screenshots exist.
- Register it in `example/lib/content/doc_registry.dart`: add the `import` and add the page to `allPages` under its group.
- Regenerate from `example/`: `dart run tool/generate_markdown.dart`, then `dart run tool/generate_markdown.dart --check` must pass.
- Add a row for it to the README component table under its layer.

## 6. Verify

`flutter analyze` clean, `flutter test` green, `generate_markdown.dart --check` passing. Confirm it renders in light, in dark and under a skin such as `DsSkins.engenLight()`.
