import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const bodyKey = Key('body');
  const fabKey = Key('fab');

  /// AppScaffold is a whole screen, so it is the app's home here instead of
  /// going through `wrap()`, whose Scaffold would sit around it. [padding]
  /// fakes the status bar and gesture bar insets.
  Widget app(
    Widget home, {
    bool dark = false,
    EdgeInsets padding = EdgeInsets.zero,
    GlobalKey<NavigatorState>? navigatorKey,
  }) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: dark ? AppTheme.dark() : AppTheme.light(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(padding: padding, viewPadding: padding),
        child: child!,
      ),
      home: home,
    );
  }

  Size screen(WidgetTester tester) =>
      tester.view.physicalSize / tester.view.devicePixelRatio;

  group('AppScaffold FAB fade', () {
    testWidgets('masks the body, not the FAB or the app bar', (tester) async {
      await tester.pumpWidget(
        app(
          AppScaffold(
            title: 'Extrato',
            body: const SizedBox.expand(key: bodyKey),
            floatingActionButton: AppFab(tooltip: 'Novo', onPressed: () {}),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final mask = tester.widget<ShaderMask>(
        find.ancestor(
          of: find.byKey(bodyKey),
          matching: find.byType(ShaderMask),
        ),
      );
      expect(mask.blendMode, BlendMode.dstIn);
      expect(
        find.ancestor(
          of: find.byType(AppFab),
          matching: find.byType(ShaderMask),
        ),
        findsNothing,
      );
      expect(
        find.ancestor(
          of: find.byType(AppBar),
          matching: find.byType(ShaderMask),
        ),
        findsNothing,
      );
    });

    testWidgets('no mask without a FAB', (tester) async {
      await tester.pumpWidget(
        app(
          const AppScaffold(
            title: 'Perfil',
            body: SizedBox.expand(key: bodyKey),
          ),
        ),
      );
      expect(
        find.descendant(
          of: find.byType(AppScaffold),
          matching: find.byType(ShaderMask),
        ),
        findsNothing,
      );
    });

    testWidgets('builds a shader for tall and for short bodies', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          AppScaffold(
            body: const SizedBox.expand(key: bodyKey),
            floatingActionButton: AppFab(tooltip: 'Novo', onPressed: () {}),
          ),
          padding: const EdgeInsets.only(bottom: 34),
        ),
      );
      final mask = tester.widget<ShaderMask>(find.byType(ShaderMask));
      // Shorter than the fade itself: the whole body fades, no bad stops.
      for (final rect in [
        const Rect.fromLTWH(0, 0, 400, 800),
        const Rect.fromLTWH(0, 0, 400, 40),
      ]) {
        expect(mask.shaderCallback(rect), isA<Shader>());
      }
    });
  });

  group('AppScaffold insets', () {
    testWidgets('body clears the status bar and runs under the gesture bar', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          const AppScaffold(
            showAppBar: false,
            padded: false,
            body: SizedBox.expand(key: bodyKey),
          ),
          padding: const EdgeInsets.only(top: 24, bottom: 34),
        ),
      );
      final safeArea = tester.widget<SafeArea>(
        find.ancestor(of: find.byKey(bodyKey), matching: find.byType(SafeArea)),
      );
      expect(safeArea.top, isTrue);
      expect(safeArea.bottom, isFalse);

      final body = tester.getRect(find.byKey(bodyKey));
      expect(body.top, 24);
      expect(body.bottom, screen(tester).height);
      // The bottom inset is still there for lists to add themselves.
      final insets = MediaQuery.paddingOf(tester.element(find.byKey(bodyKey)));
      expect(insets.top, 0);
      expect(insets.bottom, 34);
    });

    testWidgets('padded body sits on the screen gutter', (tester) async {
      await tester.pumpWidget(
        app(const AppScaffold(body: SizedBox.expand(key: bodyKey))),
      );
      final body = tester.getRect(find.byKey(bodyKey));
      expect(body.left, AppSpacing.screen);
      expect(body.right, screen(tester).width - AppSpacing.screen);
    });

    testWidgets('FAB sits on the screen gutter', (tester) async {
      await tester.pumpWidget(
        app(
          const AppScaffold(
            body: SizedBox.expand(),
            floatingActionButton: SizedBox.square(key: fabKey, dimension: 60),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.byKey(fabKey)).right,
        screen(tester).width - AppSpacing.screen,
      );
    });
  });

  group('AppScaffold app bar chrome', () {
    AppBar appBar(WidgetTester tester) =>
        tester.widget<AppBar>(find.byType(AppBar));

    testWidgets('without a back button the title starts on the gutter', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(const AppScaffold(title: 'Carteira', body: SizedBox.expand())),
      );
      expect(appBar(tester).leadingWidth, AppSpacing.screen * 2 + 44);
      expect(appBar(tester).titleSpacing, AppSpacing.screen);
      expect(tester.getRect(find.text('Carteira')).left, AppSpacing.screen);
    });

    testWidgets('the back circle sits on the gutter, the title follows it', (
      tester,
    ) async {
      final navigator = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        app(
          const AppScaffold(title: 'Início', body: SizedBox.expand()),
          navigatorKey: navigator,
        ),
      );
      navigator.currentState!.push(
        MaterialPageRoute<void>(
          builder: (_) =>
              const AppScaffold(title: 'Detalhe', body: SizedBox.expand()),
        ),
      );
      await tester.pumpAndSettle();

      expect(appBar(tester).titleSpacing, 0);
      final circle = tester.getRect(
        find
            .descendant(
              of: find.byType(BackButton),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(circle.size, const Size.square(44));
      expect(circle.left, AppSpacing.screen);
      expect(
        tester.getRect(find.text('Detalhe')).left,
        AppSpacing.screen * 2 + 44,
      );
    });

    testWidgets('an explicit leading also drops the title spacing', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          AppScaffold(
            title: 'Galeria',
            leading: IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () {},
            ),
            body: const SizedBox.expand(),
          ),
        ),
      );
      expect(appBar(tester).titleSpacing, 0);
    });

    testWidgets('the last action circle ends on the gutter', (tester) async {
      await tester.pumpWidget(
        app(
          AppScaffold(
            title: 'Detalhe',
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () {},
              ),
            ],
            body: const SizedBox.expand(),
          ),
        ),
      );
      final circle = tester.getRect(
        find
            .descendant(
              of: find.byType(IconButton),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(circle.size, const Size.square(44));
      expect(circle.right, screen(tester).width - AppSpacing.screen);
    });

    for (final dark in [false, true]) {
      final mode = dark ? 'dark' : 'light';
      final theme = dark ? AppTheme.dark() : AppTheme.light();
      final e = theme.extension<AppEffects>()!;

      testWidgets('chrome buttons are round tonal 44px buttons ($mode)', (
        tester,
      ) async {
        await tester.pumpWidget(
          app(
            dark: dark,
            AppScaffold(
              title: 'Detalhe',
              actions: [
                IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: () {},
                ),
              ],
              body: const SizedBox.expand(),
            ),
          ),
        );
        final style = IconButtonTheme.of(
          tester.element(find.byType(IconButton)),
        ).style!;
        const rest = <WidgetState>{};
        expect(style.backgroundColor!.resolve(rest), e.chromeFill);
        expect(
          style.foregroundColor!.resolve(rest),
          theme.colorScheme.onSurface,
        );
        expect(
          style.side!.resolve(rest)!.color,
          theme.colorScheme.outlineVariant,
        );
        expect(style.shape!.resolve(rest), isA<CircleBorder>());
        expect(style.fixedSize!.resolve(rest), const Size.square(44));
      });
    }
  });

  group('AppScaffold extras', () {
    testWidgets('brand puts the 28px logomark before the title', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          const AppScaffold(
            title: 'Carteira',
            brand: true,
            body: SizedBox.expand(),
          ),
        ),
      );
      final mark = tester.widget<AppLogoMark>(find.byType(AppLogoMark));
      expect(mark.size, 28);
      expect(
        tester.getRect(find.byType(AppLogoMark)).right,
        lessThan(tester.getRect(find.text('Carteira')).left),
      );
    });

    testWidgets('spotlight reaches the backdrop', (tester) async {
      await tester.pumpWidget(
        app(const AppScaffold(spotlight: true, body: SizedBox.expand())),
      );
      expect(
        tester.widget<AppBackdrop>(find.byType(AppBackdrop)).spotlight,
        isTrue,
      );
    });

    for (final dark in [false, true]) {
      final mode = dark ? 'dark' : 'light';
      final theme = dark ? AppTheme.dark() : AppTheme.light();

      testWidgets('without an app bar it still sets the status bar icons '
          '($mode)', (tester) async {
        await tester.pumpWidget(
          app(
            dark: dark,
            const AppScaffold(showAppBar: false, body: SizedBox.expand()),
          ),
        );
        expect(find.byType(AppBar), findsNothing);
        final region = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
          find
              .descendant(
                of: find.byType(AppScaffold),
                matching: find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
              )
              .first,
        );
        expect(region.value, theme.appBarTheme.systemOverlayStyle);
      });
    }

    testWidgets('settles: nothing on the screen loops', (tester) async {
      for (final dark in [false, true]) {
        await tester.pumpWidget(
          app(
            dark: dark,
            AppScaffold(
              title: 'Carteira',
              brand: true,
              spotlight: true,
              floatingActionButton: AppFab(tooltip: 'Novo', onPressed: () {}),
              body: const Column(
                children: [
                  AppPanel(child: Text('painel')),
                  AppLogoMark(spark: true),
                  KindOrb(kind: TransactionKind.income),
                  AppErrorBanner('Falhou.'),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.hasRunningAnimations, isFalse);
      }
    });
  });
}
