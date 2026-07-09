import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Img page.
///
/// Shows the three states [DsImg] guarantees without any network: the default
/// tokened skeleton box, a bespoke [placeholder], and the same tile with a
/// rounded corner radius. Each tile reserves an explicit footprint so the
/// layout is stable on the very first frame, keeping the demo screenshot-safe.
class ImgDemo extends StatelessWidget {
  const ImgDemo({super.key});

  static const double _w = 132;
  static const double _h = 96;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _Tile(
          label: 'Skeleton',
          child: const DsImg(
            width: _w,
            height: _h,
            borderRadius: 12,
            semanticLabel: 'Loading placeholder',
          ),
        ),
        _Tile(
          label: 'Placeholder',
          child: DsImg(
            width: _w,
            height: _h,
            borderRadius: 12,
            semanticLabel: 'Report cover',
            placeholder: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF3B5BDB).withValues(alpha: 0.85),
                    const Color(0xFF7048E8).withValues(alpha: 0.85),
                  ],
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.insert_chart_outlined,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ),
        ),
        _Tile(
          label: 'Square avatar',
          child: DsImg(
            width: _h,
            height: _h,
            borderRadius: 48,
            semanticLabel: 'Team avatar',
            placeholder: DecoratedBox(
              decoration: const BoxDecoration(color: Color(0xFF1098AD)),
              child: const Center(
                child: Text(
                  'AM',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        child,
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
