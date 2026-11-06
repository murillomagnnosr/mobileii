import 'package:flutter/material.dart';

/// Raw color palette of the Carteira design system.
///
/// Two palettes, one per brightness, with the same field names so the theme
/// can be built from either one. Widgets never read these directly; they go
/// through [ThemeData], `AppSemanticColors` or `AppEffects`.
class AppColorPalette {
  const AppColorPalette({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.onSurface,
    required this.onSurfaceMuted,
    required this.outline,
    required this.outlineVariant,
    required this.income,
    required this.expense,
    required this.transfer,
    required this.warning,
    required this.error,
    required this.onError,
    required this.accent,
    required this.onAccent,
    required this.spark,
    required this.onSpark,
    required this.incomeContainer,
    required this.expenseContainer,
    required this.transferContainer,
    required this.onKind,
    required this.gradientStart,
    required this.gradientEnd,
    required this.onGradient,
    required this.heroStart,
    required this.heroEnd,
    required this.onHero,
    required this.onHeroMuted,
    required this.glowA,
    required this.glowB,
    required this.glass,
    required this.glassBorder,
  });

  /// Brand violet: focus ring, selected chip, links, CategoryBar fill.
  final Color primary;
  final Color onPrimary;
  final Color primaryContainer;
  final Color onPrimaryContainer;

  /// Page ground (lavender ice / space navy).
  final Color background;

  /// Opaque surfaces: dialog, bottom sheet, unselected chip, base of glass.
  final Color surface;

  /// Tracks, disabled CTA fill, dark field fill, dark chrome buttons.
  final Color surfaceVariant;
  final Color onSurface;
  final Color onSurfaceMuted;

  /// Interactive 3:1 boundary: inputs, outlined buttons, chips, segments.
  final Color outline;

  /// Decorative hairlines only; never the only boundary of a control.
  final Color outlineVariant;
  final Color income;
  final Color expense;
  final Color transfer;
  final Color warning;
  final Color error;
  final Color onError;

  /// Second neon hue (aqua): SectionHeader dot, hero rim end.
  final Color accent;
  final Color onAccent;

  /// Lime pop. Fill only, rationed (at most two spots per screen).
  final Color spark;
  final Color onSpark;

  /// Solid kind tints: KindOrb, hero leg circle, kind pills.
  final Color incomeContainer;
  final Color expenseContainer;
  final Color transferContainer;

  /// Label and icon on a solid kind fill (selected kind segment).
  final Color onKind;

  /// CTA / FAB / logomark gradient. [gradientStart] equals [primary].
  final Color gradientStart;
  final Color gradientEnd;
  final Color onGradient;

  /// Nebula fill of the balance card.
  final Color heroStart;
  final Color heroEnd;
  final Color onHero;
  final Color onHeroMuted;

  /// Aurora hues of the backdrop.
  final Color glowA;
  final Color glowB;

  /// Translucent fill of AppPanel, capsule tiles and Card (with alpha).
  final Color glass;

  /// 1px hairline on glass (with alpha).
  final Color glassBorder;

  /// Ordered (name, color) pairs of every field.
  List<(String, Color)> get entries => [
    ('primary', primary),
    ('onPrimary', onPrimary),
    ('primaryContainer', primaryContainer),
    ('onPrimaryContainer', onPrimaryContainer),
    ('background', background),
    ('surface', surface),
    ('surfaceVariant', surfaceVariant),
    ('onSurface', onSurface),
    ('onSurfaceMuted', onSurfaceMuted),
    ('outline', outline),
    ('outlineVariant', outlineVariant),
    ('income', income),
    ('expense', expense),
    ('transfer', transfer),
    ('warning', warning),
    ('error', error),
    ('onError', onError),
    ('accent', accent),
    ('onAccent', onAccent),
    ('spark', spark),
    ('onSpark', onSpark),
    ('incomeContainer', incomeContainer),
    ('expenseContainer', expenseContainer),
    ('transferContainer', transferContainer),
    ('onKind', onKind),
    ('gradientStart', gradientStart),
    ('gradientEnd', gradientEnd),
    ('onGradient', onGradient),
    ('heroStart', heroStart),
    ('heroEnd', heroEnd),
    ('onHero', onHero),
    ('onHeroMuted', onHeroMuted),
    ('glowA', glowA),
    ('glowB', glowB),
    ('glass', glass),
    ('glassBorder', glassBorder),
  ];
}

