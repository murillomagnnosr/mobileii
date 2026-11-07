/// Spacing scale on a 4pt grid.
///
/// Use the steps (directly or through `Gap`) instead of literal numbers;
/// the named slots below cover the recurring layout insets.
abstract final class AppSpacing {
  /// 2: hairline gap, e.g. between a name and its e-mail.
  static const double xxs = 2;

  /// 4: icon-to-label gap inside pills and small controls.
  static const double xs = 4;

  /// 8: between closely related items; spacing of capsule tiles and chips.
  static const double sm = 8;

  /// 12: between siblings in a row; vertical padding of a DetailRow.
  static const double md = 12;

  /// 16: between groups of content.
  static const double lg = 16;

  /// 24: between sections; StateView padding.
  static const double xl = 24;

  /// 32: large separation, e.g. before a screen's closing action (Sair).
  static const double xxl = 32;

  /// 48: the largest step, for sparse layouts.
  static const double xxxl = 48;

  /// Default horizontal padding of screens.
  static const double screen = 20;

  /// Default inner padding of an AppPanel.
  static const double panel = 20;

  /// Inner padding of the BalanceCard and the Detalhe header.
  static const double hero = 24;

  /// Bottom spacer under lists that sit below a FAB.
  static const double fabClearance = 104;
}
