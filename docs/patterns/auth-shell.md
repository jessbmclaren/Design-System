# Auth shell

A `DsAuthShell` is the full-page frame for an auth flow: a decorative backdrop behind a centred card, a header pinned to the top start corner, a wrapping line of legal links along the bottom and an optional banner slot for the cookie consent bar. The card sits in a scroll view whose content is at least as tall as the viewport, so a short card stays centred, a tall card scrolls and the pinned chrome holds its corners while the card moves.

When a `hero` is provided and the shell's own width reaches `DsBreakpoints.expanded`, the page splits into two panes with the hero on the start side and the card on the end side. Below the breakpoint the hero is dropped, so compact viewports keep the plain centred card. The backdrop defaults to a `DsAuthGradient` under a `DsBrandBloom`, the same pairing the waiting screens use; pass another widget to swap the treatment or null to opt out. An `onBack` callback adds a back affordance beside the header for returning to wherever the flow was opened from.

## Guidelines

**Do**

- Fill the child slot with one focused card, such as a DsSignInView; the shell owns the chrome and the card owns the content.
- Pin a DsWordmark in the header slot, so every page of the flow carries the mark in the same corner.
- Keep the footer to a short wrapping line of DsLink legal links.
- Show the consent bar through the banner slot, so it overlays the page without touching the card.

**Don't**

- Do not nest the shell inside another scroll view; it manages its own scrolling.
- Do not put required controls in the hero; it disappears below the expanded breakpoint.
- Do not stack a second scrim or gradient over the backdrop slot; swap the slot instead.
- Do not rebuild the chrome per page; share one shell across the flow so the corners stay still while the cards change.

## Example

```dart
DsAuthShell(
  header: const DsWordmark(primary: 'acme', accent: 'id'),
  onBack: _returnToLanding,
  hero: marketingPanel,
  footer: Wrap(
    children: [
      DsLink(label: 'Privacy', onPressed: _openPrivacy),
      DsLink(label: 'Terms', onPressed: _openTerms),
      DsLink(label: 'Cookie settings', onPressed: _openCookieSettings),
    ],
  ),
  banner: _consentResolved ? null : cookieBanner,
  child: signInCard,
)
```

## See also

- [Auth gradient](auth-gradient.md)
- [Brand bloom](brand-bloom.md)
- [Sign in](sign-in.md)
- [Cookie banner](cookie-banner.md)
