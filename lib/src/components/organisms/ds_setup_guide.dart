import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icons.dart';
import '../../util/ds_motion.dart';
import '../atoms/ds_badge.dart';
import '../atoms/ds_link.dart';
import '../atoms/ds_progress_bar.dart';
import '../atoms/ds_tooltip.dart';

/// Diameter of a task's leading status marker.
const double _markerSize = 18;

/// Width of the card in its floating (not [DsSetupGuide.fullWidth])
/// presentation.
const double _floatingWidth = 320;

/// Thickness of the header's progress bar.
const double _barHeight = 4;

/// Minimum height of the card's fixed chrome: the hairline border, the card
/// padding, the 48dp disclosure header, the progress bar and the gaps around
/// it. A [DsSetupGuide.maxHeight] below this is clamped up to it, so a
/// starved budget degrades to a chrome-only card instead of overflowing.
double _chromeMinHeight(DsTokens tokens) =>
    2 +
    tokens.spacingUnit * 2 * 2 +
    48 +
    tokens.spacingUnit +
    _barHeight +
    tokens.spacingUnit * 1.5;

/// One task in a [DsSetupGuide] checklist.
///
/// A task is plain data: the guide derives each row's presentation from the
/// [done], [pending] and [locked] flags. A task in none of those states is an
/// open to-do; give it an [onTap] so the row routes the user to the work.
@immutable
class DsSetupTask {
  /// Creates a setup task described by [label].
  const DsSetupTask({
    required this.label,
    this.done = false,
    this.pending = false,
    this.locked = false,
    this.lockedMessage,
    this.onTap,
    this.animateCrossOff = false,
  });

  /// The short, human-readable name of the task. Ellipsizes on one line so a
  /// row never overflows on narrow screens.
  final String label;

  /// Whether the task is complete. Done tasks show a filled check marker,
  /// count towards the header's progress and are no longer tappable.
  final bool done;

  /// Whether the task is under way but awaiting an outcome (a submitted
  /// verification, say). Pending tasks show a warning pill and are not
  /// tappable until they resolve.
  final bool pending;

  /// Whether the task is gated behind other work. Locked rows are dimmed and,
  /// when [lockedMessage] is set, explain the gate in a tooltip on hover and
  /// on tap.
  final bool locked;

  /// Names the real blocker for a [locked] task ("Verify your business to go
  /// live"). Shown in the locked row's tooltip; null shows no tooltip.
  final String? lockedMessage;

  /// Called when the row is tapped. Ignored while the task is [done],
  /// [pending] or [locked]; a null callback leaves the row static.
  final VoidCallback? onTap;

  /// Whether the task crosses itself off and clears out of the list once
  /// [done]. When the task completes while the guide is on screen the row
  /// plays a strike-through then collapses away, exactly once; under reduced
  /// motion, and on any later build, it is already cleared. Tasks without
  /// this flag stay listed with a done marker instead.
  final bool animateCrossOff;
}

/// A collapsible "getting started" checklist card.
///
/// [DsSetupGuide] presents the remaining steps of a setup flow as a compact
/// card: a disclosure header with a done count, an animated progress bar and
/// the task list itself. Collapsed, the list gives way to a single "Next"
/// line naming the first task the user can act on, so the card still points
/// somewhere useful as a slim bar.
///
/// The guide is a controlled component: every task state lives in
/// [DsSetupTask] flags owned by the caller, and the widget only derives
/// presentation from them. Only the open or collapsed disclosure state is
/// internal, seeded by [initiallyCollapsed].
///
/// Float the card at its default 320dp width, or set [fullWidth] to stretch
/// it across a bottom-docked panel on mobile. Give it a [maxHeight] when the
/// viewport is short and the task list scrolls inside the card instead of
/// clipping.
///
/// All colours, radii, type and shadows come from [DsTokens], and every
/// animation resolves through [DsMotion] so it settles to a still frame under
/// reduced motion.
///
/// ```dart
/// DsSetupGuide(
///   title: 'Setup guide',
///   tasks: [
///     DsSetupTask(label: 'Verify your email', done: emailVerified),
///     DsSetupTask(label: 'Add your vehicles', onTap: _openVehicles),
///     DsSetupTask(
///       label: 'Go live',
///       locked: true,
///       lockedMessage: 'Add your vehicles to go live',
///     ),
///   ],
/// )
/// ```
class DsSetupGuide extends StatefulWidget {
  /// Creates a setup guide card over [tasks].
  const DsSetupGuide({
    super.key,
    required this.title,
    required this.tasks,
    this.collapsedSummary,
    this.initiallyCollapsed = false,
    this.fullWidth = false,
    this.maxHeight,
  });

