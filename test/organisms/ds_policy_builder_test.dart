import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

final _columns = <DsGridColumn>[
  const DsGridColumn(key: 'name', title: 'Name'),
  const DsGridColumn(key: 'amount', title: 'Amount', type: DsCellType.number),
  const DsGridColumn(
    key: 'status',
    title: 'Status',
    type: DsCellType.status,
    options: [
      DsGridOption(value: 'active', label: 'Active'),
      DsGridOption(value: 'closed', label: 'Closed'),
    ],
  ),
];

DsGridRow _row(Map<String, Object?> cells) => DsGridRow(id: 'r', cells: cells);

/// A controlled host that feeds edits back into [DsPolicyBuilder], as a real
/// caller would, and reports every emitted policy through [onChanged].
class _PolicyHarness extends StatefulWidget {
  const _PolicyHarness({required this.initial, this.onChanged});

  final DsPolicy initial;
  final ValueChanged<DsPolicy>? onChanged;

  @override
  State<_PolicyHarness> createState() => _PolicyHarnessState();
}

class _PolicyHarnessState extends State<_PolicyHarness> {
  late DsPolicy _policy = widget.initial;

  @override
  Widget build(BuildContext context) {
    return DsPolicyBuilder(
      columns: _columns,
      value: _policy,
      onChanged: (policy) {
        setState(() => _policy = policy);
        widget.onChanged?.call(policy);
      },
    );
  }
}

