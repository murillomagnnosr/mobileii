import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  /// Radial washes painted by the backdrop, bottom to top.
  List<RadialGradient> washes(WidgetTester tester) => tester
      .widgetList<DecoratedBox>(
        find.descendant(
          of: find.byType(AppBackdrop),
          matching: find.byType(DecoratedBox),
        ),
      )
      .map((box) => (box.decoration as BoxDecoration).gradient)
      .whereType<RadialGradient>()
      .toList();

  group('AppBackdrop', () {
    for (final dark in [false, true]) {
      final mode = dark ? 'dark' : 'light';
      final theme = dark ? AppTheme.dark() : AppTheme.light();
      final e = theme.extension<AppEffects>()!;

      testWidgets('paints the ground and the three aurora washes ($mode)', (
        tester,
      ) async {
        await tester.pumpWidget(wrap(const AppBackdrop(), dark: dark));

        final ground = tester.widget<ColoredBox>(
          find.descendant(
            of: find.byType(AppBackdrop),
            matching: find.byType(ColoredBox),
          ),
        );
        expect(ground.color, theme.scaffoldBackgroundColor);

        expect(washes(tester).map((g) => g.colors.first), [
          e.auroraA,
          e.auroraB,
          e.auroraC,
        ]);
      });

      testWidgets('spotlight adds the spotlight wash on top ($mode)', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrap(const AppBackdrop(spotlight: true), dark: dark),
        );
        final colors = washes(tester).map((g) => g.colors.first).toList();
        expect(colors, hasLength(4));
        expect(colors.last, e.spotlight);
      });

      testWidgets('washes fade to the same hue, never transparent black '
          '($mode)', (tester) async {
        await tester.pumpWidget(
          wrap(const AppBackdrop(spotlight: true), dark: dark),
        );
        for (final wash in washes(tester)) {
          final [from, to] = wash.colors;
          expect(to.a, 0);
          expect((to.r, to.g, to.b), (from.r, from.g, from.b));
        }
      });
    }

    testWidgets('lets taps through to what sits under it', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrap(
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onTap: () => taps++,
                    child: const ColoredBox(color: Colors.white),
                  ),
                ),
                const AppBackdrop(),
              ],
            ),
          ),
        ),
      );
      await tester.tapAt(tester.getCenter(find.byType(AppBackdrop)));
      expect(taps, 1);
    });

    testWidgets('is isolated in a repaint boundary, without blur or glow', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const AppBackdrop(spotlight: true)));
      expect(
        find.descendant(
          of: find.byType(AppBackdrop),
          matching: find.byType(RepaintBoundary),
        ),
        findsOneWidget,
      );
      expect(find.byType(BackdropFilter), findsNothing);
      for (final box in tester.widgetList<DecoratedBox>(
        find.descendant(
          of: find.byType(AppBackdrop),
          matching: find.byType(DecoratedBox),
        ),
      )) {
        expect((box.decoration as BoxDecoration).boxShadow, isNull);
      }
    });
  });
}
