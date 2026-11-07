/// Motion durations. Go through `AppMotion.of` so reduced motion is honoured.
abstract final class AppDurations {
  /// Press feedback (CTA / FAB scale) and the password eye icon swap.
  static const Duration fast = Duration(milliseconds: 120);

  /// State changes: CTA decoration, password strength, StateView entrance.
  static const Duration normal = Duration(milliseconds: 220);

  /// Entrances: BalanceCard fade-in and AppFab pop-in.
  static const Duration slow = Duration(milliseconds: 400);

  /// Longest motion in the app (CategoryBar fill).
  static const Duration emphasized = Duration(milliseconds: 600);

  /// First row of a staggered list (`TransactionTile.entranceIndex` 0).
  static const Duration listEntrance = Duration(milliseconds: 300);

  /// Extra delay per row of a staggered list, capped at [staggerMaxSteps]
  /// steps (row 5 and later: 300 + 5 × 40 = 500 ms).
  static const Duration stagger = Duration(milliseconds: 40);

  /// Rows after this one arrive together with it.
  static const int staggerMaxSteps = 5;

  /// Entrance of the row at [index] in a staggered list:
  /// [listEntrance] plus [stagger] per row, capped at [staggerMaxSteps].
  static Duration listEntranceAt(int index) =>
      listEntrance + stagger * index.clamp(0, staggerMaxSteps);
}
