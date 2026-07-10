# Design System

A white-label, Material 3 based Flutter component library, with a full
documentation experience: live examples, copyable code and a "View as
Markdown" twin for every pattern.

- **Token-driven & white-label.** Every colour, type ramp, radius and spacing
  value is a token on the `DsTokens` theme extension. Re-brand the whole system
  by passing your own token set to `DsTheme.light` / `DsTheme.dark`.
- **Material 3 base.** Themes are built with `useMaterial3: true`.
- **Responsive.** Every component works from small phones (~320dp) to large
  desktop screens; the data table collapses to stacked cards below 600dp.
- **Light & dark** out of the box.

## Install

```yaml
dependencies:
  design_system:
    path: ../Design-System   # or your git/pub source
```

## Usage

```dart
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

void main() => runApp(
      MaterialApp(
        theme: DsTheme.light(),
        darkTheme: DsTheme.dark(),
        home: const Home(),
      ),
    );

class Home extends StatelessWidget {
  const Home({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: DsButton(label: 'Get started', onPressed: () {}),
        ),
      );
}
```

### White-label it

```dart
final brand = DsTokens.light().copyWith(
  buttonPrimaryColorBackground: const Color(0xFF6D28D9),
  actionPrimaryColorText: const Color(0xFF6D28D9),
  formAccentColor: const Color(0xFF6D28D9),
);

MaterialApp(theme: DsTheme.light(tokens: brand));
```

## Components: Atomic Design

Components are organised into Brad Frost's atomic layers under
`lib/src/components/` (all re-exported from the single barrel, so imports stay
`package:design_system/design_system.dart`):

| Layer | Components |
| --- | --- |
| **Atoms** | `DsButton`, `DsBadge`, `DsSpinner`, `DsBackLink`, `DsChip` |
| **Molecules** | `DsFilterChip`, `DsListItem`, `DsToast`, `DsBanner`, `DsEmptyState`, `DsTabs`, `DsPageHeader` |
| **Organisms** | `DsList`, `DsDataTable`, `DsProgressStepper`, `DsSignInView`, `DsFocusView` |
| **Templates** | `DsPageScaffold` |
| **Pages** | the documentation demos in [`example/`](example/) |

## Documentation

The [`example/`](example/) app is the documentation site: grouped navigation,
a live example per pattern, copyable Dart and a "View as Markdown" pane.

```sh
cd example
flutter run -d chrome
```

The written pattern docs live in [`docs/patterns/`](docs/patterns/): one
markdown page per pattern with embedded screenshots, generated from the same
content model the app renders, so they never drift. See
[`example/README.md`](example/README.md) for how to regenerate them.

## Repository layout

| Path | What |
| --- | --- |
| `lib/src/tokens/` | Colour, typography, spacing, radius and breakpoint tokens |
| `lib/src/theme/` | `DsTheme` (M3 `ThemeData`) and the `DsTokens` extension |
| `lib/src/components/{atoms,molecules,organisms,templates}/` | The `Ds*` widgets, by atomic layer |
| `test/{atoms,molecules,organisms,templates}/` | Widget unit tests, mirroring the component layers |
| `example/` | The documentation app |
| `docs/patterns/` | Generated markdown twins + screenshots |

## Web deployment note

The docs app uses hash-based URLs by default, which work on any static host. If
you serve it with path-based URLs, configure your host to rewrite unknown paths
to `index.html`, or build with the correct `--base-href`.
