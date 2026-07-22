import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Live demo for the Pagination page: a controlled pager over 103 items with
/// working Prev / Next and a page-size select. The demo owns the page state,
/// exactly as a product screen would.
class PaginationDemo extends StatefulWidget {
  const PaginationDemo({super.key});

  @override
  State<PaginationDemo> createState() => _PaginationDemoState();
}

class _PaginationDemoState extends State<PaginationDemo> {
  static const int _totalItems = 103;

  int _page = 1;
  int _pageSize = 25;

  int get _pageCount => (_totalItems / _pageSize).ceil();

  @override
  Widget build(BuildContext context) {
    final pagination = DsPagination(
      page: _page,
      pageCount: _pageCount,
      totalItems: _totalItems,
      pageSize: _pageSize,
      onPageChanged: (next) => setState(() => _page = next),
      onPageSizeChanged: (size) => setState(() {
        _pageSize = size;
        _page = 1; // never point past the data
      }),
    );

    // The pager row's intrinsic width (Prev + page box + Next) is ~300dp, so
    // on the very narrowest layouts the demo pans it instead of overflowing.
    return LayoutBuilder(
      builder: (context, constraints) {
        const minWidth = 340.0;
        if (constraints.maxWidth >= minWidth) return pagination;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(width: minWidth, child: pagination),
        );
      },
    );
  }
}
