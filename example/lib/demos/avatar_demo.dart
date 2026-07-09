import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Avatar page.
///
/// Shows the fallback chain [DsAvatar] resolves without any network: initials
/// derived from a name, a person glyph when no name is given, an icon fallback
/// for non-person entities, and a per-person accent via colour overrides. It
/// also demonstrates the size scale. Nothing here needs the network — the
/// `imageUrl` tile relies on the built-in graceful fallback to initials — so
/// the demo is stable on the first frame and screenshot-safe.
class AvatarDemo extends StatelessWidget {
  const AvatarDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        _Tile(
          label: 'Initials',
          child: DsAvatar(name: 'Amara Mensah', size: 48),
        ),
        _Tile(
          label: 'Accent',
          child: DsAvatar(
            name: 'Priya Raman',
            size: 48,
            backgroundColor: Color(0xFFE9D8FD),
            foregroundColor: Color(0xFF6B46C1),
          ),
        ),
        _Tile(
          label: 'Icon',
          child: DsAvatar(icon: Icons.hub_outlined, name: 'Platform', size: 48),
        ),
        _Tile(
          label: 'Glyph',
          child: DsAvatar(size: 48),
        ),
        _Tile(
          label: 'Size 32',
          child: DsAvatar(name: 'Lin Wei', size: 32),
        ),
        _Tile(
          label: 'Size 24',
          child: DsAvatar(name: 'Ola Berg', size: 24),
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 48, child: Center(child: child)),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
