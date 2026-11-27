import 'dart:math' as math;

import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG 2.x contrast ratio between two opaque colors.
double ratio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

// 4.49 / 2.99 absorb the small difference in computeLuminance's
// linearisation threshold against the reference script.
const double _text = 4.49;
const double _ui = 2.99;

/// Worst-case composites of one theme (section 13 of the design spec).
class _Grounds {
  _Grounds(this.p, this.e)
    : aurora = Color.alphaBlend(
        e.auroraC,
        Color.alphaBlend(e.auroraB, Color.alphaBlend(e.auroraA, p.background)),
      ) {
    glass = Color.alphaBlend(e.glassSheen, Color.alphaBlend(e.glass, aurora));
  }

  final AppColorPalette p;
  final AppEffects e;
  final Color aurora;
  late final Color glass;

  /// t = 0, 0.05 ... 1.
  static final List<double> samples = [for (var i = 0; i <= 20; i++) i / 20];

  Color hero(double t) => Color.alphaBlend(
    e.heroOrbit,
    Color.alphaBlend(e.heroBlob, Color.lerp(p.heroStart, p.heroEnd, t)!),
  );

  Color leg(double t) => Color.alphaBlend(e.legChip, hero(t));

  Color cta(double t) => Color.lerp(p.gradientStart, p.gradientEnd, t)!;

  Color kindGlow(Color k) =>
      Color.alphaBlend(k.withValues(alpha: e.kindGlowAlpha), glass);
}

void main() {
  final themes = {
    'light': (AppColors.light, AppTheme.light()),
    'dark': (AppColors.dark, AppTheme.dark()),
  };

  for (final MapEntry(key: name, value: (palette, theme)) in themes.entries) {
    group('contrast ($name)', () {
      final e = theme.extension<AppEffects>()!;
      final g = _Grounds(palette, e);
      final p = palette;

      void expectAtLeast(Color fg, Color bg, double min, String what) {
        final r = ratio(fg, bg);
        expect(r, greaterThanOrEqualTo(min), reason: '$what: $r < $min');
      }

      test('page text on aurora and glass', () {
        for (final (ground, label) in [
          (g.aurora, 'aurora'),
          (g.glass, 'glass'),
        ]) {
          expectAtLeast(p.onSurface, ground, _text, 'onSurface on $label');
          expectAtLeast(p.onSurfaceMuted, ground, _text, 'muted on $label');
          expectAtLeast(p.outline, ground, _ui, 'outline on $label');
        }
      });

      test('onGradient on 21 CTA samples', () {
        for (final t in _Grounds.samples) {
          expectAtLeast(p.onGradient, g.cta(t), _text, 'onGradient at $t');
        }
      });

      test('hero text on every nebula sample', () {
        for (final t in _Grounds.samples) {
          expectAtLeast(e.onHero, g.hero(t), _text, 'onHero at $t');
          expectAtLeast(e.onHeroMuted, g.hero(t), _text, 'onHeroMuted at $t');
        }
      });

      test('hero leg chips', () {
        for (final t in _Grounds.samples) {
          final leg = g.leg(t);
          expectAtLeast(p.income, leg, _text, 'income on leg at $t');
          expectAtLeast(p.expense, leg, _text, 'expense on leg at $t');
          expectAtLeast(p.onSurfaceMuted, leg, _text, 'muted on leg at $t');
        }
      });

      test('kinds: containers, solid fills and page', () {
        final kinds = [
          ('income', p.income, p.incomeContainer),
          ('expense', p.expense, p.expenseContainer),
          ('transfer', p.transfer, p.transferContainer),
        ];
        for (final (label, kind, container) in kinds) {
          expectAtLeast(kind, container, _text, '$label on container');
          expectAtLeast(p.onKind, kind, _text, 'onKind on $label');
          expectAtLeast(kind, g.aurora, _ui, '$label vs aurora');
        }
      });

      test('money on the Detalhe kind glow', () {
        expectAtLeast(
          p.expense,
          g.kindGlow(p.expense),
          _text,
          'expense on glow',
        );
        expectAtLeast(p.income, g.kindGlow(p.income), _text, 'income on glow');
      });

      test('onPrimaryContainer on primaryContainer', () {
        expectAtLeast(
          p.onPrimaryContainer,
          p.primaryContainer,
          _text,
          'onPrimaryContainer',
        );
      });

      test('alpha caps are not raised', () {
        final dark = name == 'dark';
        expect(e.auroraA.a, lessThanOrEqualTo(dark ? 0.18 : 0.08));
        expect(e.auroraB.a, lessThanOrEqualTo(dark ? 0.10 : 0.06));
        expect(e.auroraC.a, lessThanOrEqualTo(dark ? 0.08 : 0.04));
        expect(e.spotlight.a, lessThanOrEqualTo(dark ? 0.10 : 0.08));
        expect(e.heroBlob.a, lessThanOrEqualTo(dark ? 0.14 : 0.12));
        expect(e.heroOrbit.a, lessThanOrEqualTo(0.06 + 1e-3));
        expect(e.kindGlowAlpha, lessThanOrEqualTo(0.12));
      });
    });
  }
}
