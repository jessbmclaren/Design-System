# Repository guidance

A white-label, Material 3 Flutter component library with a docs app. Components use the `Ds` prefix.

## Atomic design

Build and evolve this library the atomic-design way, and stick to it. Every new or changed piece finds its level before it is written, and nothing reaches across a boundary it should not.

Atomic design treats an interface like chemistry. A whole UI is built from a small set of building blocks that combine into larger structures, so you hold the design as a cohesive whole and as a collection of parts at the same time. There are five levels, each a deliberate step up in complexity:

- **Atoms** are the foundational building blocks: a label, an input, a button, an icon, and the design tokens beneath them (colour, type, spacing, elevation). An atom cannot be broken down further without losing its meaning.
- **Molecules** are small groups of atoms bonded into one unit with a single job. A label, an input and a button become a search field. Simple, reusable, one responsibility.
- **Organisms** are groups of molecules and atoms joined into a distinct, standalone section of the interface: a page header, a data table, a sign-in card.
- **Templates** lay organisms out into a page-level structure that shows how content is arranged, without the real content.
- **Pages** are templates filled with real content, where the system meets reality. Here the pages are the docs demos under `example/`.

These levels are a mental model, not a rigid pipeline. You move between them, and you are always building a system rather than a set of one-off screens.

**Stick to it.** A few principles keep the system coherent:

- Decide the level first. A control that cannot be broken down is an atom, a small bond of atoms with one job is a molecule, a standalone section is an organism.
- Name by level, and do not proliferate atoms. Reach for a variant before a new atom (a `DsButton.social` factory, not a new social-button atom).
- Organisms compose, they never reach into an atom's internals.
- Templates and pages are where the system is tested against real content (here, the docs demos under `example/`).
- One shared vocabulary across design and engineering. That is the point.

The barrel (`lib/design_system.dart`) and the folders under `lib/src/components/` are grouped by level, so a new file lands in the layer it belongs to.

### Tokens are the layer beneath the atoms

**Tokens are the single source of appearance.** Every component reads its colours, radii, spacing, type and shadows from `DsTokens.of(context)`. A component never hardcodes a colour, size or shadow, and never reads a primitive (`DsColors`, `DsElevation`) directly. Spacing derives from `tokens.spacingUnit`, elevation from `tokens.shadowLow` / `shadowMedium` / `shadowHigh`, type from the ramp tokens (`tokens.headingLg`, `tokens.bodyMd` and so on).

**Primitives back the tokens.** `DsColors`, `DsElevation`, `DsRadii`, `DsSpacing` and `DsTypography` are the raw scales the tokens default to. They sit beneath the tokens, so a component consumes the token, not the primitive.

**White-label base versus theme.** `DsTokens.light()` and `DsTokens.dark()` are the neutral, brand-neutral base and they stay neutral. A brand is a **skin**: a `DsTokens` value built with `copyWith` in `DsSkins`, opted into with `DsTheme.light(tokens: DsSkins.engenLight())`. A brand is a theme layered on top, never baked into the base. Engen, for example, is a theme, not the white-label default.

**Adding or changing a token.** `DsTokens` is a `ThemeExtension`, so a new field must be threaded through the constructor, its field declaration, the `light()` and `dark()` defaults, `copyWith`, `lerp`, `operator ==` and `hashCode`. Miss one and equality, theme animation or the build breaks. `DsTypeToken` carries the same contract on a smaller scale.

## Accessibility, responsiveness and motion

Every component is built to be usable by everyone, across screen sizes and text sizes. Treat these as hard requirements, not extras.

**Accessibility.**
- Label every interactive control for assistive technology. An icon-only control takes a required semantic label (see `DsIconButton.semanticLabel`), and a decorative element is hidden with `Semantics(excludeSemantics: true)` (see `DsDivider`).
- Controls are keyboard-focusable and activate on Enter and Space. A disabled control leaves the focus order.
- Tap targets are at least 48dp.
- Colour pairs meet WCAG AA contrast. Never rely on colour alone to carry meaning, pair it with a label or an icon.
- Focus order follows reading order, and related controls are grouped in a `Semantics(container: true)` node (see `DsFormFieldGroup`).
- A field's error is announced with its label (see `DsTextField.errorText`), and a state change that is not otherwise spoken is announced rather than left silent.

