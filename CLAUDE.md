# Repository guidance

A white-label, Material 3 Flutter component library with a docs app. Components use the `Ds` prefix.

## Documentation source of truth

All user-facing pattern copy lives in the content model at `example/lib/content/pages/*.dart`. The markdown files in `docs/patterns/*.md` are **generated** from it, so never hand-edit them. After changing copy in the content model, regenerate and verify from the `example/` directory:

```sh
dart run tool/generate_markdown.dart          # rewrite docs/patterns/*.md
dart run tool/generate_markdown.dart --check   # must pass; fails if any twin is stale
```

## Writing style (all prose)

This applies to every piece of human-facing copy: page descriptions, prose blocks, Do/Don't guidance, variable descriptions, sample string copy in code samples, and Dart doc comments (`///`) in `lib/`. It does not apply to code identifiers, type names, property names, hex values or token names.

1. **UK English.** colour, behaviour, customise, organise, centre, catalogue, grey, licence (noun), optimise, recognise, summarise, and so on. Never rename a Dart symbol to match: the `Color` type, `color:` arguments and token names like `colorPrimary` stay exactly as the framework spells them.
2. **No em dashes or en dashes** (`—`, `–`), and no spaced hyphen used as a dash (` - `). Rewrite the sentence with a comma, a full stop, a colon or brackets instead. Keep ordinary compound hyphens (single-open, real-time, drop-down, white-label).
3. **No serial (Oxford) comma.** Write "x, y and z", not "x, y, and z". Keep a comma before "and" only when it joins two independent clauses or removes a genuine ambiguity.
4. **No AI giveaways.** Avoid the tells that make copy read as machine-written:
   - "Reach for it when/to…", "Whether it's x or y…", "It's worth noting", "In today's…".
   - Rule-of-three triads padded for rhythm ("fast, simple and reliable").
   - "not just x, but y" and "x isn't just y" constructions.
   - Trailing participle summaries ("…, keeping focus on a single answer", "…, making it easy to scan").
   - Empty intensifiers and filler: seamless, effortless, powerful, robust, delightful, simply, easily, at a glance.
   - Over-parallel Do/Don't lines that all start the same way.

   Prefer short, plain, specific sentences. If a sentence only exists for rhythm, cut it.

Keep the same rules in mind when editing Dart comments: swap em dashes for a comma or full stop without touching any code.
