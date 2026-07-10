# Contributing

A quick, practical entry point. The conventions themselves (atomic layering,
token rules, accessibility, testing, definition of done) live in
[`CLAUDE.md`](CLAUDE.md); this file is just the commands and the flow.

## Before you push

Both must pass:

```sh
flutter analyze     # clean, no warnings
flutter test        # green, includes the 320dp and semantics checks
```

## Common tasks

**Add or change a component.** Follow the `ds-component` skill
(`.claude/skills/ds-component/`); it walks the scaffold-to-definition-of-done
steps. In short: pick the atomic layer, build it token-driven, export it from
`lib/design_system.dart` in its layer group, write the tests, add a content
page and regenerate the docs.

**Update goldens.** Only for a deliberate, reviewed visual change (a new atom,
or a skin change such as Engen). Never to make a red test go green:

```sh
flutter test test/golden --update-goldens
```

**Regenerate the pattern docs.** After changing copy in the content model
(`example/lib/content/pages/*.dart`). The markdown twins in `docs/patterns/`
are generated, so never hand-edit them. From `example/`:

```sh
dart run tool/generate_markdown.dart          # rewrite docs/patterns/*.md
dart run tool/generate_markdown.dart --check  # must pass; fails if any twin is stale
```

**Run the docs app.**

```sh
cd example && flutter run -d chrome
```

## Pull requests

- Branch off `main`; do not commit to `main` directly.
- Keep a PR to one component or one concern, so it is reviewable.
- Write a clear, imperative commit subject that says what changed.

## Where things live

The repository layout table is in [`README.md`](README.md). The reasoning
behind the sharp architectural choices (white-label base versus skin, why Engen
is a theme, container-fit responsiveness, brand-tunable tokens) is in
[`docs/adr/`](docs/adr/).
