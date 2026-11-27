/// Escala de espaçamento em múltiplos de 4 (base 4pt).
class DsSpacing {
  DsSpacing._();

  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  /// Margem lateral padrão de telas — 16px em phone, conforme o layout mobile.
  static const double screenGutter = 16;

  /// Folga no fim de listas para o botão flutuante não cobrir o último item.
  static const double fabClearance = 88;
}

/// Raios de borda. Cantos mais arredondados que o Material padrão, com
/// "pílula" reservada para botões e chips.
class DsRadius {
  DsRadius._();

  static const double sm = 8;
  static const double md = 14;
  static const double lg = 20;
  static const double pill = 999;
}

/// Tamanhos fixos de controles — um único lugar para alturas de toque.
class DsSizes {
  DsSizes._();

  static const double buttonHeight = 52;
  static const double inputHeight = 56;
  static const double iconSm = 16;
  static const double iconMd = 20;
  static const double minTouchTarget = 44;
}

/// Duração e curva de animação padrão.
class DsMotion {
  DsMotion._();

  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
}