  /// The card heading. The disclosure header announces it once, alongside
  /// the done count.
  final String title;

  /// The tasks to list, in display order. Labels should be unique; they key
  /// each row's animation state.
  final List<DsSetupTask> tasks;

  /// Shown on the collapsed card when no task is actionable (everything is
  /// done, pending or locked), in place of the "Next" line. Null shows
  /// nothing.
  final String? collapsedSummary;

  /// Whether to start with the task list closed, just the header bar and
  /// progress. Expanding it stays the user's deliberate action.
  final bool initiallyCollapsed;

  /// Whether the card stretches to the width its parent provides instead of
  /// the floating 320dp panel. Use this for a bottom-docked presentation on
  /// mobile. The parent must bound the card's width: in an unbounded-width
  /// context, a plain Row slot for instance, wrap the card in an Expanded.
  final bool fullWidth;

  /// A height budget for the card. When the task list cannot fit it scrolls
  /// inside the card instead of clipping off-screen. A budget tighter than
  /// the fixed chrome (border, padding, header and progress bar) is clamped
  /// up to the chrome's height, so the card never overflows; only the body
  /// below the bar is starved. Null leaves the card at its intrinsic height.
  final double? maxHeight;

  @override
  State<DsSetupGuide> createState() => _DsSetupGuideState();
}

class _DsSetupGuideState extends State<DsSetupGuide> {
  late bool _collapsed = widget.initiallyCollapsed;

  int get _doneCount => widget.tasks.where((task) => task.done).length;

  /// The first task the user can act on right now, surfaced by the collapsed
  /// card's "Next" line. Skips done, pending and locked tasks, and any task
  /// with no `onTap`, so "Next" always names something the user can actually
  /// follow rather than a dead link or a task hidden behind one; null once
  /// nothing is actionable.
  DsSetupTask? get _nextTask {
    for (final task in widget.tasks) {
      if (!task.done && !task.pending && !task.locked && task.onTap != null) {
        return task;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final total = widget.tasks.length;
    final progress = total == 0 ? 0.0 : _doneCount / total;

    // The header bar is itself the disclosure control: tapping anywhere on it
    // toggles the task list. Its accessible name comes from the title Text
    // inside; an outer label here would restate it.
    final header = Semantics(
      button: true,
      expanded: !_collapsed,
      child: InkWell(
        onTap: () => setState(() => _collapsed = !_collapsed),
        borderRadius: BorderRadius.circular(tokens.formBorderRadius),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tokens.labelMd
                      .toTextStyle(color: tokens.colorText)
                      .copyWith(fontWeight: tokens.strongLabelFontWeight),
                ),
              ),
              SizedBox(width: tokens.spacingUnit),
              Text(
                '$_doneCount of $total',
                style:
                    tokens.labelSm.toTextStyle(color: tokens.colorSecondaryText),
              ),
              SizedBox(width: tokens.spacingUnit),
              ExcludeSemantics(
                child: AnimatedRotation(
                  turns: _collapsed ? 0 : 0.5,
                  duration: DsMotion.durationOf(context, DsMotion.fast),
                  curve: DsMotion.curveOf(context, DsMotion.standard),
                  // Docked at the bottom the panel opens upward, so the chevron
                  // points up while collapsed ("expand up", like a bottom-sheet
                  // grabber); floating, it points down to open downward.
                  child: Icon(
                    widget.fullWidth ? DsIcons.expandLess : DsIcons.expandMore,
                    size: tokens.iconSizeSm,
                    color: tokens.colorSecondaryText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    final taskList = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final task in widget.tasks)
          if (task.animateCrossOff)
            _CrossOffTaskRow(key: ValueKey(task.label), task: task)
          else
            _TaskRow(key: ValueKey(task.label), task: task),
      ],
    );

    // Collapsed, the card summarises what to tackle next; expanded, it shows
    // the full list.
    final body = _collapsed
        ? _NextLine(next: _nextTask, summary: widget.collapsedSummary)
        : taskList;

    return Container(
      width: widget.fullWidth ? double.infinity : _floatingWidth,
      // A budget below the fixed chrome clamps up to it, so a starved card
      // shows the header and bar intact instead of overflowing.
      constraints: widget.maxHeight == null
          ? null
          : BoxConstraints(
              maxHeight: math.max(widget.maxHeight!, _chromeMinHeight(tokens)),
            ),
      padding: EdgeInsets.all(tokens.spacingUnit * 2),
      decoration: BoxDecoration(
        color: tokens.formBackgroundColor,
        borderRadius: BorderRadius.circular(tokens.formBorderRadius),
        border: Border.all(color: tokens.colorBorder),
        boxShadow: tokens.shadowMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          header,
          SizedBox(height: tokens.spacingUnit),
          // Decorative: the header's count already announces the progress.
          DsProgressBar(
            value: progress,
            minHeight: _barHeight,
            animate: true,
            excludeSemantics: true,
          ),
          SizedBox(height: tokens.spacingUnit * 1.5),
          // Under a maxHeight budget the body takes whatever space the chrome
          // leaves, down to nothing, and scrolls inside it.
          if (widget.maxHeight != null)
            Flexible(child: SingleChildScrollView(child: body))
          else
            body,
        ],
      ),
    );
  }
}

/// The collapsed card's one-line pointer at the first actionable task, with
/// the task name as a link that routes straight to it. Falls back to the
/// caller's summary line, or to nothing, once no task is actionable.
class _NextLine extends StatelessWidget {
  const _NextLine({required this.next, required this.summary});

