// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Actions → Icon button.
final PatternPage iconButtonPage = PatternPage(
  id: 'icon-button',
  group: DocGroup.actions,
  navTitle: 'Icon button',
  title: 'Icon button',
  description:
      '`DsIconButton` is a flat, circular button for a single icon action, such '
      'as closing a dialog or opening an overflow menu. It stays flat until you '
      'hover, focus or press it, when a soft themed fill appears, so it sits '
      'quietly on a toolbar or inside a card rather than reading as a raised '
      'button. The `semanticLabel` is required: it names the button for screen '
      'readers and shows as a tooltip on hover. Pass a null `onPressed` to '
      'disable the button and drop it from the focus order.',
  hasLiveDemo: true,
  dos: const [
    'Give every icon button a `semanticLabel` that names the action, for example "Close" or "Add row".',
    'Pick an icon whose meaning is well known, so the button reads without a visible caption.',
    'Keep the default size on a toolbar, and raise `size` and `iconSize` together for a more prominent slot.',
    'Disable the button with a null `onPressed` when its action is not currently available.',
  ],
  donts: const [
    'Don\'t use an icon button for the main action on a page; a labelled `DsButton` is clearer.',
    'Don\'t give two buttons that do different things the same `semanticLabel`.',
    'Don\'t pair an icon with an unclear meaning; add a visible text label instead.',
    'Don\'t shrink the control below a comfortable tap target on touch screens.',
  ],
  code: '''
Row(
  children: [
    DsIconButton(
      icon: DsIcons.close,
      semanticLabel: 'Close',
      onPressed: () => Navigator.of(context).pop(),
    ),
    DsIconButton(
      icon: DsIcons.edit,
      semanticLabel: 'Edit',
      onPressed: controller.startEditing,
    ),
    // A null onPressed disables the button and removes it from the focus order.
    const DsIconButton(
      icon: DsIcons.refresh,
      semanticLabel: 'Refresh',
      onPressed: null,
    ),
  ],
);
''',
  shots: const [
    Shot(pageId: 'icon-button', size: ShotSize.desktop),
    Shot(pageId: 'icon-button', size: ShotSize.phone),
  ],
  related: const ['action-buttons', 'icon', 'iconography'],
);
