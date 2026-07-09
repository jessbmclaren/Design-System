// Pure Dart — NO Flutter imports.
import '../pattern_page_content.dart';

/// Content → Link.
final PatternPage linkPage = PatternPage(
  id: 'link',
  group: DocGroup.content,
  navTitle: 'Link',
  title: 'Link',
  description:
      'A link is inline, tappable text for navigation and low-emphasis actions — '
      'jumping to another view, opening a document, or revealing supporting '
      'detail without the visual weight of a button. `DsLink` styles its label '
      'from the theme\'s action tokens: `primary` for the main path through a '
      'flow, `secondary` for supporting routes that should stay quiet. Set '
      '`external: true` to append an "open in new" glyph, signalling the '
      'destination leaves the current context, or pass a `trailingIcon` such as '
      'a chevron for any other affordance. The label ellipsizes rather than '
      'wrapping, so a link sits safely inside running text, a `Row`, or a `Wrap` '
      'from a 320dp phone up to a wide desktop. A null `onPressed` renders the '
      'link disabled and drops it from the tap and focus order.',
  dos: const [
    'Write labels that name the destination or outcome, e.g. "View invoice", so the target is clear before the click.',
    'Reserve the `primary` variant for the main path; use `secondary` for supporting links that should not compete for attention.',
    'Set `external: true` whenever the link opens a new tab, document, or third-party site so people can anticipate the jump.',
    'Wrap a link in `Flexible`, or place it in a `Wrap`, when the surrounding row may be narrower than the label.',
    'Use a link for low-emphasis actions and reach for `DsButton` when the action is the primary call to action.',
  ],
  donts: const [
    'Don\'t use vague labels like "click here" or "read more" that carry no meaning out of context.',
    'Don\'t style a link as the primary action on a form or dialog — use a button instead.',
    'Don\'t add the external glyph to links that stay within the app; reserve it for destinations that leave the context.',
    'Don\'t disable a link silently when the reason is recoverable — explain why the path is unavailable.',
  ],
  code: '''
Wrap(
  spacing: 16,
  runSpacing: 8,
  children: [
    DsLink(
      label: 'View invoice',
      onPressed: () {},
    ),
    DsLink(
      label: 'Billing settings',
      variant: DsLinkVariant.secondary,
      onPressed: () {},
    ),
    DsLink(
      label: 'API documentation',
      external: true,
      onPressed: () {},
    ),
    DsLink(
      label: 'All activity',
      trailingIcon: Icons.chevron_right,
      onPressed: () {},
    ),
  ],
);
''',
  shots: const [
    Shot(pageId: 'link', size: ShotSize.desktop),
    Shot(pageId: 'link', size: ShotSize.phone),
  ],
  hasLiveDemo: true,
  related: const ['button', 'back-link'],
);