**Responsiveness and devices.**
- Every component works across the device spectrum, from a 320dp small phone to a 1920dp large desktop, without overflow. `example/test/device_matrix_test.dart` sweeps each page's demo across `[320, 360, 390, 414, 600, 768, 834, 1024, 1280, 1440, 1920]`; a component's own test asserts no overflow at 320dp and at a wide width.
- Layout adapts across the Material 3 window classes in `DsBreakpoints`: **compact** (below 600), **medium** (600 to 840) and **expanded** (840 and up). Use `DsBreakpoints.of(context)` only for a genuine window-class decision.
- Prefer responding to the component's own width, not the window: measure with a `LayoutBuilder` and a content threshold (see `DsFormFieldGroup.minRowWidth`), so one component fits a narrow card and a wide pane.
- On wide desktops, constrain the main content to `DsBreakpoints.contentMaxWidth` and centre the surplus, so a layout does not sprawl to 1920dp.
- Honour the user's text scale. Text wraps or ellipsizes, it never clips.

**Motion.**
- Animate through the `DsMotion` tokens (durations and curves), not hand-picked values.
- Every animation collapses to a still frame when the user asks for reduced motion (`MediaQuery.disableAnimations`), resolved through `DsMotion.durationOf` / `curveOf`.

## Component conventions

**API.** One component per `ds_x.dart` file, all with the `Ds` prefix. Components are controlled: the caller owns the state and passes `value` with `onChanged`, and a `null` callback disables the control and drops it from the focus order. Express emphasis or kind as an enum (`DsButtonVariant`) or a named-constructor variant (`DsButton.social`), never a near-duplicate widget. Prefer `const` constructors, and give every public member a `///` doc comment.

**Flutter craft.**
- Prefer `StatelessWidget`. Hold state only when the widget genuinely owns it (a toggle, an animation), and dispose every controller, focus node and animation controller in `dispose`.
- Never use a `BuildContext` across an `await` without checking `mounted` first.
- Keep components presentational and controlled. No business logic, network or storage inside a widget.
- `const` the widget subtree where you can to cut rebuilds, and wrap expensive custom painting in a `RepaintBoundary`.
- Read Ds appearance with `DsTokens.of(context)`, resolved once per build. Sound null safety, no `dynamic`.

**Testing.** Work as an expert tester. Before calling a change done, drive the real behaviour end to end and probe the edges (empty and very long content, 320dp, disabled, pending, error, dark, a skin, reduced motion, keyboard only). Verify by observing, never by assuming from the code. Every component ships widget tests that cover: it renders, its interaction fires, its disabled and pending states, and no overflow at 320dp and at a wide width. Atoms also get golden tests across the light, dark and skinned themes.

- Keep tests deterministic and screenshot-safe: no real timers, network or randomness, and pump explicit durations rather than `pumpAndSettle` on an animated surface.
- Prefer `find.text`, `find.bySemanticsLabel` and `find.widgetWithText` over brittle `find.byType`, so a refactor does not break the test.
- Assert the accessibility contract: the semantic label is present, the control is focusable, the tap target holds at 320dp.
- Regenerate goldens only as a deliberate, reviewed visual change.

`flutter analyze` and `flutter test` are clean before a change is done.

**Definition of done** for a new or changed component:

- `flutter analyze` clean and `flutter test` green, including the 320dp and semantics checks.
- Exported from the barrel in its layer group.
- A `///` doc comment on the component and its public members.
- A content-model page at `example/lib/content/pages/<id>.dart`, then `dart run tool/generate_markdown.dart` from `example/` with `--check` passing.
- Renders correctly in light and dark, and under a skin such as `DsSkins.engenLight()`.
- Listed in the README component table.

## Documentation source of truth

All user-facing pattern copy lives in the content model at `example/lib/content/pages/*.dart`. The markdown files in `docs/patterns/*.md` are **generated** from it, so never hand-edit them. After changing copy in the content model, regenerate and verify from the `example/` directory:

```sh
dart run tool/generate_markdown.dart          # rewrite docs/patterns/*.md
dart run tool/generate_markdown.dart --check   # must pass; fails if any twin is stale
```
