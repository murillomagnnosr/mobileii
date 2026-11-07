import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppMotion', () {
    Future<Duration> resolve(
      WidgetTester tester, {
      required bool disableAnimations,
    }) async {
      late Duration result;
      await tester.pumpWidget(
        MediaQuery(
          data: MediaQueryData(disableAnimations: disableAnimations),
          child: Builder(
            builder: (context) {
              result = AppMotion.of(context, AppDurations.slow);
              return const SizedBox();
            },
          ),
        ),
      );
      return result;
    }

    testWidgets('keeps the duration by default', (tester) async {
      expect(
        await resolve(tester, disableAnimations: false),
        AppDurations.slow,
      );
    });

    testWidgets('returns zero when the OS asks for reduced motion', (
      tester,
    ) async {
      expect(await resolve(tester, disableAnimations: true), Duration.zero);
    });

    test('curves are the documented ones', () {
      expect(AppCurves.standard, Curves.easeOutCubic);
      expect(AppCurves.playful, Curves.easeOutBack);
    });
  });

  group('AppDurations', () {
    test('scale grows and never passes 600 ms', () {
      const scale = [
        AppDurations.fast,
        AppDurations.normal,
        AppDurations.slow,
        AppDurations.emphasized,
      ];
      expect(scale.map((d) => d.inMilliseconds), [120, 220, 400, 600]);
      expect(
        AppDurations.listEntranceAt(AppDurations.staggerMaxSteps),
        lessThanOrEqualTo(AppDurations.emphasized),
      );
    });

    test('list entrance staggers 40 ms per row, capped at 5 rows', () {
      expect(AppDurations.listEntrance, const Duration(milliseconds: 300));
      expect(AppDurations.stagger, const Duration(milliseconds: 40));
      expect(
        [for (var i = 0; i <= 7; i++) AppDurations.listEntranceAt(i)]
            .map((d) => d.inMilliseconds),
        [300, 340, 380, 420, 460, 500, 500, 500],
      );
      expect(AppDurations.listEntranceAt(-1), AppDurations.listEntrance);
    });
  });

  group('AppFonts.registerLicenses', () {
    tearDown(LicenseRegistry.reset);

    testWidgets('adds the two OFL licences, loaded from the bundle', (
      tester,
    ) async {
      LicenseRegistry.reset();
      AppFonts.registerLicenses();

      final entries = await tester.runAsync(
        () => LicenseRegistry.licenses.toList(),
      );

      final byPackage = {
        for (final entry in entries!)
          for (final package in entry.packages)
            package: entry.paragraphs.map((p) => p.text).join('\n'),
      };
      expect(byPackage.keys, containsAll(['PlusJakartaSans', 'SpaceGrotesk']));
      for (final text in [
        byPackage['PlusJakartaSans']!,
        byPackage['SpaceGrotesk']!,
      ]) {
        expect(text, contains('SIL Open Font License, Version 1.1'));
      }
    });
  });
}
