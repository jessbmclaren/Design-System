# Cookie preferences

A `DsCookiePreferences` is the per-category consent surface opened from the cookie banner. Each `DsCookieCategory` renders as a row with a title, a description and a trailing `DsSwitch`; a locked category, the essential row, carries an always-on `DsBadge` instead of a switch. The caller owns the category state and receives every toggle through `onChanged` with the category id and the requested value.

Present the card inside a `DsTakeover` over the page that opened it. The takeover blurs the page, blocks its input and keeps keyboard focus inside the card, so the choice is settled before the page becomes interactive again. Beneath the rows sit a primary save action and a secondary accept-all action; a null callback disables either, and a null `onChanged` disables every switch.

## Guidelines

**Do**

- Mark the essential category locked, so it reads as fact rather than choice.
- Describe each category in a sentence of plain language, not a policy excerpt.
- Apply the choice on save, record it and remove the takeover.
- Offer a way back in through a "Cookie settings" link in the page footer.

**Don't**

- Do not pre-enable optional categories; consent is opt-in.
- Do not list categories the product does not use.
- Do not give the card a route of its own when a takeover fits; the page behind gives the choice its context.
- Do not toggle categories on the accept-all action yourself; the callback is the caller's cue to enable everything and save.

## Example

```dart
DsTakeover(
  background: page,
  child: DsCookiePreferences(
    categories: [
      const DsCookieCategory(
        id: 'essential',
        title: 'Essential',
        description: 'Required for security and sign-in.',
        enabled: true,
        locked: true,
      ),
      DsCookieCategory(
        id: 'analytics',
        title: 'Analytics',
        description: 'Help us understand how the product is used.',
        enabled: _analytics,
      ),
    ],
    onChanged: (id, enabled) => setState(() => _setCategory(id, enabled)),
    onSave: _save,
    onAcceptAll: _acceptAll,
    onClose: _close,
  ),
)
```

## See also

- [Cookie banner](cookie-banner.md)
- [Takeover](takeover.md)
- [Selection controls](selection-controls.md)
