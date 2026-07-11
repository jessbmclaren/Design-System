import 'package:flutter/material.dart';
import '../../tokens/ds_icons.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';
import '../atoms/ds_badge.dart';
import '../atoms/ds_button.dart';
import '../atoms/ds_icon.dart';
import '../atoms/ds_switch.dart';
import '../molecules/ds_select.dart';
import '../molecules/ds_text_field.dart';
import 'ds_data_grid.dart';
import 'ds_filter_bar.dart';

/// The kind of consequence a [DsPolicyRule] enforces on the records a
/// [DsPolicy] applies to.
///
/// Each effect maps to one of the shared semantic badge palettes so a rule
/// reads consistently with status badges elsewhere in the system (see
/// [DsPolicyBuilder]):
///
/// * [require]: the record must satisfy something. Rendered neutral/info.
/// * [restrict]: the record is blocked or forbidden. Rendered danger.
/// * [warn]: the record is flagged for attention. Rendered warning.
/// * [autoTag]: the record is automatically labelled. Rendered success.
enum DsPolicyEffect {
  /// Mandate that matching records satisfy the rule's description.
  require,

  /// Forbid or block matching records.
  restrict,

  /// Flag matching records for attention without blocking them.
  warn,

  /// Automatically apply a tag or label to matching records.
  autoTag,
}

/// A human-readable label for each [DsPolicyEffect], shown in the effect picker
/// and on the rule's colour badge.
extension DsPolicyEffectLabel on DsPolicyEffect {
  /// The label shown for this effect.
  String get label => switch (this) {
        DsPolicyEffect.require => 'Require',
        DsPolicyEffect.restrict => 'Restrict',
        DsPolicyEffect.warn => 'Warn',
        DsPolicyEffect.autoTag => 'Auto-tag',
      };
}

/// The badge variant used to colour a [DsPolicyEffect].
DsBadgeVariant _variantForEffect(DsPolicyEffect effect) => switch (effect) {
      DsPolicyEffect.require => DsBadgeVariant.neutral,
      DsPolicyEffect.restrict => DsBadgeVariant.danger,
      DsPolicyEffect.warn => DsBadgeVariant.warning,
      DsPolicyEffect.autoTag => DsBadgeVariant.success,
    };

/// A single consequence within a [DsPolicy]: apply [effect] with the given
/// [description].
///
/// [description] is the human phrase completing the effect, for example
/// `'a monthly safety inspection'` for [DsPolicyEffect.require], reading as
/// "Require a monthly safety inspection".
@immutable
class DsPolicyRule {
  /// Creates a policy rule.
  const DsPolicyRule({required this.effect, required this.description});

  /// The consequence this rule enforces.
  final DsPolicyEffect effect;

  /// The phrase describing what the [effect] applies to.
  final String description;

