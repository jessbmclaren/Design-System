import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final (String name, ThemeData theme, DsTokens tokens) in <(
    String,
    ThemeData,
    DsTokens
  )>[
    ('light', DsTheme.light(), DsTokens.light()),
    ('engen light', DsTheme.light(tokens: DsSkins.engenLight()),
        DsSkins.engenLight()),
  ]) {
    group('theme wiring · $name', () {
      test('interactions are splash-free', () {
        expect(theme.splashFactory, NoSplash.splashFactory);
      });

      test('tooltips are the dark inverse panel', () {
        final decoration = theme.tooltipTheme.decoration! as BoxDecoration;
        expect(decoration.color, tokens.colorInverseSurface);
        expect(
          decoration.borderRadius,
          BorderRadius.circular(tokens.tooltipBorderRadius),
        );
        expect(theme.tooltipTheme.textStyle!.color, tokens.colorOnInverse);
        expect(
          theme.tooltipTheme.waitDuration,
          const Duration(milliseconds: 300),
        );
      });

      test('a bare field is filled with all six border states', () {
        final input = theme.inputDecorationTheme;
        expect(input.filled, isTrue);
        expect(input.fillColor, tokens.formBackgroundColor);
        expect(input.isDense, isFalse);
        expect(
          input.contentPadding,
          EdgeInsets.symmetric(
            horizontal: tokens.inputFieldPaddingX,
            vertical: tokens.textFieldPaddingY,
          ),
        );

        BorderSide side(InputBorder? border) =>
            (border! as OutlineInputBorder).borderSide;
        expect(side(input.enabledBorder).color, tokens.colorBorder);
        expect(side(input.enabledBorder).width, tokens.inputBorderWidth);
        expect(side(input.disabledBorder).color, tokens.colorBorderSubtle);
        expect(
          side(input.focusedBorder).color,
          tokens.formHighlightColorBorder,
        );
        expect(
          side(input.focusedBorder).width,
          tokens.inputFocusBorderWidth,
        );
        expect(side(input.errorBorder).color, tokens.colorDanger);
        expect(side(input.errorBorder).width, tokens.inputBorderWidth);
        expect(side(input.focusedErrorBorder).color, tokens.colorDanger);
        expect(
          side(input.focusedErrorBorder).width,
          tokens.inputFocusBorderWidth,
        );
        expect(input.errorStyle!.color, tokens.colorDanger);
        expect(
          input.hintStyle!.color,
          tokens.formPlaceholderTextColor,
        );
      });
    });
  }

  test('the Engen skin adopts the platform font', () {
    final ThemeData theme = DsTheme.light(tokens: DsSkins.engenLight());
    expect(theme.textTheme.bodyLarge!.fontFamily, isNull);
  });

  test('the contrast guard rejects an unreadable skin in debug', () {
    final DsTokens broken = DsTokens.light().copyWith(
      colorText: const Color(0xFFDDDDDD),
    );
    expect(() => DsTheme.light(tokens: broken), throwsAssertionError);
  });
}
