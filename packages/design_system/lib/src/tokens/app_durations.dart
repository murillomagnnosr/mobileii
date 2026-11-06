/// Motion durations. Go through `AppMotion.of` so reduced motion is honoured.
abstract final class AppDurations {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 400);

  /// Longest motion in the app (CategoryBar fill).
  static const Duration emphasized = Duration(milliseconds: 600);
}
