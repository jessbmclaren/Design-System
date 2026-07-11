// Pieces shared by the auth-card organisms, `DsSignInView` and
// `DsSignUpView`. Internal to the package: this file is deliberately not
// exported from the barrel.
import 'package:flutter/material.dart';

import '../../theme/ds_tokens_extension.dart';
import '../../tokens/ds_icon_size.dart';
import '../atoms/ds_icon.dart';

/// Layout constants and helpers shared by the auth-card organisms.
abstract final class DsAuthCardLayout {
  /// The maximum width of the sign-in card, in logical pixels.
  ///
  /// Deliberately narrower than [signUpMaxWidth]: the sign-in card is
  /// message-led (a heading, a line or two of copy and one action), so it
  /// holds a tight reading measure.
  static const double signInMaxWidth = 420;

  /// The maximum width of the sign-up card, in logical pixels.
  ///
  /// Deliberately wider than [signInMaxWidth]: the sign-up card is form-led,
  /// and the extra 20dp gives its text fields a comfortable line length.
  static const double signUpMaxWidth = 440;

  /// The extra trailing inset applied to an auth card's heading block while a
  /// corner close button is shown, so heading glyphs never paint beneath it.
  ///
  /// The button's 48dp padded tap target ([kMinInteractiveDimension]) sits one
  /// [DsTokens.spacingUnit] in from the card edge. The card body's padding of
  /// three units already covers part of that span, and a further unit keeps a
  /// visible gap between the last glyph and the button.
  static double headingCloseInset(DsTokens tokens) {
    final double unit = tokens.spacingUnit;
    return kMinInteractiveDimension + unit + unit - unit * 3;
  }
}

/// The tinted rounded square that frames an auth card's brand glyph.
///
/// Shared by `DsSignInView` and `DsSignUpView` so both cards render the same
/// brand treatment.
class DsAuthBrandMark extends StatelessWidget {
  /// Creates the tinted rounded square that frames [icon].
  const DsAuthBrandMark({
    super.key,
    required this.icon,
    required this.color,
    required this.alignment,
  });

  /// The brand glyph.
  final IconData icon;

  /// The tint painted behind the glyph.
  final Color color;

  /// Where the mark sits within the card's width.
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final tokens = DsTokens.of(context);
    return Align(
      alignment: alignment,
      child: Container(
        padding: EdgeInsets.all(tokens.spacingUnit * 1.5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(tokens.formBorderRadius),
          boxShadow: tokens.shadowMedium,
        ),
        child: DsIcon(
          icon: icon,
          size: DsIconSize.xl,
          color: tokens.buttonPrimaryColorText,
        ),
      ),
    );
  }
}
