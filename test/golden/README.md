# Golden (visual regression) tests

These tests capture a component's **pixels** under fixed themes, so a stray
padding, colour, radius or font change is caught even when the behavioural
tests stay green. Appearance is the product of a design system, so this is the
layer that guards it.

## Layout

```
test/golden/
  golden_helpers.dart      # font loader + themed capture helper + theme matrix
  atoms_golden_test.dart   # one golden per atom, per theme
  goldens/                 # the reference PNGs (committed — this is the baseline)
```

Each component is captured under the matrix in `dsGoldenThemes`:

| Theme        | Why it's captured                                            |
| ------------ | ------------------------------------------------------------ |
| `light`      | Default light appearance.                                    |
| `dark`       | Default dark appearance.                                     |
| `skin-engen` | A full re-brand (`DsSkins.engenLight()`) — catches a token that stops flowing through to a component. |

## Running

```sh
flutter test test/golden           # compare against the committed baseline
```

## After an intentional visual change

Regenerate the baseline, then review the diff in the PNGs before committing:

```sh
flutter test --update-goldens test/golden
git add test/golden/goldens
```

Only commit regenerated goldens when the pixel change is **expected**. An
unexpected diff here is a real regression.

## Adding a component

Add a line to the relevant `*_golden_test.dart` using `dsGoldenMatrix`, which
registers one golden per theme automatically:

```dart
dsGoldenMatrix('atom', 'chip', () => const DsChip(label: 'Active'));
```

Keep instances **deterministic** — no network images, no time- or
random-dependent data — or the goldens will flake.

## CI caveat (important)

Golden PNGs are **platform-sensitive**: font hinting and anti-aliasing differ
between macOS, Linux and Windows, so goldens generated on one OS can show
sub-pixel diffs on another. Two safe options:

1. **Generate and verify on the same OS** — e.g. run CI on `macos-latest` if the
   baseline was generated on macOS (the current baseline was).
2. If CI must run on Linux, regenerate the baseline once on Linux (in the CI
   image) and commit those, or adopt a golden framework such as `alchemist`
   that renders a deterministic block font for CI comparisons.

The Flutter SDK version also matters — pin it (`flutter --version`) so the
rendering engine is stable across machines.