  final DsSetupTask? next;
  final String? summary;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final muted = tokens.bodySm.toTextStyle(color: tokens.colorSecondaryText);
    final task = next;
    if (task == null) {
      if (summary == null) return const SizedBox.shrink();
      return Padding(
        padding: EdgeInsets.symmetric(vertical: tokens.spacingUnit / 2),
        child: Text(
          summary!,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: muted,
        ),
      );
    }
    return Row(
      children: [
        Text('Next:', style: muted),
        SizedBox(width: tokens.spacingUnit / 2),
        // Padded so the collapsed bar's only action is a full 48dp touch
        // target, matching the expanded task rows and the header bar.
        Flexible(
          child: DsLink(label: task.label, onPressed: task.onTap, padded: true),
        ),
      ],
    );
  }
}

/// A task that crosses itself off: while not done it renders as a normal row,
/// and when [DsSetupTask.done] flips true on screen it plays a strike-through
/// then collapses away, once. Mounting already done renders nothing, and
/// reduced motion collapses instantly, so the animation never replays.
/// Flipping done back off mid-animation restores the ordinary row and
/// rewinds, so a later completion plays the cross-off again from the start.
class _CrossOffTaskRow extends StatefulWidget {
  const _CrossOffTaskRow({super.key, required this.task});

  final DsSetupTask task;

  @override
  State<_CrossOffTaskRow> createState() => _CrossOffTaskRowState();
}

class _CrossOffTaskRowState extends State<_CrossOffTaskRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _crossOff;
  late final Animation<double> _strike;
  late final Animation<double> _collapse;

  @override
  void initState() {
    super.initState();
    _crossOff = AnimationController(
      vsync: this,
      // The strike runs in the first phase, the collapse in the last, with a
      // beat between them so the crossed-off label registers before it clears.
      duration: DsMotion.expressive * 3,
    );
    _strike = CurvedAnimation(
      parent: _crossOff,
      curve: const Interval(0.0, 0.35, curve: DsMotion.smooth),
    );
    _collapse = CurvedAnimation(
      parent: _crossOff,
      curve: const Interval(0.65, 1.0, curve: DsMotion.smooth),
    );
    // Mounted already done: render collapsed, no replay.
    if (widget.task.done) _crossOff.value = 1;
  }

  @override
  void didUpdateWidget(_CrossOffTaskRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only react to completion happening on screen; the cross-off plays once
    // per completion.
    if (widget.task.done && !oldWidget.task.done) {
      if (DsMotion.reduced(context)) {
        _crossOff.value = 1;
      } else if (_crossOff.status == AnimationStatus.dismissed) {
        _crossOff.forward();
      }
    } else if (!widget.task.done && oldWidget.task.done) {
      // The completion was withdrawn mid-flight. Stop the controller and
      // rewind it, so nothing keeps ticking behind the restored row and a
      // later completion still plays the cross-off from the start.
      _crossOff.stop();
      _crossOff.value = 0;
    }
  }

  @override
  void dispose() {
    _crossOff.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.task.done) return _TaskRow(task: widget.task);
    return AnimatedBuilder(
      animation: _crossOff,
      builder: (context, _) {
        final collapse = _collapse.value;
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: 1 - collapse,
            child: Opacity(
              opacity: 1 - collapse,
              child: _TaskRow(task: widget.task, strike: _strike.value),
            ),
          ),
        );
      },
    );
  }
}