  /// Returns a copy with the given fields replaced.
  DsPolicyRule copyWith({DsPolicyEffect? effect, String? description}) {
    return DsPolicyRule(
      effect: effect ?? this.effect,
      description: description ?? this.description,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DsPolicyRule &&
          runtimeType == other.runtimeType &&
          effect == other.effect &&
          description == other.description;

  @override
  int get hashCode => Object.hash(effect, description);
}

/// An immutable policy: a named rule set that applies to the records matching a
/// [filter].
///
/// A policy is the access-policy / automation class of the table epic. Its
/// [filter] (reused from the Wave 3 filter model) describes *who or what* the
/// policy is in scope for, and its [rules] describe *what happens* to those
/// records. [appliesTo] delegates to [DsFilter.matches], so the very policy
/// authored in a [DsPolicyBuilder] can decide elsewhere whether a given record
/// is governed by it.
@immutable
class DsPolicy {
  /// Creates a policy. An empty [filter] means the policy applies to every
  /// record.
  const DsPolicy({
    required this.id,
    required this.name,
    this.description,
    this.filter = const DsFilter(),
    this.rules = const <DsPolicyRule>[],
    this.enabled = true,
  });

  /// The stable identifier for this policy.
  final String id;

  /// The policy's display name.
  final String name;

  /// An optional longer description of the policy's intent.
  final String? description;

  /// Who or what the policy applies to. An empty filter matches every record.
  final DsFilter filter;

  /// The consequences applied to matching records, in display order.
  final List<DsPolicyRule> rules;

  /// Whether the policy is active. A disabled policy still edits, but reads
  /// visibly muted.
  final bool enabled;

  /// Returns a copy with the given fields replaced.
  DsPolicy copyWith({
    String? id,
    String? name,
    String? description,
    DsFilter? filter,
    List<DsPolicyRule>? rules,
    bool? enabled,
  }) {
    return DsPolicy(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      filter: filter ?? this.filter,
      rules: rules ?? this.rules,
      enabled: enabled ?? this.enabled,
    );
  }

  /// Whether [row] is in scope for this policy, evaluating the [filter] against
  /// the matching column in [columns] for type-aware comparisons. Delegates to
  /// [DsFilter.matches], so an empty filter puts every record in scope.
  bool appliesTo(DsGridRow row, List<DsGridColumn> columns) =>
      filter.matches(row, columns);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DsPolicy &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          filter == other.filter &&
          _rulesEqual(rules, other.rules) &&
          enabled == other.enabled;

  @override
  int get hashCode =>
      Object.hash(id, name, description, filter, Object.hashAll(rules), enabled);
}

bool _rulesEqual(List<DsPolicyRule> a, List<DsPolicyRule> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// An Airtable-class policy builder for a [DsDataGrid]'s [columns].
///
/// A policy names a rule set, scopes it to the records matching a filter and
/// lists the consequences applied to them. The editor stacks four parts:
///
/// * a header with the policy [DsPolicy.name] (a [DsTextField]) and an
///   enable/disable [DsSwitch] (a disabled policy reads visibly muted);
/// * an optional [DsPolicy.description] field;
/// * an **Applies when** section: an embedded [DsFilterBar] bound to
///   [DsPolicy.filter], with a subtle hint that the policy applies to *all*
///   records while the filter is empty;
/// * a **Then** section: a list of `[effect] [description] [remove]` rule rows,
///   each effect a coloured [DsBadge] plus a [DsSelect], with an "Add rule"
///   action.
///
/// The widget is fully controlled: it never holds its own copy of the policy.
/// Every edit reports a brand-new immutable [DsPolicy] through [onChanged], and
/// [DsPolicy.appliesTo] can evaluate a record against the same filter the user
/// authored here. All colours, spacing, radii and typography come from
/// [DsTokens], so it re-brands with the active theme.
///
/// ## Responsiveness & accessibility
///
/// Below [compactBreakpoint] the header stacks the switch beneath the name and
/// each rule row stacks its controls, so nothing overflows a 320dp phone; at or
/// above it they lay out side by side. Every control is a labelled, focusable
/// target and the widget runs no timers, so it renders a stable frame for tests
/// and screenshots.
class DsPolicyBuilder extends StatelessWidget {
  /// Creates a policy builder.
  const DsPolicyBuilder({
    super.key,
    required this.columns,
    required this.value,
    required this.onChanged,
    this.compactBreakpoint = 600,
  });

  /// The columns the policy's filter can reference. Their [DsGridColumn.type]
  /// selects the operators and value control shown by the embedded
  /// [DsFilterBar].
  final List<DsGridColumn> columns;

  /// The policy being edited. The widget is controlled: it renders this value
  /// and reports edits through [onChanged].
  final DsPolicy value;

  /// Called with a new immutable [DsPolicy] whenever the user edits the name,
  /// description, enabled state, filter or rules.
  final ValueChanged<DsPolicy> onChanged;

  /// The width, in logical pixels, below which the header and each rule stack
  /// their controls vertically instead of laying them out on one row.
  final double compactBreakpoint;

  void _emit(DsPolicy next) => onChanged(next);

  void _setName(String name) => _emit(value.copyWith(name: name));

  void _setDescription(String description) =>
      _emit(value.copyWith(description: description));

  void _setEnabled(bool enabled) => _emit(value.copyWith(enabled: enabled));

  void _setFilter(DsFilter filter) => _emit(value.copyWith(filter: filter));

  void _addRule() {
    _emit(value.copyWith(
      rules: [
        ...value.rules,
        const DsPolicyRule(effect: DsPolicyEffect.require, description: ''),
      ],
    ));
  }

  void _removeRule(int index) {
    final next = List<DsPolicyRule>.of(value.rules)..removeAt(index);
    _emit(value.copyWith(rules: next));
  }

  void _setRule(int index, DsPolicyRule rule) {
    final next = List<DsPolicyRule>.of(value.rules);
    next[index] = rule;
    _emit(value.copyWith(rules: next));
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final compact = maxWidth < compactBreakpoint;

        return DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.formBackgroundColor,
            border: Border.all(color: tokens.colorBorder),
            borderRadius: BorderRadius.circular(tokens.formBorderRadius),
          ),
          child: Padding(
            padding: EdgeInsets.all(tokens.spacingUnit * 1.5),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(tokens, compact),
                SizedBox(height: tokens.spacingUnit * 1.5),
                // A disabled policy still edits but reads visibly muted below
                // the header, so the enable switch stays crisp and reachable.
                Opacity(
                  opacity: value.enabled ? 1 : 0.5,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _PolicyTextField(
                        key: const ValueKey<String>('ds-policy-description'),
                        initialText: value.description ?? '',
                        label: 'Description',
                        hintText: 'What is this policy for?',
                        maxLines: 2,
                        onChanged: _setDescription,
                      ),
                      SizedBox(height: tokens.spacingUnit * 2),
                      _buildAppliesWhen(tokens),
                      SizedBox(height: tokens.spacingUnit * 2),
                      _buildThen(tokens, compact),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(DsTokens tokens, bool compact) {
    final name = _PolicyTextField(
      key: const ValueKey<String>('ds-policy-name'),
      initialText: value.name,
      label: 'Policy name',
      hintText: 'Name this policy',
      onChanged: _setName,
    );
    final toggle = DsSwitch(
      value: value.enabled,
      label: value.enabled ? 'Enabled' : 'Disabled',
      onChanged: _setEnabled,
    );

    if (compact) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          name,
          SizedBox(height: tokens.spacingUnit),
          Align(alignment: Alignment.centerLeft, child: toggle),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: name),
        SizedBox(width: tokens.spacingUnit * 1.5),
        Padding(
          // Nudge the switch to sit level with the field, not its label.
          padding: EdgeInsets.only(bottom: tokens.spacingUnit / 2),
          child: toggle,
        ),
      ],
    );
  }

  Widget _buildAppliesWhen(DsTokens tokens) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle(tokens, 'Applies when'),
        SizedBox(height: tokens.spacingUnit),
        DsFilterBar(
          columns: columns,
          value: value.filter,
          initiallyOpen: true,
          compactBreakpoint: compactBreakpoint,
          onChanged: _setFilter,
        ),
        if (value.filter.isEmpty) ...[
          SizedBox(height: tokens.spacingUnit),
          Text(
            'This policy applies to all records.',
            style: tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText),
          ),
        ],
      ],
    );
  }

  Widget _buildThen(DsTokens tokens, bool compact) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle(tokens, 'Then'),
        SizedBox(height: tokens.spacingUnit),
        if (value.rules.isEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'No rules yet',
              style:
                  tokens.bodyMd.toTextStyle(color: tokens.colorSecondaryText),
            ),
          )
        else
          for (var i = 0; i < value.rules.length; i++) ...[
            if (i > 0) SizedBox(height: tokens.spacingUnit),
            _buildRuleRow(tokens, i, value.rules[i], compact),
          ],
        SizedBox(height: tokens.spacingUnit * 1.5),
        Align(
          alignment: Alignment.centerLeft,
          child: DsButton(
            label: 'Add rule',
            variant: DsButtonVariant.secondary,
            icon: DsIcons.add,
            onPressed: _addRule,
          ),
        ),
      ],
    );
  }

  Widget _buildRuleRow(
    DsTokens tokens,
    int index,
    DsPolicyRule rule,
    bool compact,
  ) {
    final badge = DsBadge(
      label: rule.effect.label,
      variant: _variantForEffect(rule.effect),
    );
    final effectSelect = DsSelect<DsPolicyEffect>(
      value: rule.effect,
      hintText: 'Effect',
      options: [
        for (final effect in DsPolicyEffect.values)
          DsSelectOption<DsPolicyEffect>(value: effect, label: effect.label),
      ],
      onChanged: (effect) {
        if (effect != null) _setRule(index, rule.copyWith(effect: effect));
      },
    );
    final effectCell = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        badge,
        SizedBox(width: tokens.spacingUnit),
        Expanded(child: effectSelect),
      ],
    );
    final description = _PolicyTextField(
      key: ValueKey<String>('ds-policy-rule-$index'),
      initialText: rule.description,
      hintText: 'e.g. a monthly safety inspection',
      onChanged: (text) => _setRule(index, rule.copyWith(description: text)),
    );
    final remove = _IconAction(
      icon: DsIcons.close,
      tooltip: 'Remove rule',
      onTap: () => _removeRule(index),
    );

    if (compact) {
      return DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: tokens.colorBorder),
          borderRadius: BorderRadius.circular(tokens.formBorderRadius),
        ),
        child: Padding(
          padding: EdgeInsets.all(tokens.spacingUnit),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(child: effectCell),
                  remove,
                ],
              ),
              SizedBox(height: tokens.spacingUnit),
              description,
            ],
          ),
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 5, child: effectCell),
        SizedBox(width: tokens.spacingUnit),
        Expanded(flex: 6, child: description),
        SizedBox(width: tokens.spacingUnit / 2),
        remove,
      ],
    );
  }

  Widget _sectionTitle(DsTokens tokens, String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: tokens.labelMd
            .toTextStyle(color: tokens.colorText)
            .copyWith(fontWeight: tokens.strongLabelFontWeight),
      ),
    );
  }
}

