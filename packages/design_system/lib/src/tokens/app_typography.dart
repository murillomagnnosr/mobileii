import 'package:flutter/material.dart';

/// Type scale built on two bundled OFL variable fonts.
///
/// - Plus Jakarta Sans ([sansFamily]): every UI style and list money.
/// - Space Grotesk ([displayFamily]): large figures, screen titles, the Valor
///   field and avatar initials.
///
/// Both are variable fonts, so every style sets `fontWeight` AND the `wght`
/// variation with the same value; otherwise the font renders its default
/// instance. Change a weight only through [weighted].
abstract final class AppTypography {
  /// Primary family (Plus Jakarta Sans).
  static const String sansFamily = 'PlusJakartaSans';

  /// Display family (Space Grotesk).
  static const String displayFamily = 'SpaceGrotesk';

  /// Package that bundles both fonts.
  static const String fontPackage = 'carteira_design_system';

  // Display (Space Grotesk).

  /// Space Grotesk 42/700. Base of `MoneySize.display` (balance, Detalhe
  /// amount).
  static const TextStyle displayLarge = TextStyle(
    fontFamily: displayFamily,
    package: fontPackage,
    fontSize: 42,
    height: 1.05,
    letterSpacing: -1.0,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700)],
  );

  /// Space Grotesk 36/700. Spare display slot.
  static const TextStyle displayMedium = TextStyle(
    fontFamily: displayFamily,
    package: fontPackage,
    fontSize: 36,
    height: 1.08,
    letterSpacing: -0.8,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700)],
  );

  /// Space Grotesk 30/700. Spare display slot.
  static const TextStyle displaySmall = TextStyle(
    fontFamily: displayFamily,
    package: fontPackage,
    fontSize: 30,
    height: 1.10,
    letterSpacing: -0.6,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700)],
  );

  /// Space Grotesk 34/700. Spare headline slot.
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: displayFamily,
    package: fontPackage,
    fontSize: 34,
    height: 1.10,
    letterSpacing: -0.8,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700)],
  );

  /// Space Grotesk 32/700. Login "Entrar".
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: displayFamily,
    package: fontPackage,
    fontSize: 32,
    height: 1.10,
    letterSpacing: -0.8,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700)],
  );

  // UI (Plus Jakarta Sans).

  /// Plus Jakarta Sans 24/800. Spare headline slot.
  static const TextStyle headlineSmall = TextStyle(
    fontFamily: sansFamily,
    package: fontPackage,
    fontSize: 24,
    height: 1.20,
    letterSpacing: -0.4,
    fontWeight: FontWeight.w800,
    fontVariations: [FontVariation('wght', 800)],
  );

  /// 22/800: greeting, profile name, dialog title (the dialog theme uses 20).
  static const TextStyle titleLarge = TextStyle(
    fontFamily: sansFamily,
    package: fontPackage,
    fontSize: 22,
    height: 1.25,
    letterSpacing: -0.4,
    fontWeight: FontWeight.w800,
    fontVariations: [FontVariation('wght', 800)],
  );

  /// 17/700: Detalhe description.
  static const TextStyle titleMedium = TextStyle(
    fontFamily: sansFamily,
    package: fontPackage,
    fontSize: 17,
    height: 1.30,
    letterSpacing: -0.2,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700)],
  );

  /// 15/700: tile and list titles; base of DetailRow values.
  static const TextStyle titleSmall = TextStyle(
    fontFamily: sansFamily,
    package: fontPackage,
    fontSize: 15,
    height: 1.30,
    letterSpacing: -0.1,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700)],
  );

  /// 17/500: typed text, Login subtitle, StateView message.
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: sansFamily,
    package: fontPackage,
    fontSize: 17,
    height: 1.50,
    letterSpacing: 0,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation('wght', 500)],
  );

  /// 15/500: body text, field labels and hints, DetailRow label.
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: sansFamily,
    package: fontPackage,
    fontSize: 15,
    height: 1.45,
    letterSpacing: 0,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation('wght', 500)],
  );

  /// 13/500: subtitles, captions, helper and error text.
  static const TextStyle bodySmall = TextStyle(
    fontFamily: sansFamily,
    package: fontPackage,
    fontSize: 13,
    height: 1.40,
    letterSpacing: 0.1,
    fontWeight: FontWeight.w500,
    fontVariations: [FontVariation('wght', 500)],
  );

  /// 15/700: buttons, segments and chips (chips use 14).
  static const TextStyle labelLarge = TextStyle(
    fontFamily: sansFamily,
    package: fontPackage,
    fontSize: 15,
    height: 1.20,
    letterSpacing: 0.2,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700)],
  );

  /// 13/700: pills (month, kind, caption, "Ver todos").
  static const TextStyle labelMedium = TextStyle(
    fontFamily: sansFamily,
    package: fontPackage,
    fontSize: 13,
    height: 1.20,
    letterSpacing: 0.2,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700)],
  );

  /// UPPERCASE section headers only.
  static const TextStyle labelSmall = TextStyle(
    fontFamily: sansFamily,
    package: fontPackage,
    fontSize: 11,
    height: 1.20,
    letterSpacing: 1.4,
    fontWeight: FontWeight.w800,
    fontVariations: [FontVariation('wght', 800)],
  );

  /// Screen titles (`AppBarTheme.titleTextStyle`).
  static const TextStyle appBarTitle = TextStyle(
    fontFamily: displayFamily,
    package: fontPackage,
    fontSize: 22,
    height: 1.20,
    letterSpacing: -0.4,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700)],
  );

  /// Money figures use tabular digits so columns line up.
  static const List<FontFeature> tabularFigures = [
    FontFeature.tabularFigures(),
  ];

  /// `MoneySize.small`.
  static const TextStyle moneySmall = TextStyle(
    fontFamily: sansFamily,
    package: fontPackage,
    fontSize: 13,
    height: 1.40,
    letterSpacing: 0,
    fontWeight: FontWeight.w600,
    fontVariations: [FontVariation('wght', 600)],
    fontFeatures: tabularFigures,
  );

  /// `MoneySize.medium`: tile amounts and hero legs.
  static const TextStyle moneyMedium = TextStyle(
    fontFamily: sansFamily,
    package: fontPackage,
    fontSize: 17,
    height: 1.30,
    letterSpacing: -0.2,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700)],
    fontFeatures: tabularFigures,
  );

  /// `MoneySize.large`.
  static const TextStyle moneyLarge = TextStyle(
    fontFamily: sansFamily,
    package: fontPackage,
    fontSize: 22,
    height: 1.20,
    letterSpacing: -0.4,
    fontWeight: FontWeight.w800,
    fontVariations: [FontVariation('wght', 800)],
    fontFeatures: tabularFigures,
  );

  /// Text and hint of the Valor field.
  static const TextStyle moneyInput = TextStyle(
    fontFamily: displayFamily,
    package: fontPackage,
    fontSize: 28,
    height: 1.15,
    letterSpacing: -0.6,
    fontWeight: FontWeight.w700,
    fontVariations: [FontVariation('wght', 700)],
    fontFeatures: tabularFigures,
  );

  /// Sets fontWeight and the variable 'wght' axis together.
  ///
  /// [w] is a CSS-like weight (100..900, multiple of 100). A bare
  /// `copyWith(fontWeight:)` leaves a stale variation and renders the old
  /// weight.
  static TextStyle weighted(TextStyle s, int w) => s.copyWith(
    fontWeight: FontWeight.values[(w ~/ 100) - 1],
    fontVariations: [FontVariation('wght', w.toDouble())],
  );

  /// All 15 Material 3 slots, so no slot renders a default instance.
  static const TextTheme textTheme = TextTheme(
    displayLarge: displayLarge,
    displayMedium: displayMedium,
    displaySmall: displaySmall,
    headlineLarge: headlineLarge,
    headlineMedium: headlineMedium,
    headlineSmall: headlineSmall,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    titleSmall: titleSmall,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelMedium: labelMedium,
    labelSmall: labelSmall,
  );
}