void main() {
  group('DsPolicyBuilder rendering', () {
    testWidgets('renders the policy name and its rules', (tester) async {
      await pumpDs(
        tester,
        DsPolicyBuilder(
          columns: _columns,
          value: const DsPolicy(
            id: 'p1',
            name: 'Safety policy',
            rules: [
              DsPolicyRule(
                effect: DsPolicyEffect.require,
                description: 'a monthly safety inspection',
              ),
              DsPolicyRule(
                effect: DsPolicyEffect.warn,
                description: 'a signed waiver',
              ),
            ],
          ),
          onChanged: (_) {},
        ),
        surfaceSize: const Size(1000, 900),
      );
      await tester.pump();
      expect(find.text('Safety policy'), findsOneWidget);
      expect(find.text('a monthly safety inspection'), findsOneWidget);
      expect(find.text('a signed waiver'), findsOneWidget);
      expect(find.text('Add rule'), findsOneWidget);
      // The empty filter surfaces the "all records" hint.
      expect(find.text('This policy applies to all records.'), findsOneWidget);
    });
  });

  group('DsPolicyBuilder editing', () {
    testWidgets('editing the name emits a policy with the new name',
        (tester) async {
      DsPolicy? last;
      await pumpDs(
        tester,
        _PolicyHarness(
          initial: const DsPolicy(id: 'p1', name: 'Draft'),
          onChanged: (p) => last = p,
        ),
        surfaceSize: const Size(1000, 900),
      );
      await tester.pump();
      // The name field is the first text input in the editor.
      await tester.enterText(find.byType(TextField).first, 'Renamed policy');
      await tester.pump();
      expect(last, isNotNull);
      expect(last!.name, 'Renamed policy');
    });

    testWidgets('toggling enabled emits enabled:false', (tester) async {
      DsPolicy? last;
      await pumpDs(
        tester,
        _PolicyHarness(
          initial: const DsPolicy(id: 'p1', name: 'Draft'),
          onChanged: (p) => last = p,
        ),
        surfaceSize: const Size(1000, 900),
      );
      await tester.pump();
      await tester.tap(find.byType(DsSwitch));
      await tester.pumpAndSettle();
      expect(last, isNotNull);
      expect(last!.enabled, isFalse);
    });

    testWidgets('adding a rule emits one more DsPolicyRule', (tester) async {
      DsPolicy? last;
      await pumpDs(
        tester,
        _PolicyHarness(
          initial: const DsPolicy(id: 'p1', name: 'Draft'),
          onChanged: (p) => last = p,
        ),
        surfaceSize: const Size(1000, 900),
      );
      await tester.pump();
      await tester.tap(find.text('Add rule'));
      await tester.pump();
      expect(last, isNotNull);
      expect(last!.rules, hasLength(1));
      expect(last!.rules.single.effect, DsPolicyEffect.require);
    });

    testWidgets("changing a rule's effect emits the updated rule",
        (tester) async {
      DsPolicy? last;
      await pumpDs(
        tester,
        _PolicyHarness(
          initial: const DsPolicy(
            id: 'p1',
            name: 'Draft',
            rules: [
              DsPolicyRule(
                effect: DsPolicyEffect.require,
                description: 'an audit',
              ),
            ],
          ),
          onChanged: (p) => last = p,
        ),
        surfaceSize: const Size(1000, 900),
      );
      await tester.pump();
      await tester.tap(find.byType(DropdownButtonFormField<DsPolicyEffect>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Restrict').last);
      await tester.pumpAndSettle();
      expect(last, isNotNull);
      expect(last!.rules.single.effect, DsPolicyEffect.restrict);
      expect(last!.rules.single.description, 'an audit');
    });

    testWidgets("changing a rule's description emits the updated rule",
        (tester) async {
      DsPolicy? last;
      await pumpDs(
        tester,
        _PolicyHarness(
          initial: const DsPolicy(
            id: 'p1',
            name: 'Draft',
            rules: [
              DsPolicyRule(
                effect: DsPolicyEffect.require,
                description: '',
              ),
            ],
          ),
          onChanged: (p) => last = p,
        ),
        surfaceSize: const Size(1000, 900),
      );
      await tester.pump();
      // Fields in order: name (0), policy description (1), rule description (2).
      await tester.enterText(find.byType(TextField).at(2), 'a background check');
      await tester.pump();
      expect(last, isNotNull);
      expect(last!.rules.single.description, 'a background check');
      expect(last!.rules.single.effect, DsPolicyEffect.require);
    });

    testWidgets('editing the embedded filter emits a policy whose filter changed',
        (tester) async {
      DsPolicy? last;
      await pumpDs(
        tester,
        _PolicyHarness(
          initial: const DsPolicy(id: 'p1', name: 'Draft'),
          onChanged: (p) => last = p,
        ),
        surfaceSize: const Size(1000, 900),
      );
      await tester.pump();
      expect(find.text('This policy applies to all records.'), findsOneWidget);
      // The embedded filter bar starts open, so "Add condition" is visible.
      await tester.tap(find.text('Add condition'));
      await tester.pump();
      expect(last, isNotNull);
      expect(last!.filter.conditions, hasLength(1));
      expect(last!.filter.conditions.first.columnKey, 'name');
    });

    testWidgets('removing a rule leaves the survivors showing the right text',
        (tester) async {
      // Regression: rule fields must reflect the value after a non-last rule is
      // removed, not the stale text of the row that used to sit at that index.
      DsPolicy? last;
      await pumpDs(
        tester,
        _PolicyHarness(
          initial: const DsPolicy(
            id: 'p1',
            name: 'Draft',
            // Empty filter -> the only Icons.close are the rule removals.
            rules: [
              DsPolicyRule(effect: DsPolicyEffect.require, description: 'alpha rule'),
              DsPolicyRule(effect: DsPolicyEffect.warn, description: 'beta rule'),
            ],
          ),
          onChanged: (p) => last = p,
        ),
        surfaceSize: const Size(1000, 900),
      );
      await tester.pump();
      // Remove the FIRST rule.
      await tester.tap(find.byIcon(DsIcons.close).first);
      await tester.pump();
      expect(last!.rules, hasLength(1));
      expect(last!.rules.first.description, 'beta rule');
      // The surviving field shows 'beta rule', not the removed 'alpha rule'.
      expect(find.text('beta rule'), findsOneWidget);
      expect(find.text('alpha rule'), findsNothing);
    });
  });

  group('DsPolicy.appliesTo', () {
    test('returns true for an in-scope row and false for an out-of-scope row',
        () {
      const policy = DsPolicy(
        id: 'p1',
        name: 'High-value accounts',
        filter: DsFilter(conditions: [
          DsFilterCondition(
            columnKey: 'amount',
            operator: DsFilterOperator.greaterThan,
            value: 1000,
          ),
        ]),
      );
      expect(policy.appliesTo(_row({'amount': 2500}), _columns), isTrue);
      expect(policy.appliesTo(_row({'amount': 250}), _columns), isFalse);
    });

    test('an empty filter puts every record in scope', () {
      const policy = DsPolicy(id: 'p1', name: 'Everyone');
      expect(policy.appliesTo(_row({'amount': 1}), _columns), isTrue);
    });
  });

  testWidgets('no overflow across device widths', (tester) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1.0;
    for (final width in <double>[320, 768, 1440]) {
      tester.view.physicalSize = Size(width, 1600);
      await tester.pumpWidget(
        MaterialApp(
          theme: DsTheme.light(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: DsPolicyBuilder(
                columns: _columns,
                value: const DsPolicy(
                  id: 'p1',
                  name: 'Safety policy',
                  description: 'Keeps records compliant.',
                  filter: DsFilter(conditions: [
                    DsFilterCondition(
                      columnKey: 'status',
                      operator: DsFilterOperator.is_,
                      value: 'active',
                    ),
                  ]),
                  rules: [
                    DsPolicyRule(
                      effect: DsPolicyEffect.require,
                      description: 'a monthly safety inspection',
                    ),
                    DsPolicyRule(
                      effect: DsPolicyEffect.restrict,
                      description: 'access without a badge',
                    ),
                  ],
                ),
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull, reason: 'overflow at ${width}dp');
    }
  });
}