/// A small icon-only affordance (remove) with a >=48dp target, a tooltip and a
/// semantics button label.
class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: Material(
          type: MaterialType.transparency,
          child: InkResponse(
            onTap: onTap,
            radius: 24,
            child: SizedBox(
              width: 40,
              height: 48,
              child: Center(
                child: DsIcon(
                  icon: icon,
                  size: DsIconSize.md,
                  color: tokens.colorSecondaryText,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A self-contained text input that owns its controller so keystrokes never
/// reset the field, seeded once from [initialText] (the widget is re-keyed when
/// its target, the policy field or a rule index, changes).
class _PolicyTextField extends StatefulWidget {
  const _PolicyTextField({
    super.key,
    required this.initialText,
    required this.onChanged,
    this.label,
    this.hintText,
    this.maxLines = 1,
  });

  final String initialText;
  final ValueChanged<String> onChanged;
  final String? label;
  final String? hintText;
  final int maxLines;

  @override
  State<_PolicyTextField> createState() => _PolicyTextFieldState();
}

class _PolicyTextFieldState extends State<_PolicyTextField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initialText);

  @override
  void didUpdateWidget(covariant _PolicyTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // The parent is the source of truth: when the value flowing in changes
    // (a rule removed/reordered above this row, or a whole new policy swapped
    // in) reseed the controller. Comparing against the controller's own text
    // (not oldWidget) means an in-progress keystroke (which round-trips back as
    // the same string) never reseeds, so the cursor is left alone.
    if (widget.initialText != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.initialText,
        selection:
            TextSelection.collapsed(offset: widget.initialText.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DsTextField(
      controller: _controller,
      label: widget.label,
      hintText: widget.hintText,
      maxLines: widget.maxLines,
      onChanged: widget.onChanged,
    );
  }
}
