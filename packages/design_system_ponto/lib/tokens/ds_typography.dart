import 'package:flutter/material.dart';

/// Escala tipográfica com nomes de papel (não de tamanho). Use `DsTypography.of(context)`.
/// Cor não é definida aqui: ela vem do tema, para funcionar em claro e escuro.
class DsTypography {
  DsTypography._();

  static const String family = 'Roboto';

  static const display = TextStyle(fontSize: 36, height: 1.1, fontWeight: FontWeight.w800, letterSpacing: -1);
  static const headline = TextStyle(fontSize: 26, height: 1.2, fontWeight: FontWeight.w800, letterSpacing: -0.5);
  static const title = TextStyle(fontSize: 20, height: 1.25, fontWeight: FontWeight.w700);
  static const subtitle = TextStyle(fontSize: 16, height: 1.3, fontWeight: FontWeight.w700);
  static const body = TextStyle(fontSize: 15, height: 1.5, fontWeight: FontWeight.w400);
  static const bodySmall = TextStyle(fontSize: 13, height: 1.45, fontWeight: FontWeight.w400);
  static const label = TextStyle(fontSize: 14, height: 1.2, fontWeight: FontWeight.w700, letterSpacing: 0.1);
  static const caption = TextStyle(fontSize: 12, height: 1.3, fontWeight: FontWeight.w600, letterSpacing: 0.3);

  /// Converte a escala de papéis no `TextTheme` do Material, para que widgets nativos herdem o estilo.
  static TextTheme textTheme({required Color primary, required Color secondary}) {
    TextStyle s(TextStyle base, Color c) => base.copyWith(color: c, fontFamily: family);
    return TextTheme(
      displaySmall: s(display, primary),
      headlineSmall: s(headline, primary),
      titleLarge: s(title, primary),
      titleMedium: s(subtitle, primary),
      bodyLarge: s(body, primary),
      bodyMedium: s(bodySmall, secondary),
      labelLarge: s(label, primary),
      labelSmall: s(caption, secondary),
    );
  }
}
