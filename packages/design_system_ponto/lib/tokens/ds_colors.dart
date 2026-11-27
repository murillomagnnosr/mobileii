import 'package:flutter/material.dart';

/// Paleta "Ponto": tinta azul-noite, maré (teal) e areia, com coral como acento.
/// Cada papel semântico tem um valor claro e um escuro — o tema escolhe um deles.
class DsColors {
  DsColors._();

  // Marca (primitivas)
  static const ink = Color(0xFF0E1A2B);
  static const tide = Color(0xFF1FB5A8);
  static const tideDeep = Color(0xFF0B7F76);
  static const sand = Color(0xFFF4EBDD);
  static const coral = Color(0xFFFF6B4A);
  static const amber = Color(0xFFF2B33D);
  static const white = Color(0xFFFFFFFF);

  /// Cores categóricas dos gráficos, na ordem de uso. Funcionam em claro e escuro.
  static const chartPalette = [
    Color(0xFF1FB5A8),
    Color(0xFFFF6B4A),
    Color(0xFFF2B33D),
    Color(0xFF7C8DF2),
    Color(0xFF5FD39A),
    Color(0xFFB86FD6),
    Color(0xFF8C8577),
  ];

  // Feedback
  static const success = Color(0xFF2E9E6A);
  static const warning = Color(0xFFE09A1A);
  static const danger = Color(0xFFD64545);

  // Papéis — modo claro
  static const light = DsSemanticColors(
    background: Color(0xFFFBF8F3),
    surface: white,
    surfaceVariant: sand,
    border: Color(0xFFE3DACB),
    textPrimary: ink,
    textSecondary: Color(0xFF5B6675),
    textOnAccent: white,
    accent: tideDeep,
    accentSoft: Color(0xFFD5F1EE),
    highlight: coral,
    success: success,
    warning: warning,
    danger: danger,
    disabled: Color(0xFFCFC8BA),
    disabledText: Color(0xFF8C8577),
  );

  // Papéis — modo escuro
  static const dark = DsSemanticColors(
    background: ink,
    surface: Color(0xFF15233A),
    surfaceVariant: Color(0xFF1D2F4A),
    border: Color(0xFF2B3E5C),
    textPrimary: Color(0xFFF1EDE4),
    textSecondary: Color(0xFFA9B4C4),
    textOnAccent: ink,
    accent: tide,
    accentSoft: Color(0xFF123B45),
    highlight: coral,
    success: Color(0xFF5FD39A),
    warning: amber,
    danger: Color(0xFFFF8A80),
    disabled: Color(0xFF34465F),
    disabledText: Color(0xFF6F7F96),
  );
}

/// Papéis semânticos. Componentes consomem estes nomes, nunca as primitivas.
@immutable
class DsSemanticColors {
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textOnAccent;
  final Color accent;
  final Color accentSoft;
  final Color highlight;
  final Color success;
  final Color warning;
  final Color danger;
  final Color disabled;
  final Color disabledText;

  const DsSemanticColors({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textOnAccent,
    required this.accent,
    required this.accentSoft,
    required this.highlight,
    required this.success,
    required this.warning,
    required this.danger,
    required this.disabled,
    required this.disabledText,
  });
}
