import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  group('AppErrorBanner', () {
    testWidgets('puts textKey on the message Text', (tester) async {
      await tester.pumpWidget(
        wrap(
          const AppErrorBanner(
            'E-mail ou senha inválidos.',
            textKey: Key('login_error'),
          ),
        ),
      );
      expect(find.text('E-mail ou senha inválidos.'), findsOneWidget);
      final text = tester.widget<Text>(find.byKey(const Key('login_error')));
      expect(text.data, 'E-mail ou senha inválidos.');
    });

    testWidgets('is announced as a live region', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(wrap(const AppErrorBanner('Sem conexão.')));
      expect(
        tester.getSemantics(find.byType(AppErrorBanner)),
        isSemantics(isLiveRegion: true, label: 'Sem conexão.'),
      );
      semantics.dispose();
    });

    for (final dark in [false, true]) {
      final mode = dark ? 'dark' : 'light';
      final theme = dark ? AppTheme.dark() : AppTheme.light();
      final s = theme.extension<AppSemanticColors>()!;

      testWidgets('error text and icon on the expense tint ($mode)', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrap(const AppErrorBanner('Falhou.'), dark: dark),
        );
        final box = tester.widget<DecoratedBox>(
          find
              .descendant(
                of: find.byType(AppErrorBanner),
                matching: find.byType(DecoratedBox),
              )
              .first,
        );
        final decoration = box.decoration as BoxDecoration;
        expect(decoration.color, s.expenseContainer);
        expect(decoration.color, theme.colorScheme.errorContainer);
        // A solid tint: no gradient and no glow.
        expect(decoration.gradient, isNull);
        expect(decoration.boxShadow, isNull);

        final icon = tester.widget<Icon>(
          find.byIcon(Icons.error_outline_rounded),
        );
        expect(icon.color, theme.colorScheme.error);

        final text = tester.widget<Text>(find.text('Falhou.'));
        expect(text.style!.color, theme.colorScheme.error);
        // Variable font: the weight needs the 'wght' axis too.
        expect(text.style!.fontWeight, FontWeight.w600);
        expect(text.style!.fontVariations, [const FontVariation('wght', 600)]);
      });
    }

    testWidgets('a long message wraps instead of overflowing', (tester) async {
      Widget banner(String message) =>
          wrap(SizedBox(width: 220, child: AppErrorBanner(message)));

      await tester.pumpWidget(banner('Falhou.'));
      final oneLine = tester.getSize(find.byType(AppErrorBanner)).height;

      await tester.pumpWidget(
        banner(
          'Não foi possível salvar o lançamento. Verifique sua conexão e '
          'tente de novo em alguns instantes.',
        ),
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(AppErrorBanner)).height,
        greaterThan(oneLine),
      );
    });
  });
}
