import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  Finder inFab(Finder matching) =>
      find.descendant(of: find.byType(AppFab), matching: matching);

  /// Current pop-in scale (x scale of the outermost Transform of the FAB).
  double popScale(WidgetTester tester) => tester
      .widget<Transform>(inFab(find.byType(Transform)).first)
      .transform
      .entry(0, 0);

  /// Current press scale.
  double pressScale(WidgetTester tester) =>
      tester.widget<AnimatedScale>(inFab(find.byType(AnimatedScale))).scale;

  group('AppFab', () {
    testWidgets('calls onPressed and exposes the tooltip as its label', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      var taps = 0;
      await tester.pumpWidget(
        wrap(AppFab(tooltip: 'Novo lançamento', onPressed: () => taps++)),
      );
      await tester.pumpAndSettle();

      expect(find.byTooltip('Novo lançamento'), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(FloatingActionButton)),
        isSemantics(
          tooltip: 'Novo lançamento',
          isButton: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
      await tester.tap(find.byType(AppFab));
      expect(taps, 1);
      semantics.dispose();
    });

    testWidgets('shows the add icon by default and a custom one', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(AppFab(tooltip: 'Novo', onPressed: () {})));
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);

      await tester.pumpWidget(
        wrap(
          AppFab(tooltip: 'Editar', icon: Icons.edit_rounded, onPressed: () {}),
        ),
      );
      expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsNothing);
    });

    testWidgets('null onPressed disables it', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        wrap(const AppFab(tooltip: 'Novo lançamento', onPressed: null)),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<FloatingActionButton>(find.byType(FloatingActionButton))
            .onPressed,
        isNull,
      );
      expect(
        tester.getSemantics(find.byType(FloatingActionButton)),
        isSemantics(isEnabled: false, hasTapAction: false),
      );

      // Pressing a disabled FAB gives no press feedback either.
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(AppFab)),
      );
      await tester.pumpAndSettle();
      expect(pressScale(tester), 1);
      await gesture.up();
      semantics.dispose();
    });

    testWidgets('is 60x60 from the theme', (tester) async {
      await tester.pumpWidget(wrap(AppFab(tooltip: 'Novo', onPressed: () {})));
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byType(FloatingActionButton)),
        const Size(60, 60),
      );
    });

    for (final dark in [false, true]) {
      final mode = dark ? 'dark' : 'light';
      final e = (dark ? AppTheme.dark() : AppTheme.light())
          .extension<AppEffects>()!;

      testWidgets('sits on the brand gradient with the FAB glow ($mode)', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrap(
            AppFab(tooltip: 'Novo', onPressed: () {}),
            dark: dark,
          ),
        );
        await tester.pumpAndSettle();

        final box = tester.widget<DecoratedBox>(
          find
              .ancestor(
                of: find.byType(FloatingActionButton),
                matching: find.byType(DecoratedBox),
              )
              .first,
        );
        final decoration = box.decoration as BoxDecoration;
        final gradient = decoration.gradient! as LinearGradient;
        expect(gradient.colors, e.ctaGradient.colors);
        expect(gradient.begin, Alignment.topLeft);
        expect(gradient.end, Alignment.bottomRight);
        expect(decoration.borderRadius, AppRadius.lgAll);
        expect(decoration.boxShadow, e.fabGlow);

        // The FAB itself is see-through, so the gradient shows and the
        // splash paints on top of it.
        final fab = tester.widget<FloatingActionButton>(
          find.byType(FloatingActionButton),
        );
        expect(fab.backgroundColor, Colors.transparent);
        expect(fab.foregroundColor, e.onGradient);
        expect(fab.elevation, 0);
        expect(fab.highlightElevation, 0);
        final icon = tester.widget<Icon>(find.byIcon(Icons.add_rounded));
        expect(icon.size, 28);
      });
    }

    testWidgets('pops in once and settles', (tester) async {
      await tester.pumpWidget(wrap(AppFab(tooltip: 'Novo', onPressed: () {})));
      expect(popScale(tester), closeTo(0.8, 1e-6));

      await tester.pumpAndSettle();
      expect(popScale(tester), closeTo(1, 1e-6));
      expect(tester.hasRunningAnimations, isFalse);

      // A rebuild with new props does not replay the entrance. (wrap()
      // builds a fresh ThemeData, so the theme itself may cross-fade: only
      // the scale is checked frame by frame.)
      await tester.pumpWidget(
        wrap(AppFab(tooltip: 'Novo lançamento', onPressed: () {})),
      );
      for (var i = 0; i < 4; i++) {
        expect(popScale(tester), closeTo(1, 1e-6));
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pumpAndSettle();
    });

    testWidgets('skips the entrance under reduced motion', (tester) async {
      await tester.pumpWidget(
        wrap(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: AppFab(tooltip: 'Novo', onPressed: () {}),
          ),
        ),
      );
      await tester.pump();
      expect(popScale(tester), closeTo(1, 1e-6));
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('shrinks slightly while pressed', (tester) async {
      await tester.pumpWidget(wrap(AppFab(tooltip: 'Novo', onPressed: () {})));
      await tester.pumpAndSettle();
      expect(pressScale(tester), 1);

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(AppFab)),
      );
      await tester.pump();
      expect(pressScale(tester), 0.97);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(pressScale(tester), 1);
    });
  });
}
