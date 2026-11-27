import 'package:flutter/material.dart';

import '../theme/app_semantic_colors.dart';
import '../tokens/app_typography.dart';

/// Which semantic color a money figure takes.
enum MoneyTone {
  /// `onSurface`: balances and transfers. Never signed.
  neutral,

  /// [AppSemanticColors.income]; "+" when [MoneyText.signed].
  income,

  /// [AppSemanticColors.expense]; "−" when [MoneyText.signed].
  expense,
}

/// Size of a [MoneyText].
enum MoneySize {
  /// [AppTypography.moneySmall] (13).
  small,

  /// [AppTypography.moneyMedium] (17): tile amounts and hero legs.
  medium,

  /// [AppTypography.moneyLarge] (22).
  large,

  /// [AppTypography.displayLarge] (Space Grotesk 42) with a half-size
  /// "R$". Always scales down to fit. Balance and Detalhe amount.
  display,
}

/// Money figure. The string arrives formatted by the caller
/// ("R\$ 1.234,56"); the widget only picks color and size.
///
/// Always a solid color with tabular digits: never a gradient, shader,
/// shadow, emoji, partial opacity or count-up. Exactly one [Text] is built,
/// so tests can read its color and plain text.
class MoneyText extends StatelessWidget {
  /// Creates a figure for the already formatted [value].
  const MoneyText(
    this.value, {
    super.key,
    this.tone = MoneyTone.neutral,
    this.size = MoneySize.medium,
    this.signed = false,
    this.scaleDown = false,
  });

  /// Formatted amount, e.g. "R\$ 89,90". Pass it unsigned with [signed].
  final String value;

  /// Color of the figure. Defaults to neutral.
  final MoneyTone tone;

  /// Style of the figure. Defaults to medium.
  final MoneySize size;

  /// Prefix "+" for income and "−" for expense.
  final bool signed;

  /// Shrinks the figure to fit instead of ellipsizing it. Always on for
  /// [MoneySize.display]. Needs a bounded width: never use it in a ListTile
  /// trailing slot.
  final bool scaleDown;

  // Sign, currency (with its original space, NBSP included) and the rest.
  static final RegExp _parts = RegExp(r'^([+−-]?)(R\$\s?)(.*)$');

  // Half-size "R$" of display figures (half of displayLarge, weight 600 on
  // both the weight and the wght axis). Family and color are inherited.
  static final TextStyle _currency = AppTypography.weighted(
    TextStyle(
      fontSize: AppTypography.displayLarge.fontSize! / 2,
      letterSpacing: -0.2,
    ),
    600,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = context.semanticColors;
    final color = switch (tone) {
      MoneyTone.neutral => theme.colorScheme.onSurface,
      MoneyTone.income => semantic.income,
      MoneyTone.expense => semantic.expense,
    };
    final base = switch (size) {
      MoneySize.small => AppTypography.moneySmall,
      MoneySize.medium => AppTypography.moneyMedium,
      MoneySize.large => AppTypography.moneyLarge,
      MoneySize.display => AppTypography.displayLarge,
    };
    final prefix = switch ((signed, tone)) {
      (true, MoneyTone.income) => '+',
      (true, MoneyTone.expense) => '−',
      _ => '',
    };
    final style = base.copyWith(
      color: color,
      fontFeatures: AppTypography.tabularFigures,
    );
    final text = '$prefix$value';
    final isDisplay = size == MoneySize.display;
    final fits = scaleDown || isDisplay;

    // Display figures split sign, currency and digits; the plain text stays
    // identical to "$prefix$value".
    final match = isDisplay ? _parts.firstMatch(text) : null;
    final Widget figure = match == null
        ? Text(
            text,
            style: style,
            maxLines: 1,
            overflow: fits ? null : TextOverflow.ellipsis,
          )
        : Text.rich(
            TextSpan(
              children: [
                TextSpan(text: match.group(1)),
                TextSpan(text: match.group(2), style: _currency),
                TextSpan(text: match.group(3)),
              ],
            ),
            style: style,
            maxLines: 1,
          );
    if (!fits) return figure;

    // FittedBox lays the text out unconstrained, so it scales down instead
    // of being cut: a money figure is never ellipsized.
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: AlignmentDirectional.centerStart,
      child: figure,
    );
  }
}
