# Cookie banner

A `DsCookieBanner` is the site consent bar pinned along the bottom of a public page, usually through the banner slot of a `DsAuthShell`. It pairs a short explanation with the three standard actions, all visible at once: accept all cookies, reject the non-essential ones or open the preferences surface. The component holds no consent state; each choice is reported through its callback and the caller records it and removes the bar.

The banner measures its own width. When the bar is wide the message and the actions share a row; on middling widths the actions drop beneath the message; when the bar itself is narrow the three buttons stack full-width with the primary action first. The whole bar is a polite live region, so a screen reader announces the message when the banner first appears without interrupting what the user was doing. Pass the explanation as a `message` string or as a `messageWidget` when the copy needs an inline link.

## Guidelines

**Do**

- Keep the message to a sentence or two on what cookies are for; the detail belongs in the preferences surface.
- Keep all three actions visible; rejecting must be as easy as accepting.
- Route the preferences action to a DsCookiePreferences card, typically hosted in a DsTakeover.
- Record the choice and dismiss the banner as soon as one is made.

**Don't**

- Do not hide the reject action behind the preferences surface; it stays on the bar.
- Do not block the page behind the banner; the user can keep reading while it waits.
- Do not show the banner again once consent is recorded.
- Do not demote the reject action to a quiet link; it sits beside accept as a full button.

## Example

```dart
DsCookieBanner(
  message: 'We use cookies to keep your account secure and to '
      'understand how the product is used.',
  onAcceptAll: _acceptAll,
  onRejectNonEssential: _rejectNonEssential,
  onManagePreferences: _openPreferences,
)
```

## See also

- [Cookie preferences](cookie-preferences.md)
- [Auth shell](auth-shell.md)
- [Takeover](takeover.md)
