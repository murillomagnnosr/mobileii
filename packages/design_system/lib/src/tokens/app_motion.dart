import 'package:flutter/widgets.dart';

/// Motion curves.
abstract final class AppCurves {
  /// Default ease for entrances and state changes.
  static const Curve standard = Curves.easeOutCubic;

  /// Slight overshoot. Scale only, never on numbers.
  static const Curve playful = Curves.easeOutBack;
}

/// Motion helpers.
abstract final class AppMotion {
  /// [Duration.zero] when the OS asks for reduced motion, [d] otherwise.
  static Duration of(BuildContext context, Duration d) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : d;
}