/// One checklist row: status marker, label and any pending pill or lock.
class _TaskRow extends StatelessWidget {
  const _TaskRow({super.key, required this.task, this.strike = 0});

  final DsSetupTask task;

  /// 0 to 1 progress of the strike-through line while the task is being
  /// crossed off.
  final double strike;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final color = task.locked
        ? tokens.formPlaceholderTextColor
        : (task.done ? tokens.colorSecondaryText : tokens.colorText);
    final labelStyle = tokens.bodySm.toTextStyle(color: color);

    final row = Padding(
      padding: EdgeInsets.symmetric(vertical: tokens.spacingUnit / 2),
      child: Row(
        children: [
          _Marker(task: task),
          SizedBox(width: tokens.spacingUnit * 1.5),
          if (strike > 0)
            Flexible(
              child: _StrikeText(
                text: task.label,
                style: labelStyle,
                progress: strike,
                lineColor: tokens.colorSecondaryText,
              ),
            )
          else
            Expanded(
              child: Text(
                task.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: labelStyle,
              ),
            ),
          if (task.pending) ...[
            SizedBox(width: tokens.spacingUnit),
            const DsBadge(label: 'Pending', variant: DsBadgeVariant.warning),
          ],
          if (task.locked)
            Icon(DsIcons.lock, size: tokens.iconSizeXs, color: color),
        ],
      ),
    );

    // A resolved task is no longer a target, whatever callback it still
    // carries; only an open to-do routes anywhere.
    final onTap =
        (task.done || task.pending || task.locked) ? null : task.onTap;

    Widget result;
    if (onTap != null) {
      // Tappable to-dos grow to the 48dp touch minimum. Static rows keep the
      // compact density; they are not targets.
      result = Semantics(
        button: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(tokens.formBorderRadius),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            alignment: Alignment.centerLeft,
            child: row,
          ),
        ),
      );
    } else if (task.locked && task.lockedMessage != null) {
      // Locked rows explain the gate on hover and on tap, so touch users
      // learn why the task is gated too. DsTooltip owns the presentation;
      // only the tap trigger is layered on through the tooltip theme.
      result = TooltipTheme(
        data: TooltipTheme.of(context)
            .copyWith(triggerMode: TooltipTriggerMode.tap),
        child: DsTooltip(
          message: task.lockedMessage!,
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            alignment: Alignment.centerLeft,
            child: row,
          ),
        ),
      );
    } else {
      result = row;
    }

    // State the row's status for assistive technology: a done task reads as
    // checked and a locked one as a disabled row with a hint, so a screen
    // reader can tell either apart from an open to-do.
    if (task.done) {
      return Semantics(checked: true, child: result);
    }
    if (task.locked) {
      return Semantics(enabled: false, hint: 'Locked', child: result);
    }
    return result;
  }
}

/// A label with a strike-through line drawn left to right as [progress] runs
/// 0 to 1.
class _StrikeText extends StatelessWidget {
  const _StrikeText({
    required this.text,
    required this.style,
    required this.progress,
    required this.lineColor,
  });

  final String text;
  final TextStyle style;
  final double progress;
  final Color lineColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Text(text, maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
        Positioned.fill(
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              alignment: Alignment.centerLeft,
              child: Container(
                height: 1.5,
                decoration: BoxDecoration(
                  color: lineColor,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The leading status marker: a filled check when done, a warning ring and
/// dot while pending, otherwise an outlined ring (fainter when locked).
class _Marker extends StatelessWidget {
  const _Marker({required this.task});

  final DsSetupTask task;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    if (task.done) {
      return Container(
        width: _markerSize,
        height: _markerSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: tokens.buttonPrimaryColorBackground,
          shape: BoxShape.circle,
        ),
        child: Icon(
          DsIcons.check,
          size: tokens.iconSizeXxs,
          color: tokens.buttonPrimaryColorText,
        ),
      );
    }
    if (task.pending) {
      return Container(
        width: _markerSize,
        height: _markerSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: tokens.badgeWarningColorText, width: 1.5),
        ),
        child: Container(
          width: _markerSize / 3,
          height: _markerSize / 3,
          decoration: BoxDecoration(
            color: tokens.badgeWarningColorText,
            shape: BoxShape.circle,
          ),
        ),
      );
    }
    return Container(
      width: _markerSize,
      height: _markerSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color:
              task.locked ? tokens.colorBorder : tokens.colorSecondaryText,
          width: 1.5,
        ),
      ),
    );
  }
}
