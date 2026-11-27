import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  /// Decorations inside the mark: the tile first, then the spark dot.
  List<BoxDecoration> decorations(WidgetTester tester) => tester
      .widgetList<DecoratedBox>(
        find.descendant(
          of: find.byType(AppLogoMark),
          matching: find.byType(DecoratedBox),
        ),
      )
      .map((box) => box.decoration as BoxDecoration)
      .toList();

  Icon glyph(WidgetTester tester) =>
      tester.widget<Icon>(find.byIcon(Icons.account_balance_wallet_rounded));

  group('AppLogoMark', () {
    testWidgets('is decorative: hidden from screen readers', (tester) async {
      await tester.pumpWidget(wrap(const AppLogoMark(spark: true)));
      final exclude = tester.widget<ExcludeSemantics>(
        find
            .descendant(
              of: find.byType(AppLogoMark),
              matching: find.byType(ExcludeSemantics),
            )
            .first,
      );
      expect(exclude.excluding, isTrue);
    });

    for (final dark in [false, true]) {
      final mode = dark ? 'dark' : 'light';
      final theme = dark ? AppTheme.dark() : AppTheme.light();
      final e = theme.extension<AppEffects>()!;

      testWidgets('72px Login mark: gradient tile with glow ($mode)', (
        tester,
      ) async {
        await tester.pumpWidget(wrap(const AppLogoMark(), dark: dark));
        expect(tester.getSize(find.byType(AppLogoMark)), const Size(72, 72));

        final [tile] = decorations(tester);
        final gradient = tile.gradient! as LinearGradient;
        expect(gradient.colors, e.ctaGradient.colors);
        expect(gradient.begin, Alignment.topLeft);
        expect(gradient.end, Alignment.bottomRight);
        expect(tile.borderRadius, BorderRadius.circular(24));
        expect(tile.boxShadow, e.logoGlow);

        expect(glyph(tester).size, 34);
        expect(glyph(tester).color, e.onGradient);
      });

      testWidgets('28px app bar mark: no glow ($mode)', (tester) async {
        await tester.pumpWidget(wrap(const AppLogoMark(size: 28), dark: dark));
        expect(tester.getSize(find.byType(AppLogoMark)), const Size(28, 28));

        final [tile] = decorations(tester);
        expect(tile.gradient, isA<LinearGradient>());
        expect(tile.borderRadius, BorderRadius.circular(9));
        expect(tile.boxShadow, isNull);
        expect(glyph(tester).size, 16);
        expect(glyph(tester).color, e.onGradient);
      });

      testWidgets('spark dot is a spark fill ringed by the page ($mode)', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrap(const AppLogoMark(spark: true), dark: dark),
        );
        // The dot overhangs the corner without growing the mark.
        expect(tester.getSize(find.byType(AppLogoMark)), const Size(72, 72));

        final [_, dot] = decorations(tester);
        expect(dot.shape, BoxShape.circle);
        expect(dot.color, e.spark);
        expect(dot.gradient, isNull);
        expect(dot.boxShadow, isNull);
        final border = dot.border! as Border;
        expect(border.top.color, theme.scaffoldBackgroundColor);
        expect(border.top.width, 2);
      });
    }

    testWidgets('glow starts at 64px', (tester) async {
      await tester.pumpWidget(wrap(const AppLogoMark(size: 63)));
      expect(decorations(tester).single.boxShadow, isNull);

      await tester.pumpWidget(wrap(const AppLogoMark(size: 64)));
      expect(decorations(tester).single.boxShadow, isNotEmpty);
    });

    testWidgets('no spark dot unless asked', (tester) async {
      await tester.pumpWidget(wrap(const AppLogoMark()));
      expect(decorations(tester), hasLength(1));
      expect(
        find.descendant(
          of: find.byType(AppLogoMark),
          matching: find.byType(Positioned),
        ),
        findsNothing,
      );
    });
  });
}
