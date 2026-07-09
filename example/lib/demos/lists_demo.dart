import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Lists page: a bordered DsList of team members, each row
/// with a leading avatar, a name, a supporting email, and a trailing status
/// badge. Every row is tappable and navigates in a real product.
class ListsDemo extends StatelessWidget {
  const ListsDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);

    return DsList(
      bordered: true,
      children: [
        for (final member in _members)
          DsListItem(
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: tokens.badgeNeutralColorBackground,
              child: Text(
                member.initials,
                style: TextStyle(
                  fontSize: 13,
                  color: tokens.badgeNeutralColorText,
                ),
              ),
            ),
            title: member.name,
            subtitle: member.email,
            trailing: DsBadge(
              label: member.statusLabel,
              variant: member.statusVariant,
            ),
            onTap: () {},
          ),
      ],
    );
  }
}

class _Member {
  const _Member(
    this.name,
    this.email,
    this.statusLabel,
    this.statusVariant,
  );

  final String name;
  final String email;
  final String statusLabel;
  final DsBadgeVariant statusVariant;

  String get initials {
    final parts = name.split(' ');
    return parts.map((p) => p[0]).take(2).join();
  }
}

const List<_Member> _members = [
  _Member('Ava Morgan', 'ava.morgan@example.com', 'Active',
      DsBadgeVariant.success),
  _Member('Jonah Cole', 'jonah.cole@example.com', 'Invited',
      DsBadgeVariant.warning),
  _Member('Priya Nair', 'priya.nair@example.com', 'Active',
      DsBadgeVariant.success),
  _Member('Marcus Reid', 'marcus.reid@example.com', 'Suspended',
      DsBadgeVariant.danger),
  _Member('Lena Fischer', 'lena.fischer@example.com', 'Active',
      DsBadgeVariant.success),
];
