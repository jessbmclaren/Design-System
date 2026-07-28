import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// The `DsCheckbox` atom and every checkbox the data grid draws read one token,
/// so they cannot drift apart. Before the token existed each held its own
/// private `18`, and changing one would silently have left the other behind.
///
/// These assertions are deliberately cross-layer: the point is not that either
/// widget is 18dp, it is that both follow the *same* number wherever a skin
/// moves it — including when the skin changes under a live tree.

/// Swaps the checkbox-size token on a running tree, the way a skin switcher
/// does, so the assertions cover reactivity rather than just first build.
class _Skinner extends StatefulWidget {
  const _Skinner({required this.child});

  final Widget child;

  @override
  State<_Skinner> createState() => _SkinnerState();
}

class _SkinnerState extends State<_Skinner> {
  double _size = DsTokens.light().checkboxSize;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: DsTheme.light(
        tokens: DsTokens.light().copyWith(checkboxSize: _size),
      ),
      home: Scaffold(
        body: Column(
          children: <Widget>[
            ElevatedButton(
              onPressed: () => setState(() => _size = 26),
              child: const Text('reskin'),
            ),
            widget.child,
          ],
        ),
      ),
    );
  }
}

/// The side of the grid's own check widget, as laid out.
double _gridSide(WidgetTester tester) => tester
    .getSize(
      find
          .byWidgetPredicate(
            (Widget w) => w.runtimeType.toString() == '_GridCheck',
          )
          .first,
    )
    .width;

/// The side of the atom's box, which is an AnimatedContainer.
double _atomSide(WidgetTester tester) =>
    tester.getSize(find.byType(AnimatedContainer).first).width;

void main() {
  group('checkbox size is one token', () {
    testWidgets('the atom follows it, live', (tester) async {
      await tester.pumpWidget(
        _Skinner(
          child: DsCheckbox(value: true, label: 'Ready', onChanged: (_) {}),
        ),
      );
      await tester.pumpAndSettle();
      expect(_atomSide(tester), DsTokens.light().checkboxSize);

      await tester.tap(find.text('reskin'));
      await tester.pumpAndSettle();
      expect(_atomSide(tester), 26);
    });

    testWidgets('the grid draws its checkbox cells at the same size, live',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const _Skinner(
          child: SizedBox(
            height: 300,
            width: 900,
            child: DsDataGrid(
              selectable: true,
              columns: <DsGridColumn>[
                DsGridColumn(key: 'name', title: 'Name'),
                DsGridColumn(
                  key: 'active',
                  title: 'Active',
                  type: DsCellType.checkbox,
                ),
              ],
              rows: <DsGridRow>[
                DsGridRow(id: 'a', cells: {'name': 'Acme', 'active': true}),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(_gridSide(tester), DsTokens.light().checkboxSize);

      await tester.tap(find.text('reskin'));
      await tester.pumpAndSettle();
      // A skin moves the atom and the grid together; the grid keeps no number
      // of its own.
      expect(_gridSide(tester), 26);
    });

    testWidgets('the atom and the grid agree under one theme', (tester) async {
      await pumpDs(
        tester,
        Column(
          children: <Widget>[
            DsCheckbox(value: true, label: 'Ready', onChanged: (_) {}),
            const SizedBox(
              height: 200,
              width: 700,
              child: DsDataGrid(
                columns: <DsGridColumn>[
                  DsGridColumn(
                    key: 'active',
                    title: 'Active',
                    type: DsCellType.checkbox,
                  ),
                ],
                rows: <DsGridRow>[
                  DsGridRow(id: 'a', cells: {'active': true}),
                ],
              ),
            ),
          ],
        ),
        surfaceSize: const Size(1000, 800),
      );
      await tester.pumpAndSettle();
      expect(_gridSide(tester), _atomSide(tester));
    });
  });
}
