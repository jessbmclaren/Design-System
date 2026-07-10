import 'package:flutter/material.dart';
import '../../tokens/ds_icons.dart';

import '../../theme/ds_tokens_extension.dart';

/// A contextual side panel that renders beside primary content.
///
/// [DsContextView] is an embedded, non-modal drawer: a full-height surface
/// pinned to the edge of a layout that supplements the main content without
/// taking it over. Use it for supporting detail (an inspector, a filter
/// column, a preview or a help panel) that should stay visible while the
/// user works alongside it.
///
/// The panel has a titled header (with optional [actions] and a close button
/// when [onClose] is provided), a scrollable body and an optional [footer]
/// above a divider. It reads every colour and text style from
/// [DsTokens.of], so it re-themes with the surrounding application.
///
/// Responsiveness: on wide layouts the panel is [width] logical pixels wide so
/// it fits beside content. On a narrow (phone) layout it expands to fill the
/// available width, becoming a full-bleed column rather than a cramped sliver.
/// It never overflows down to a 320dp-wide viewport.
///
/// The widget starts no timers or animations, so it renders a stable frame
/// that is safe to capture in screenshots.
///
/// ```dart
/// Row(
///   children: [
///     const Expanded(child: MainContent()),
///     DsContextView(
///       title: 'Details',
///       onClose: () => setState(() => _showPanel = false),
///       actions: const [DsButton(label: 'Edit', variant: DsButtonVariant.secondary)],
///       footer: DsButton(label: 'Save', onPressed: _save),
///       child: const DetailBody(),
///     ),
///   ],
/// )
/// ```
class DsContextView extends StatelessWidget {
  /// Creates a contextual side panel.
  const DsContextView({
    super.key,
    required this.title,
    required this.child,
    this.footer,
    this.actions = const [],
    this.onClose,
    this.width = 360,
  });

  /// The heading shown at the top of the panel, styled as `headingSm`.
  final String title;

  /// The main content, rendered in a scrollable body with 20dp padding.
  final Widget child;

  /// Optional footer content, such as a primary action, shown above a divider
  /// at the bottom of the panel.
  final Widget? footer;

  /// Header actions, laid out in a [Wrap] between the [title] and the close
  /// button. Typically compact controls such as secondary buttons or icon
  /// buttons.
  final List<Widget> actions;

  /// Called when the header close button is tapped. When null, no close button
  /// is shown.
  final VoidCallback? onClose;

  /// The panel width on wide layouts, in logical pixels. On narrow layouts the
  /// panel expands to fill the available width instead.
  final double width;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    final borderColor = tokens.colorBorder;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Resolve a finite width even under unbounded horizontal constraints.
        final available = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        // On a narrow layout the panel fills the width; on a wide layout it
        // sits at its natural [width] beside the primary content.
        final effectiveWidth = available < width * 1.4 ? available : width;

        return SizedBox(
          width: effectiveWidth,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: tokens.formBackgroundColor,
              border: Border(
                left: BorderSide(color: borderColor),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Header(
                  title: title,
                  actions: actions,
                  onClose: onClose,
                  tokens: tokens,
                ),
                Divider(height: 1, thickness: 1, color: borderColor),
                // Scrollable body: takes the remaining height.
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: child,
                  ),
                ),
                if (footer != null) ...[
                  Divider(height: 1, thickness: 1, color: borderColor),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: footer,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The panel header: title, wrapped [actions] and an optional close button.
class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.actions,
    required this.onClose,
    required this.tokens,
  });

  final String title;
  final List<Widget> actions;
  final VoidCallback? onClose;
  final DsTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 8, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: tokens.headingSm.toTextStyle(color: tokens.colorText),
              ),
            ),
          ),
          if (actions.isNotEmpty) ...[
            const SizedBox(width: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: actions,
            ),
          ],
          if (onClose != null) ...[
            const SizedBox(width: 4),
            IconButton(
              onPressed: onClose,
              icon: const Icon(DsIcons.close),
              iconSize: 20,
              color: tokens.colorSecondaryText,
              tooltip: 'Close',
              // Keep a >=48dp touch target for accessibility.
              constraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
