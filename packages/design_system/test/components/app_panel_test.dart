import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  Finder inPanel(Finder matching) =>
      find.descendant(of: find.byType(AppPanel), matching: matching);

  /// Gradients of the [Ink] layers between the glass and the child.
  List<Gradient?> inkGradients(WidgetTester tester) => tester
      .widgetList<Ink>(inPanel(find.byType(Ink)))
      .map((ink) => (ink.decoration as BoxDecoration?)?.gradient)
      .toList();

  /// The shadow box behind the glass, or null when the panel draws none.
  ShapeDecoration? outerBox(WidgetTester tester) => tester
      .widgetList<DecoratedBox>(inPanel(find.byType(DecoratedBox)))
      .map((box) => box.decoration)
      .whereType<ShapeDecoration>()
      .singleOrNull;

  group('AppPanel', () {
    testWidgets('renders the child inside the default panel padding', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const AppPanel(child: Text('conteúdo'))));
      expect(find.text('conteúdo'), findsOneWidget);
      final padding = tester.widget<Padding>(
        find
            .ancestor(of: find.text('conteúdo'), matching: find.byType(Padding))
            .first,
      );
      expect(padding.padding, const EdgeInsets.all(AppSpacing.panel));
    });

    testWidgets('ripples of an InkWell inside paint on the panel', (
      tester,
    ) async {
      var taps = 0;
      await tester.pumpWidget(
        wrap(
          AppPanel(
            child: InkWell(onTap: () => taps++, child: const Text('linha')),
          ),
        ),
      );
      // The nearest Material above the InkWell is the panel itself, not the
      // Scaffold beneath the glass.
      final nearest = find
          .ancestor(of: find.byType(InkWell), matching: find.byType(Material))
          .first;
      expect(
        find.descendant(of: find.byType(AppPanel), matching: nearest),
        findsOneWidget,
      );
      await tester.tap(find.text('linha'));
      expect(taps, 1);
    });

    for (final dark in [false, true]) {
      final mode = dark ? 'dark' : 'light';
      final e = (dark ? AppTheme.dark() : AppTheme.light())
          .extension<AppEffects>()!;

      testWidgets('is glass with a hairline edge ($mode)', (tester) async {
        await tester.pumpWidget(
          wrap(const AppPanel(child: Text('x')), dark: dark),
        );
        final material = tester.widget<Material>(
          inPanel(find.byType(Material)),
        );
        expect(material.color, e.glass);
        expect(material.clipBehavior, Clip.antiAlias);
        final shape = material.shape! as RoundedRectangleBorder;
        expect(shape.side.color, e.glassBorder);
        expect(shape.borderRadius, BorderRadius.circular(AppRadius.lg));
        expect(find.byType(BackdropFilter), findsNothing);
      });

      testWidgets('glow is washed at kindGlowAlpha only when given ($mode)', (
        tester,
      ) async {
        bool isRadial(Gradient? g) => g is RadialGradient;

        await tester.pumpWidget(
          wrap(const AppPanel(child: Text('x')), dark: dark),
        );
        expect(inkGradients(tester).where(isRadial), isEmpty);

        const hue = Color(0xFF12B76A);
        await tester.pumpWidget(
          wrap(
            const AppPanel(glow: hue, child: Text('x')),
            dark: dark,
          ),
        );
        final wash = inkGradients(tester).whereType<RadialGradient>().single;
        expect(wash.colors.first, hue.withValues(alpha: e.kindGlowAlpha));
        expect(wash.colors.last, hue.withValues(alpha: 0));
      });

      testWidgets('custom radius reaches the glass and the shadow ($mode)', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrap(
            const AppPanel(
              radius: AppRadius.xl,
              shadows: [BoxShadow(blurRadius: 4)],
              child: Text('x'),
            ),
            dark: dark,
          ),
        );
        final material = tester.widget<Material>(
          inPanel(find.byType(Material)),
        );
        expect(
          (material.shape! as RoundedRectangleBorder).borderRadius,
          AppRadius.xlAll,
        );
        final decoration = outerBox(tester)!;
        expect(
          (decoration.shape as RoundedRectangleBorder).borderRadius,
          AppRadius.xlAll,
        );
        expect(decoration.shadows, const [BoxShadow(blurRadius: 4)]);
      });
    }

    testWidgets('light: ambient panelShadow and no sheen', (tester) async {
      final e = AppTheme.light().extension<AppEffects>()!;
      await tester.pumpWidget(wrap(const AppPanel(child: Text('x'))));
      expect(e.panelShadow, isNotEmpty);
      expect(outerBox(tester)!.shadows, e.panelShadow);
      expect(inkGradients(tester).whereType<LinearGradient>(), isEmpty);
    });

    testWidgets('dark: top sheen and no shadow at all', (tester) async {
      final e = AppTheme.dark().extension<AppEffects>()!;
      await tester.pumpWidget(
        wrap(const AppPanel(child: Text('x')), dark: true),
      );
      expect(outerBox(tester), isNull);
      final sheen = inkGradients(tester).whereType<LinearGradient>().single;
      expect(sheen.colors, [e.glassSheen, e.glassSheen.withValues(alpha: 0)]);
      expect(sheen.begin, Alignment.topCenter);
      expect(sheen.end, Alignment.bottomCenter);
    });

    testWidgets('an empty shadows list removes the light shadow', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const AppPanel(shadows: [], child: Text('x'))),
      );
      expect(outerBox(tester), isNull);
    });
  });
}
