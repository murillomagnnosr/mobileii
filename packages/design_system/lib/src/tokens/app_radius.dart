import 'package:flutter/painting.dart';

/// Corner radii.
///
/// One-off radii (9, 12, 16, 18, 24, 26.5) are written inline with
/// `BorderRadius.circular(n)` where the spec names them.
abstract final class AppRadius {
  /// Small chips inside panels, swatches.
  static const double sm = 8;

  /// Text fields, KindOrb at 44px, SnackBar.
  static const double md = 14;

  /// AppPanel, Card, capsule tiles, ListTile ink shape, AppFab.
  static const double lg = 20;

  /// BalanceCard, Login panel, Detalhe header, dialogs, bottom-sheet top.
  static const double xl = 28;

  /// Buttons, chips, segments, pills, progress tracks.
  static const double pill = 999;

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}
