import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  group('DsSettingsView', () {
    testWidgets('renders header, section titles and descriptions', (
      tester,
    ) async {
      await pumpDs(
        tester,
        const SizedBox(
          height: 900,
          child: DsSettingsView(
            header: Text('Settings'),
            sections: <DsSettingsSection>[
              DsSettingsSection(
                title: 'Account',
                description: 'Manage how you sign in.',
                children: <Widget>[Text('Email row')],
              ),
              DsSettingsSection(
                title: 'Notifications',
                children: <Widget>[Text('Email toggle')],
              ),
            ],
          ),
        ),
      );

      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Manage how you sign in.'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Email row'), findsOneWidget);
      expect(find.text('Email toggle'), findsOneWidget);
    });

    testWidgets('renders the footer widget', (tester) async {
      await pumpDs(
        tester,
        const SizedBox(
          height: 900,
          child: DsSettingsView(
            footer: Text('Sign out'),
            sections: <DsSettingsSection>[
              DsSettingsSection(
                title: 'Account',
                children: <Widget>[Text('Row')],
              ),
            ],
          ),
        ),
      );

      expect(find.text('Sign out'), findsOneWidget);
    });

    testWidgets('inserts dividers between section children', (tester) async {
      await pumpDs(
        tester,
        const SizedBox(
          height: 900,
          child: DsSettingsView(
            sections: <DsSettingsSection>[
              DsSettingsSection(
                title: 'Account',
                children: <Widget>[
                  Text('Row one'),
                  Text('Row two'),
                  Text('Row three'),
                ],
              ),
            ],
          ),
        ),
      );

      // Three children within one section => two hairline dividers.
      expect(find.byType(Divider), findsNWidgets(2));
    });

    testWidgets('fires a callback when a section row is tapped', (
      tester,
    ) async {
      var tapped = false;
      await pumpDs(
        tester,
        SizedBox(
          height: 900,
          child: DsSettingsView(
            sections: <DsSettingsSection>[
              DsSettingsSection(
                title: 'Account',
                children: <Widget>[
                  GestureDetector(
                    onTap: () => tapped = true,
                    child: const Text('Tap me'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

      await tester.tap(find.text('Tap me'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('renders without overflow on a 320dp phone', (tester) async {
      await pumpDs(
        tester,
        const SizedBox(
          height: 900,
          child: DsSettingsView(
            header: Text('Settings'),
            sections: <DsSettingsSection>[
              DsSettingsSection(
                title: 'Account',
                description: 'Manage how you sign in.',
                children: <Widget>[Text('Row one'), Text('Row two')],
              ),
              DsSettingsSection(
                title: 'Notifications',
                children: <Widget>[Text('Row three')],
              ),
            ],
            footer: Text('Sign out'),
          ),
        ),
        surfaceSize: const Size(320, 900),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders without overflow on a large desktop', (tester) async {
      await pumpDs(
        tester,
        const SizedBox(
          height: 900,
          child: DsSettingsView(
            header: Text('Settings'),
            sections: <DsSettingsSection>[
              DsSettingsSection(
                title: 'Account',
                description: 'Manage how you sign in.',
                children: <Widget>[Text('Row one'), Text('Row two')],
              ),
              DsSettingsSection(
                title: 'Notifications',
                children: <Widget>[Text('Row three')],
              ),
            ],
            footer: Text('Sign out'),
          ),
        ),
        surfaceSize: const Size(1200, 900),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
