import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Bundled fonts (Plus Jakarta Sans and Space Grotesk, both OFL 1.1).
abstract final class AppFonts {
  static const String _base = 'packages/carteira_design_system/assets/fonts';

  /// Registers both OFL licences in the [LicenseRegistry], so they show on
  /// the licences page. Call once in `main()` before `runApp`.
  static void registerLicenses() {
    LicenseRegistry.addLicense(() async* {
      yield LicenseEntryWithLineBreaks(const [
        'PlusJakartaSans',
      ], await rootBundle.loadString('$_base/OFL-PlusJakartaSans.txt'));
      yield LicenseEntryWithLineBreaks(const [
        'SpaceGrotesk',
      ], await rootBundle.loadString('$_base/OFL-SpaceGrotesk.txt'));
    });
  }
}
