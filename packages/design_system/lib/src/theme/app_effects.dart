import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../tokens/app_colors.dart';

/// Decorative values of the design system: gradients, glows, glass, aurora.
///
/// Every alpha lives here as a named constant. The ones documented as
/// "AA cap" must not be raised: `test/theme/contrast_test.dart` asserts the
/// worst-case composites they produce.
///
/// Registered as a [ThemeExtension] so widgets read it with
/// `context.effects`, and lerped on theme switches so the hero, the CTA and
/// the aurora cross-fade.
class AppEffects extends ThemeExtension<AppEffects> {
  const AppEffects({
    required this.heroGradient,
    required this.heroRim,
    required this.heroBlob,
    required this.heroOrbit,
    required this.heroShadow,
    required this.onHero,
    required this.onHeroMuted,
    required this.legChip,
    required this.ctaGradient,
    required this.onGradient,
    required this.ctaGlow,
    required this.fabGlow,
    required this.logoGlow,
    required this.ringGradient,
    required this.avatarGlow,
    required this.glass,
    required this.glassBorder,
    required this.glassSheen,
    required this.panelShadow,
    required this.tileShadow,
    required this.auroraA,
    required this.auroraB,
    required this.auroraC,
    required this.spotlight,
    required this.spark,
    required this.onSpark,
    required this.chromeFill,
    required this.kindGlowAlpha,
    required this.tintAlpha,
    required this.scrolledBar,
  });

