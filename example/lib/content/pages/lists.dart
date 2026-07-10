// Pure Dart, no Flutter imports.
import '../pattern_page_content.dart';

/// Layout → Lists.
final PatternPage listsPage = PatternPage(
  id: 'lists',
  group: DocGroup.display,
  navTitle: 'Lists',
  title: 'Lists',
  description:
      'A list presents a collection of records as stacked rows. '
      'Use `DsList` with `DsListItem` children when people need to skim a set '
      'of items (teammates, invoices, projects) and open one to see more. '
      'Each row pairs a leading icon or avatar, a primary title, an optional '
      'supporting detail and a trailing element such as a status `DsBadge` or '
      'a navigation chevron. Use a list when the goal is to recognise and '
      'select a single record; use a table when people need aligned '
      'columns to compare values across rows.',
  hasLiveDemo: true,
  blocks: const [
    ProseBlock(
      'Give `DsListItem` an `onTap` to make the whole row a target. When no '
      'trailing widget is supplied, a chevron appears automatically to signal '
      'that the row navigates. Set `bordered: true` on `DsList` to group the '
      'rows into a rounded card, and keep `showDividers` on so adjacent rows '
      'stay visually separate.',
    ),
  ],
  dos: const [
    'Use DsList for straightforward, tappable collections of records.',
    'Give every row a clear primary title and one line of supporting detail.',
    'Show a record\'s status with a trailing DsBadge.',
    'Make the whole row tappable when it navigates to a detail view.',
  ],
  donts: const [
    'Don\'t cram more than two lines of detail into a single row.',
    'Don\'t use a list when people need aligned columns to compare values. Use a table.',
    'Don\'t leave rows looking tappable if tapping them does nothing.',
  ],
  code: '''
DsList(
  bordered: true,
  children: [
    DsListItem(
      leading: const CircleAvatar(child: Text('AM')),
      title: 'Ava Morgan',
      subtitle: 'ava.morgan@example.com',
      trailing: const DsBadge(
        label: 'Active',
        variant: DsBadgeVariant.success,
      ),
      onTap: () {},
    ),
    DsListItem(
      leading: const CircleAvatar(child: Text('JC')),
      title: 'Jonah Cole',
      subtitle: 'jonah.cole@example.com',
      trailing: const DsBadge(
        label: 'Invited',
        variant: DsBadgeVariant.warning,
      ),
      onTap: () {},
    ),
  ],
);
''',
  shots: const [
    Shot(pageId: 'lists', size: ShotSize.desktop),
    Shot(pageId: 'lists', size: ShotSize.phone),
  ],
  related: ['filter-controls', 'empty-state', 'full-page-layouts'],
);
