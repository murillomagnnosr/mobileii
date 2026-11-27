import 'package:flutter/material.dart';

/// Curvas de animação padrão do design system.
class DsCurves {
  DsCurves._();

  /// Sai rápido e assenta devagar: boa para entradas e gráficos.
  static const emphasized = Curves.easeOutCubic;
}

/// Verdadeiro quando a pessoa pediu menos movimento nas configurações do aparelho.
bool dsDisableAnimations(BuildContext context) => MediaQuery.disableAnimationsOf(context);
