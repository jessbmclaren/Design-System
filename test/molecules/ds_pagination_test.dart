import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  testWidgets('reports the visible range when item counts are known',
      (tester) async {
    await pumpDs(
      tester,
      DsPagination(
        page: 1,
        pageCount: 5,
        totalItems: 103,
        pageSize: 25,
        onPageChanged: (_) {},
      ),
    );

    expect(find.text('1–25 of 103'), findsOneWidget);
  });

  testWidgets('clamps the range end to the total on the last page',
      (tester) async {
    await pumpDs(
      tester,
      DsPagination(
        page: 5,
        pageCount: 5,
        totalItems: 103,
        pageSize: 25,
        onPageChanged: (_) {},
      ),
    );

    expect(find.text('101–103 of 103'), findsOneWidget);
  });

  testWidgets('falls back to a page label when item counts are unknown',
      (tester) async {
    await pumpDs(
      tester,
      DsPagination(page: 2, pageCount: 5, onPageChanged: (_) {}),
    );

    expect(find.text('Page 2 of 5'), findsOneWidget);
  });

  testWidgets('next reports the following page through onPageChanged',
      (tester) async {
    final pages = <int>[];
    await pumpDs(
      tester,
      DsPagination(page: 2, pageCount: 5, onPageChanged: pages.add),
    );

    await tester.tap(find.widgetWithText(DsButton, 'Next'));
    await tester.pump();

    expect(pages, [3]);
  });

  testWidgets('prev reports the preceding page through onPageChanged',
      (tester) async {
    final pages = <int>[];
    await pumpDs(
      tester,
      DsPagination(page: 2, pageCount: 5, onPageChanged: pages.add),
    );

    await tester.tap(find.widgetWithText(DsButton, 'Prev'));
    await tester.pump();

    expect(pages, [1]);
  });

  testWidgets('prev is disabled on the first page', (tester) async {
    var changed = 0;
    await pumpDs(
      tester,
      DsPagination(page: 1, pageCount: 5, onPageChanged: (_) => changed++),
    );

    expect(
      tester.widget<DsButton>(find.widgetWithText(DsButton, 'Prev')).onPressed,
      isNull,
    );

    await tester.tap(find.widgetWithText(DsButton, 'Prev'));
    await tester.pump();

    expect(changed, 0);
  });

  testWidgets('next is disabled on the last page', (tester) async {
    var changed = 0;
    await pumpDs(
      tester,
      DsPagination(page: 5, pageCount: 5, onPageChanged: (_) => changed++),
    );

    expect(
      tester.widget<DsButton>(find.widgetWithText(DsButton, 'Next')).onPressed,
      isNull,
    );

    await tester.tap(find.widgetWithText(DsButton, 'Next'));
    await tester.pump();

    expect(changed, 0);
  });

  testWidgets('a null onPageChanged disables both pager buttons',
      (tester) async {
    await pumpDs(tester, const DsPagination(page: 2, pageCount: 5));

    expect(
      tester.widget<DsButton>(find.widgetWithText(DsButton, 'Prev')).onPressed,
      isNull,
    );
    expect(
      tester.widget<DsButton>(find.widgetWithText(DsButton, 'Next')).onPressed,
      isNull,
    );
  });

  testWidgets('announces the current page to assistive technology',
      (tester) async {
    await pumpDs(
      tester,
      DsPagination(
        page: 1,
        pageCount: 5,
        totalItems: 103,
        pageSize: 25,
        onPageChanged: (_) {},
      ),
    );

    expect(find.bySemanticsLabel('Page 1 of 5'), findsOneWidget);
  });

  testWidgets('hides the page-size select when onPageSizeChanged is null',
      (tester) async {
    await pumpDs(
      tester,
      DsPagination(
        page: 1,
        pageCount: 5,
        totalItems: 103,
        pageSize: 25,
        onPageChanged: (_) {},
      ),
    );

    expect(find.text('25 / page'), findsNothing);
  });

  testWidgets('reports a newly picked page size through onPageSizeChanged',
      (tester) async {
    final sizes = <int>[];
    await pumpDs(
      tester,
      DsPagination(
        page: 1,
        pageCount: 5,
        totalItems: 103,
        pageSize: 25,
        onPageChanged: (_) {},
        onPageSizeChanged: sizes.add,
      ),
    );

    expect(find.text('25 / page'), findsOneWidget);

    await tester.tap(find.text('25 / page'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.text('50 / page').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(sizes, [50]);
  });

  testWidgets('renders without overflow on a small phone', (tester) async {
    await pumpDs(
      tester,
      DsPagination(
        page: 3,
        pageCount: 5,
        totalItems: 103,
        pageSize: 25,
        onPageChanged: (_) {},
        onPageSizeChanged: (_) {},
      ),
      surfaceSize: const Size(320, 640),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('renders without overflow on a large desktop', (tester) async {
    await pumpDs(
      tester,
      DsPagination(
        page: 3,
        pageCount: 5,
        totalItems: 103,
        pageSize: 25,
        onPageChanged: (_) {},
        onPageSizeChanged: (_) {},
      ),
      surfaceSize: const Size(1440, 900),
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'the pager wraps instead of overflowing inside a padded 320dp screen',
      (tester) async {
    await pumpDs(
      tester,
      SizedBox(
        width: 288,
        child: DsPagination(
          page: 3,
          pageCount: 5,
          totalItems: 103,
          pageSize: 25,
          onPageChanged: (_) {},
          onPageSizeChanged: (_) {},
        ),
      ),
      surfaceSize: const Size(320, 640),
    );

    expect(tester.takeException(), isNull);
  });
}
