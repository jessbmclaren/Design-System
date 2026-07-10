import 'package:design_system/design_system.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// A light theme whose links rest without a decoration, so the hover and
/// focus underline is observable.
ThemeData plainLinkTheme() => DsTheme.light(
      tokens: DsTokens.light().copyWith(
        actionPrimaryTextDecorationLine: TextDecoration.none,
      ),
    );

TextDecoration linkDecoration(WidgetTester tester, String label) {
  final text = tester.widget<Text>(find.text(label));
  return text.style!.decoration!;
}

void main() {
  testWidgets('renders its label text', (tester) async {
    await pumpDs(tester, const DsLink(label: 'View details'));

    expect(find.text('View details'), findsOneWidget);
  });

  testWidgets('fires onPressed when tapped', (tester) async {
    var tapped = 0;
    await pumpDs(
      tester,
      DsLink(label: 'Open', onPressed: () => tapped++),
    );

    await tester.tap(find.byType(DsLink));
    await tester.pump();

    expect(tapped, 1);
  });

  testWidgets('is disabled when onPressed is null', (tester) async {
    await pumpDs(tester, const DsLink(label: 'Disabled'));

    final inkWell = tester.widget<InkWell>(find.byType(InkWell));
    expect(inkWell.onTap, isNull);
  });

  testWidgets('external appends an open-in-new glyph', (tester) async {
    await pumpDs(
      tester,
      DsLink(label: 'Docs', onPressed: () {}, external: true),
    );

    expect(find.byIcon(DsIcons.externalLink), findsOneWidget);
  });

  testWidgets('renders a custom trailing icon', (tester) async {
    await pumpDs(
      tester,
      DsLink(
        label: 'More',
        onPressed: () {},
        trailingIcon: Icons.chevron_right,
      ),
    );

    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
  });

  testWidgets('secondary variant renders its label', (tester) async {
    await pumpDs(
      tester,
      DsLink(
        label: 'Secondary',
        onPressed: () {},
        variant: DsLinkVariant.secondary,
      ),
    );

    expect(find.text('Secondary'), findsOneWidget);
  });

  testWidgets('underlines on hover', (tester) async {
    await pumpDs(
      tester,
      DsLink(label: 'Open', onPressed: () {}),
      theme: plainLinkTheme(),
    );

    expect(
      linkDecoration(tester, 'Open').contains(TextDecoration.underline),
      isFalse,
    );

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();

    await gesture.moveTo(tester.getCenter(find.text('Open')));
    await tester.pump();

    expect(
      linkDecoration(tester, 'Open').contains(TextDecoration.underline),
      isTrue,
    );

    await gesture.moveTo(Offset.zero);
    await tester.pump();

    expect(
      linkDecoration(tester, 'Open').contains(TextDecoration.underline),
      isFalse,
    );
  });

  testWidgets('underlines on keyboard focus', (tester) async {
    await pumpDs(
      tester,
      DsLink(label: 'Open', onPressed: () {}),
      theme: plainLinkTheme(),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();

    expect(
      linkDecoration(tester, 'Open').contains(TextDecoration.underline),
      isTrue,
    );
  });

  testWidgets('maxLines defaults to one line and is overridable',
      (tester) async {
    await pumpDs(tester, const DsLink(label: 'View details'));
    expect(tester.widget<Text>(find.text('View details')).maxLines, 1);

    await pumpDs(
      tester,
      const DsLink(label: 'View details', maxLines: 3),
    );
    expect(tester.widget<Text>(find.text('View details')).maxLines, 3);
  });

  testWidgets('padded extends the tap target to 48dp without growing the '
      'laid-out size', (tester) async {
    var taps = 0;
    await pumpDs(
      tester,
      DsLink(label: 'Open', onPressed: () => taps++, padded: true),
    );

    final rect = tester.getRect(find.byType(DsLink));
    // The layout box keeps its natural, sub-48dp height.
    expect(rect.height, lessThan(48));

    // A tap just past the visible edge, within the 48dp zone, still fires.
    await tester.tapAt(rect.center + Offset(0, (rect.height / 2) + 6));
    expect(taps, 1);
  });

  testWidgets('without padded the same edge tap misses', (tester) async {
    var taps = 0;
    await pumpDs(
      tester,
      DsLink(label: 'Open', onPressed: () => taps++),
    );

    final rect = tester.getRect(find.byType(DsLink));
    await tester.tapAt(rect.center + Offset(0, (rect.height / 2) + 6));
    expect(taps, 0);
  });

  testWidgets('renders without overflow from small phone to desktop',
      (tester) async {
    await pumpDs(
      tester,
      DsLink(
        label: 'A fairly long hyperlink label that may need to ellipsize',
        onPressed: () {},
        external: true,
        trailingIcon: Icons.chevron_right,
      ),
      surfaceSize: const Size(320, 900),
    );
    expect(tester.takeException(), isNull);

    await pumpDs(
      tester,
      DsLink(
        label: 'A fairly long hyperlink label that may need to ellipsize',
        onPressed: () {},
        external: true,
        trailingIcon: Icons.chevron_right,
      ),
      surfaceSize: const Size(1200, 900),
    );
    expect(tester.takeException(), isNull);
  });
}