/// The two official palettes ("Neon noturno+").
abstract final class AppColors {
  /// Light palette: lavender ice ground, electric violet and ocean blue.
  static const AppColorPalette light = AppColorPalette(
    primary: Color(0xFF5A2EE5),
    onPrimary: Color(0xFFFFFFFF),
    primaryContainer: Color(0xFFE7DFFF),
    onPrimaryContainer: Color(0xFF23106B),
    background: Color(0xFFF5F4FF),
    surface: Color(0xFFFFFFFF),
    surfaceVariant: Color(0xFFEEECFA),
    onSurface: Color(0xFF15132E),
    onSurfaceMuted: Color(0xFF575380),
    outline: Color(0xFF6F6AA0),
    outlineVariant: Color(0xFFDFDBF5),
    income: Color(0xFF036A46),
    expense: Color(0xFFB51C4B),
    transfer: Color(0xFF4A548C),
    warning: Color(0xFF8A4B00),
    error: Color(0xFFB51C4B),
    onError: Color(0xFFFFFFFF),
    accent: Color(0xFF00657F),
    onAccent: Color(0xFFFFFFFF),
    spark: Color(0xFFC6F432),
    onSpark: Color(0xFF15132E),
    incomeContainer: Color(0xFFDCF5E8),
    expenseContainer: Color(0xFFFFE3EB),
    transferContainer: Color(0xFFE5E8F8),
    onKind: Color(0xFFFFFFFF),
    gradientStart: Color(0xFF5A2EE5),
    gradientEnd: Color(0xFF0C68C9),
    onGradient: Color(0xFFFFFFFF),
    heroStart: Color(0xFF5426E0),
    heroEnd: Color(0xFF0A55A6),
    onHero: Color(0xFFFFFFFF),
    onHeroMuted: Color(0xFFF4F2FF),
    glowA: Color(0xFF7C4DFF),
    glowB: Color(0xFF00C2EE),
    glass: Color(0xC7FFFFFF),
    glassBorder: Color(0x1F5A2EE5),
  );

  /// Dark palette: space-navy ground with neon violet and cyan.
  static const AppColorPalette dark = AppColorPalette(
    primary: Color(0xFFB39CFF),
    onPrimary: Color(0xFF12082E),
    primaryContainer: Color(0xFF2C1F70),
    onPrimaryContainer: Color(0xFFE6DEFF),
    background: Color(0xFF070A1A),
    surface: Color(0xFF11152D),
    surfaceVariant: Color(0xFF1B2042),
    onSurface: Color(0xFFF1F2FF),
    onSurfaceMuted: Color(0xFFA9AED8),
    outline: Color(0xFF7A82C0),
    outlineVariant: Color(0xFF262C55),
    income: Color(0xFF3EEFA0),
    expense: Color(0xFFFF7D9C),
    transfer: Color(0xFF9DB2FF),
    warning: Color(0xFFFFC65C),
    error: Color(0xFFFF7D9C),
    onError: Color(0xFF2B0711),
    accent: Color(0xFF3EE6FF),
    onAccent: Color(0xFF03161C),
    spark: Color(0xFFD2FF4D),
    onSpark: Color(0xFF0B0620),
    incomeContainer: Color(0xFF0E3A2B),
    expenseContainer: Color(0xFF47162A),
    transferContainer: Color(0xFF1E2752),
    onKind: Color(0xFF0B0620),
    gradientStart: Color(0xFFB39CFF),
    gradientEnd: Color(0xFF3EE6FF),
    onGradient: Color(0xFF0B0620),
    heroStart: Color(0xFF4B1FD6),
    heroEnd: Color(0xFF0A5592),
    onHero: Color(0xFFFFFFFF),
    onHeroMuted: Color(0xFFF3F0FF),
    glowA: Color(0xFF7C4DFF),
    glowB: Color(0xFF00D4FF),
    glass: Color(0xB811152D),
    glassBorder: Color(0x1AFFFFFF),
  );
}
