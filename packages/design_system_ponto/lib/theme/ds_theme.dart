import 'package:flutter/material.dart';

import '../tokens/ds_colors.dart';
import '../tokens/ds_spacing.dart';
import '../tokens/ds_typography.dart';

/// Expõe os papéis semânticos ao widget tree via `Theme.of(context).extension<DsThemeExtension>()`.
/// Prefira `context.ds` (ver fim do arquivo) nos componentes.
@immutable
class DsThemeExtension extends ThemeExtension<DsThemeExtension> {
  final DsSemanticColors colors;

  const DsThemeExtension(this.colors);

  @override
  DsThemeExtension copyWith({DsSemanticColors? colors}) => DsThemeExtension(colors ?? this.colors);

  @override
  DsThemeExtension lerp(ThemeExtension<DsThemeExtension>? other, double t) => this;
}

class DsTheme {
  DsTheme._();

  static ThemeData light() => _build(DsColors.light, Brightness.light);
  static ThemeData dark() => _build(DsColors.dark, Brightness.dark);

  static ThemeData _build(DsSemanticColors c, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: DsColors.tide,
      brightness: brightness,
    ).copyWith(
      primary: c.accent,
      onPrimary: c.textOnAccent,
      secondary: DsColors.coral,
      onSecondary: DsColors.white,
      surface: c.surface,
      onSurface: c.textPrimary,
      surfaceContainerHighest: c.surfaceVariant,
      outline: c.border,
      error: c.danger,
    );

    final radiusMd = BorderRadius.circular(DsRadius.md);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      fontFamily: DsTypography.family,
      textTheme: DsTypography.textTheme(primary: c.textPrimary, secondary: c.textSecondary),
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DsRadius.lg),
          side: BorderSide(color: c.border),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(horizontal: DsSpacing.md, vertical: DsSpacing.md),
        border: OutlineInputBorder(borderRadius: radiusMd, borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: radiusMd, borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: BorderSide(color: c.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: radiusMd,
          borderSide: BorderSide(color: c.danger, width: 1.5),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      chipTheme: ChipThemeData(
        backgroundColor: c.surfaceVariant,
        selectedColor: c.accentSoft,
        labelStyle: DsTypography.label.copyWith(color: c.textPrimary),
        side: BorderSide.none,
        shape: const StadiumBorder(),
      ),
      extensions: [DsThemeExtension(c)],
    );
  }
}

/// Atalho: `context.ds.accent`, `context.ds.surface`, etc.
extension DsThemeContext on BuildContext {
  DsSemanticColors get ds {
    final ext = Theme.of(this).extension<DsThemeExtension>();
    assert(ext != null, 'DsTheme não foi aplicado: use DsTheme.light() ou DsTheme.dark() no MaterialApp.');
    return ext!.colors;
  }
}
