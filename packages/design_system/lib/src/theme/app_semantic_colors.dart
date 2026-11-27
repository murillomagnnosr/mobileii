import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';

/// Colors that carry meaning in a finance app and have no slot in
/// [ColorScheme]: income, expense, transfer and warning, plus the solid kind
/// containers and the label color on a solid kind fill.
///
/// Registered as a [ThemeExtension] so widgets read them with
/// `context.semanticColors`.
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  /// Creates the colors field by field. Themes use
  /// [AppSemanticColors.fromPalette] instead.
  const AppSemanticColors({
    required this.income,
    required this.expense,
    required this.transfer,
    required this.warning,
    required this.muted,
    required this.incomeContainer,
    required this.expenseContainer,
    required this.transferContainer,
    required this.onKind,
  });

  /// Picks the semantic fields of [palette]; [muted] is its
  /// `onSurfaceMuted`.
  factory AppSemanticColors.fromPalette(AppColorPalette palette) {
    return AppSemanticColors(
      income: palette.income,
      expense: palette.expense,
      transfer: palette.transfer,
      warning: palette.warning,
      muted: palette.onSurfaceMuted,
      incomeContainer: palette.incomeContainer,
      expenseContainer: palette.expenseContainer,
      transferContainer: palette.transferContainer,
      onKind: palette.onKind,
    );
  }

  /// Income money and icons. Always paired with a "+" sign and a down
  /// arrow: kinds never differ by color alone.
  final Color income;

  /// Expense money and icons. Always paired with a "−" sign and an up
  /// arrow.
  final Color expense;

  /// Transfer icon. Transfer amounts stay neutral `onSurface`.
  final Color transfer;

  /// Caution, e.g. the "Razoável" password strength.
  final Color warning;

  /// Secondary text color.
  final Color muted;

  /// Solid income tint (KindOrb, hero leg circle, kind pill).
  final Color incomeContainer;

  /// Solid expense tint (KindOrb, error banner, destructive dialog icon).
  final Color expenseContainer;

  /// Solid transfer tint (KindOrb, kind pill).
  final Color transferContainer;

  /// Label and icon on a SOLID kind fill (selected kind segment).
  final Color onKind;

  @override
  AppSemanticColors copyWith({
    Color? income,
    Color? expense,
    Color? transfer,
    Color? warning,
    Color? muted,
    Color? incomeContainer,
    Color? expenseContainer,
    Color? transferContainer,
    Color? onKind,
  }) {
    return AppSemanticColors(
      income: income ?? this.income,
      expense: expense ?? this.expense,
      transfer: transfer ?? this.transfer,
      warning: warning ?? this.warning,
      muted: muted ?? this.muted,
      incomeContainer: incomeContainer ?? this.incomeContainer,
      expenseContainer: expenseContainer ?? this.expenseContainer,
      transferContainer: transferContainer ?? this.transferContainer,
      onKind: onKind ?? this.onKind,
    );
  }

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other == null) return this;
    return AppSemanticColors(
      income: Color.lerp(income, other.income, t)!,
      expense: Color.lerp(expense, other.expense, t)!,
      transfer: Color.lerp(transfer, other.transfer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      incomeContainer: Color.lerp(incomeContainer, other.incomeContainer, t)!,
      expenseContainer: Color.lerp(
        expenseContainer,
        other.expenseContainer,
        t,
      )!,
      transferContainer: Color.lerp(
        transferContainer,
        other.transferContainer,
        t,
      )!,
      onKind: Color.lerp(onKind, other.onKind, t)!,
    );
  }
}

/// Shortcut: `context.semanticColors.income`.
extension SemanticColorsContext on BuildContext {
  /// The [AppSemanticColors] of the nearest [Theme]. Asserts that the theme
  /// was built by `AppTheme.light()` or `AppTheme.dark()`.
  AppSemanticColors get semanticColors {
    final colors = Theme.of(this).extension<AppSemanticColors>();
    assert(
      colors != null,
      'AppSemanticColors is missing. Use AppTheme.light() or AppTheme.dark().',
    );
    return colors!;
  }
}
