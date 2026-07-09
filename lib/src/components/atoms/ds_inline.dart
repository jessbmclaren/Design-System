import 'package:flutter/widgets.dart';

import '../../theme/ds_tokens_extension.dart';

/// Inline styled text for a single run of copy.
///
/// [DsInline] renders a [Text] whose style combines a small set of typographic
/// treatments — bold, italic, monospace `code`, and strikethrough — while
/// inheriting size and colour from the surrounding [DefaultTextStyle] unless an
/// explicit [color] is provided. It is designed to be dropped inline anywhere
/// text appears, and it never sets its own font size so it composes cleanly with
/// any type ramp.
///
/// For embedding the same treatment inside a [RichText] / [Text.rich], use the
/// static [DsInline.span] helper, which returns an [InlineSpan] with identical
/// options.
///
/// ```dart
/// // As a widget:
/// const DsInline(text: 'important', bold: true)
///
/// // Inside rich text:
/// Text.rich(TextSpan(children: [
///   const TextSpan(text: 'The '),
///   DsInline.span(context: context, text: 'config', code: true),
///   const TextSpan(text: ' value.'),
/// ]))
/// ```
///
/// The widget starts no timers or animations and renders no network content, so
/// it is safe for screenshots and demos. It is inherently responsive: it lays
/// out within whatever constraints its parent provides and wraps/ellipsizes
/// according to [softWrap] and [overflow].
class DsInline extends StatelessWidget {
  /// Creates an inline styled text run.
  const DsInline({
    super.key,
    required this.text,
    this.bold = false,
    this.italic = false,
    this.code = false,
    this.strikethrough = false,
    this.color,
    this.textAlign,
    this.softWrap,
    this.overflow,
    this.maxLines,
    this.semanticsLabel,
  });

  /// The string to render.
  final String text;

  /// Whether to render with a semi-bold weight (`FontWeight.w600`).
  final bool bold;

  /// Whether to render in italic.
  final bool italic;

  /// Whether to render as inline code: a monospace family and, unless [color]
  /// is set, the theme's secondary text colour.
  final bool code;

  /// Whether to strike the text through.
  final bool strikethrough;

  /// An explicit colour. When null the colour is inherited from the ambient
  /// [DefaultTextStyle] (or, for [code], the theme's secondary text colour).
  final Color? color;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// Whether the text should break at soft line breaks. Defaults to the
  /// inherited behaviour.
  final bool? softWrap;

  /// How visual overflow should be handled.
  final TextOverflow? overflow;

  /// The maximum number of lines before truncating.
  final int? maxLines;

  /// An alternative semantics label to announce instead of [text].
  final String? semanticsLabel;

  /// Builds the [TextStyle] that expresses the requested treatments.
  ///
  /// [inlineCodeColor] is used as the fallback colour when [code] is true and no
  /// explicit [color] is supplied; callers resolve it from the theme.
  static TextStyle _buildStyle({
    required bool bold,
    required bool italic,
    required bool code,
    required bool strikethrough,
    required Color? color,
    required Color inlineCodeColor,
  }) {
    return TextStyle(
      fontWeight: bold ? FontWeight.w600 : null,
      fontStyle: italic ? FontStyle.italic : null,
      fontFamily: code ? 'monospace' : null,
      fontFamilyFallback: code
          ? const <String>['Menlo', 'Consolas', 'Courier New', 'monospace']
          : null,
      decoration: strikethrough ? TextDecoration.lineThrough : null,
      color: color ?? (code ? inlineCodeColor : null),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DsTokens tokens = DsTokens.of(context);
    final TextStyle style = _buildStyle(
      bold: bold,
      italic: italic,
      code: code,
      strikethrough: strikethrough,
      color: color,
      inlineCodeColor: tokens.colorSecondaryText,
    );

    return Text(
      text,
      style: style,
      textAlign: textAlign,
      softWrap: softWrap,
      overflow: overflow,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
    );
  }

  /// Returns an [InlineSpan] carrying the same treatments as the widget, for
  /// embedding inside a [RichText] / [Text.rich].
  ///
  /// A [context] is required so the `code` colour can be resolved from the
  /// active theme. Pass [recognizer] and [semanticsLabel] through to the
  /// resulting [TextSpan] when needed.
  static InlineSpan span({
    required BuildContext context,
    required String text,
    bool bold = false,
    bool italic = false,
    bool code = false,
    bool strikethrough = false,
    Color? color,
    String? semanticsLabel,
    List<InlineSpan>? children,
  }) {
    final DsTokens tokens = DsTokens.of(context);
    return TextSpan(
      text: text,
      style: _buildStyle(
        bold: bold,
        italic: italic,
        code: code,
        strikethrough: strikethrough,
        color: color,
        inlineCodeColor: tokens.colorSecondaryText,
      ),
      semanticsLabel: semanticsLabel,
      children: children,
    );
  }
}