  factory AppEffects.fromPalette(AppColorPalette p, Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return AppEffects(
      heroGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [p.heroStart, p.heroEnd],
      ),
      heroRim: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [
                const Color(0x73FFFFFF),
                const Color(0x14FFFFFF),
                p.accent.withValues(alpha: 0.75),
              ]
            : [
                const Color(0xCCFFFFFF),
                const Color(0x00FFFFFF),
                p.accent.withValues(alpha: 0.55),
              ],
        stops: const [0, 0.45, 1],
      ),
      heroBlob: p.glowB.withValues(alpha: isDark ? 0.14 : 0.12),
      heroOrbit: const Color(0x0FFFFFFF),
      heroShadow: [
        BoxShadow(
          color: p.heroStart.withValues(alpha: isDark ? 0.45 : 0.28),
          blurRadius: 40,
          offset: const Offset(0, 18),
          spreadRadius: -10,
        ),
        BoxShadow(
          color: p.heroEnd.withValues(alpha: isDark ? 0.30 : 0.18),
          blurRadius: 24,
          offset: const Offset(12, 8),
          spreadRadius: -12,
        ),
      ],
      onHero: p.onHero,
      onHeroMuted: p.onHeroMuted,
      legChip: p.surface.withAlpha(isDark ? 0xEB : 0xF0),
      ctaGradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [p.gradientStart, p.gradientEnd],
      ),
      onGradient: p.onGradient,
      ctaGlow: [
        BoxShadow(
          color: p.gradientStart.withValues(alpha: isDark ? 0.40 : 0.28),
          blurRadius: 24,
          offset: const Offset(0, 10),
          spreadRadius: -6,
        ),
      ],
      fabGlow: [
        BoxShadow(
          color: p.gradientStart.withValues(alpha: isDark ? 0.45 : 0.30),
          blurRadius: 28,
          offset: const Offset(0, 12),
          spreadRadius: -6,
        ),
      ],
      logoGlow: [
        BoxShadow(
          color: p.gradientStart.withValues(alpha: isDark ? 0.50 : 0.32),
          blurRadius: 40,
          offset: const Offset(0, 12),
          spreadRadius: -6,
        ),
      ],
      ringGradient: SweepGradient(
        colors: [p.gradientStart, p.gradientEnd, p.spark, p.gradientStart],
        stops: const [0, 0.45, 0.7, 1],
      ),
      avatarGlow: [
        BoxShadow(
          color: p.gradientStart.withValues(alpha: isDark ? 0.35 : 0.22),
          blurRadius: 28,
          spreadRadius: -4,
        ),
      ],
      glass: p.glass,
      glassBorder: p.glassBorder,
      glassSheen: isDark ? const Color(0x0AFFFFFF) : const Color(0x00FFFFFF),
      panelShadow: isDark
          ? const []
          : [
              BoxShadow(
                color: p.primary.withValues(alpha: 0.07),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
      tileShadow: isDark
          ? const []
          : [
              BoxShadow(
                color: p.primary.withValues(alpha: 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
      auroraA: p.glowA.withValues(alpha: isDark ? 0.18 : 0.08),
      auroraB: p.glowB.withValues(alpha: isDark ? 0.10 : 0.06),
      auroraC: p.glowA.withValues(alpha: isDark ? 0.08 : 0.04),
      spotlight: p.glowB.withValues(alpha: isDark ? 0.10 : 0.08),
      spark: p.spark,
      onSpark: p.onSpark,
      chromeFill: isDark ? p.surfaceVariant : p.surface,
      kindGlowAlpha: 0.12,
      tintAlpha: isDark ? 0.16 : 0.12,
      scrolledBar: p.background.withAlpha(0xEB),
    );
  }

  /// Nebula fill of the BalanceCard (heroStart to heroEnd, diagonal).
  final LinearGradient heroGradient;

  /// Iridescent 1.5px rim around the BalanceCard.
  final LinearGradient heroRim;

  /// Cyan blob on the nebula. AA cap: 0.12 light / 0.14 dark.
  final Color heroBlob;

  /// Orbit rings on the nebula. AA cap: 0.06.
  final Color heroOrbit;

  /// Two coloured shadows under the BalanceCard.
  final List<BoxShadow> heroShadow;

  /// Balance figure and strong text on the nebula.
  final Color onHero;

  /// "Saldo do mês" on the nebula.
  final Color onHeroMuted;

  /// Fill of the hero leg chips (surface at 94% / 92%).
  final Color legChip;

  /// CTA fill (gradientStart to gradientEnd, horizontal).
  final LinearGradient ctaGradient;

  /// Label and icon on [ctaGradient] (and on the FAB / logomark gradient).
  final Color onGradient;

  /// Glow under the enabled primary AppButton.
  final List<BoxShadow> ctaGlow;

  /// Glow under the AppFab.
  final List<BoxShadow> fabGlow;

  /// Glow under the AppLogoMark at 64px or more.
  final List<BoxShadow> logoGlow;

  /// Gradient ring of the AppAvatar.
  final SweepGradient ringGradient;

  /// Glow under the AppAvatar at 64px or more.
  final List<BoxShadow> avatarGlow;

  /// Translucent fill of AppPanel, capsule tiles and Card. AA cap.
  final Color glass;

  /// 1px hairline on glass.
  final Color glassBorder;

  /// Top sheen on glass (none in light).
  final Color glassSheen;

  /// Ambient shadow of AppPanel (light only, empty in dark).
  final List<BoxShadow> panelShadow;

  /// Ambient shadow of capsule tiles (light only, empty in dark).
  final List<BoxShadow> tileShadow;

  /// Violet aurora, top-left. AA cap: 0.08 light / 0.18 dark.
  final Color auroraA;

  /// Aqua aurora, right. AA cap: 0.06 light / 0.10 dark.
  final Color auroraB;

  /// Faint violet aurora, bottom-right. AA cap: 0.04 light / 0.08 dark.
  final Color auroraC;

  /// Login spotlight. AA cap: 0.08 light / 0.10 dark.
  final Color spotlight;

  /// Lime pop (fill only) and the text on it.
  final Color spark;
  final Color onSpark;

  /// Fill of the 44px round AppBar chrome buttons.
  final Color chromeFill;

  /// Alpha of the kind glow wash on glass (Detalhe header). AA cap: 0.12.
  final double kindGlowAlpha;

  /// Alpha of primary-tint squircles (DetailRow icon).
  final double tintAlpha;

  /// AppBar fill when content scrolls under it.
  final Color scrolledBar;

  /// Radial wash used by AppBackdrop and the Detalhe kind glow.
  ///
  /// Fades to the same hue at alpha 0, never [Colors.transparent], which is
  /// transparent black and leaves grey fringes.
  RadialGradient wash(
    Color c, {
    required Alignment center,
    required double radius,
  }) => RadialGradient(
    center: center,
    radius: radius,
    colors: [c, c.withValues(alpha: 0)],
  );

  @override
  AppEffects copyWith({
    LinearGradient? heroGradient,
    LinearGradient? heroRim,
    Color? heroBlob,
    Color? heroOrbit,
    List<BoxShadow>? heroShadow,
    Color? onHero,
    Color? onHeroMuted,
    Color? legChip,
    LinearGradient? ctaGradient,
    Color? onGradient,
    List<BoxShadow>? ctaGlow,
    List<BoxShadow>? fabGlow,
    List<BoxShadow>? logoGlow,
    SweepGradient? ringGradient,
    List<BoxShadow>? avatarGlow,
    Color? glass,
    Color? glassBorder,
    Color? glassSheen,
    List<BoxShadow>? panelShadow,
    List<BoxShadow>? tileShadow,
    Color? auroraA,
    Color? auroraB,
    Color? auroraC,
    Color? spotlight,
    Color? spark,
    Color? onSpark,
    Color? chromeFill,
    double? kindGlowAlpha,
    double? tintAlpha,
    Color? scrolledBar,
  }) {
    return AppEffects(
      heroGradient: heroGradient ?? this.heroGradient,
      heroRim: heroRim ?? this.heroRim,
      heroBlob: heroBlob ?? this.heroBlob,
      heroOrbit: heroOrbit ?? this.heroOrbit,
      heroShadow: heroShadow ?? this.heroShadow,
      onHero: onHero ?? this.onHero,
      onHeroMuted: onHeroMuted ?? this.onHeroMuted,
      legChip: legChip ?? this.legChip,
      ctaGradient: ctaGradient ?? this.ctaGradient,
      onGradient: onGradient ?? this.onGradient,
      ctaGlow: ctaGlow ?? this.ctaGlow,
      fabGlow: fabGlow ?? this.fabGlow,
      logoGlow: logoGlow ?? this.logoGlow,
      ringGradient: ringGradient ?? this.ringGradient,
      avatarGlow: avatarGlow ?? this.avatarGlow,
      glass: glass ?? this.glass,
      glassBorder: glassBorder ?? this.glassBorder,
      glassSheen: glassSheen ?? this.glassSheen,
      panelShadow: panelShadow ?? this.panelShadow,
      tileShadow: tileShadow ?? this.tileShadow,
      auroraA: auroraA ?? this.auroraA,
      auroraB: auroraB ?? this.auroraB,
      auroraC: auroraC ?? this.auroraC,
      spotlight: spotlight ?? this.spotlight,
      spark: spark ?? this.spark,
      onSpark: onSpark ?? this.onSpark,
      chromeFill: chromeFill ?? this.chromeFill,
      kindGlowAlpha: kindGlowAlpha ?? this.kindGlowAlpha,
      tintAlpha: tintAlpha ?? this.tintAlpha,
      scrolledBar: scrolledBar ?? this.scrolledBar,
    );
  }

  @override
  AppEffects lerp(AppEffects? other, double t) {
    if (other == null) return this;
    return AppEffects(
      heroGradient: LinearGradient.lerp(heroGradient, other.heroGradient, t)!,
      heroRim: LinearGradient.lerp(heroRim, other.heroRim, t)!,
      heroBlob: Color.lerp(heroBlob, other.heroBlob, t)!,
      heroOrbit: Color.lerp(heroOrbit, other.heroOrbit, t)!,
      heroShadow: BoxShadow.lerpList(heroShadow, other.heroShadow, t)!,
      onHero: Color.lerp(onHero, other.onHero, t)!,
      onHeroMuted: Color.lerp(onHeroMuted, other.onHeroMuted, t)!,
      legChip: Color.lerp(legChip, other.legChip, t)!,
      ctaGradient: LinearGradient.lerp(ctaGradient, other.ctaGradient, t)!,
      onGradient: Color.lerp(onGradient, other.onGradient, t)!,
      ctaGlow: BoxShadow.lerpList(ctaGlow, other.ctaGlow, t)!,
      fabGlow: BoxShadow.lerpList(fabGlow, other.fabGlow, t)!,
      logoGlow: BoxShadow.lerpList(logoGlow, other.logoGlow, t)!,
      ringGradient: SweepGradient.lerp(ringGradient, other.ringGradient, t)!,
      avatarGlow: BoxShadow.lerpList(avatarGlow, other.avatarGlow, t)!,
      glass: Color.lerp(glass, other.glass, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      glassSheen: Color.lerp(glassSheen, other.glassSheen, t)!,
      panelShadow: BoxShadow.lerpList(panelShadow, other.panelShadow, t)!,
      tileShadow: BoxShadow.lerpList(tileShadow, other.tileShadow, t)!,
      auroraA: Color.lerp(auroraA, other.auroraA, t)!,
      auroraB: Color.lerp(auroraB, other.auroraB, t)!,
      auroraC: Color.lerp(auroraC, other.auroraC, t)!,
      spotlight: Color.lerp(spotlight, other.spotlight, t)!,
      spark: Color.lerp(spark, other.spark, t)!,
      onSpark: Color.lerp(onSpark, other.onSpark, t)!,
      chromeFill: Color.lerp(chromeFill, other.chromeFill, t)!,
      kindGlowAlpha: lerpDouble(kindGlowAlpha, other.kindGlowAlpha, t)!,
      tintAlpha: lerpDouble(tintAlpha, other.tintAlpha, t)!,
      scrolledBar: Color.lerp(scrolledBar, other.scrolledBar, t)!,
    );
  }
}

/// Shortcut: `context.effects.heroGradient`.
extension EffectsContext on BuildContext {
  AppEffects get effects {
    final effects = Theme.of(this).extension<AppEffects>();
    assert(
      effects != null,
      'AppEffects is missing. Use AppTheme.light() or AppTheme.dark().',
    );
    return effects!;
  }
}
