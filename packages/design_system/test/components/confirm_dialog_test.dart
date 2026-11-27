import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  group('ConfirmDialog', () {
    final scheme = AppTheme.light().colorScheme;

    Finder confirmButton() => find.byKey(const Key('confirm_dialog_confirm'));

    Color? circleColor(WidgetTester tester, IconData icon) {
      final box = tester.widget<DecoratedBox>(
        find
            .ancestor(
              of: find.byIcon(icon),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      return (box.decoration as BoxDecoration).color;
    }

    testWidgets('non-destructive uses the question icon and theme button', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const ConfirmDialog(
            title: 'Sair da conta?',
            message: 'Você precisará entrar de novo.',
          ),
        ),
      );

      expect(find.text('Sair da conta?'), findsOneWidget);
      expect(find.text('Você precisará entrar de novo.'), findsOneWidget);
      expect(find.text('Confirmar'), findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline_rounded), findsNothing);
      expect(
        tester.widget<Icon>(find.byIcon(Icons.help_outline_rounded)).color,
        scheme.primary,
      );
      expect(
        circleColor(tester, Icons.help_outline_rounded),
        scheme.primaryContainer,
      );
      // Solid theme FilledButton: no error colour, never a gradient.
      final style = tester.widget<FilledButton>(confirmButton()).style!;
      expect(style.backgroundColor, isNull);
      expect(style.minimumSize!.resolve({}), const Size(96, 44));
    });

    testWidgets('destructive paints the button and circle in error', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const ConfirmDialog(
            title: 'Excluir?',
            message: 'Não dá para desfazer.',
            destructive: true,
          ),
        ),
      );

      expect(find.byIcon(Icons.delete_outline_rounded), findsOneWidget);
      expect(
        tester.widget<Icon>(find.byIcon(Icons.delete_outline_rounded)).color,
        scheme.error,
      );
      expect(
        circleColor(tester, Icons.delete_outline_rounded),
        AppColors.light.expenseContainer,
      );
      final style = tester.widget<FilledButton>(confirmButton()).style!;
      expect(style.backgroundColor!.resolve({}), scheme.error);
      expect(style.foregroundColor!.resolve({}), scheme.onError);
    });

    testWidgets('custom icon and labels replace the defaults', (tester) async {
      await tester.pumpWidget(
        wrap(
          const ConfirmDialog(
            title: 'Sair?',
            message: 'Até logo.',
            icon: Icons.logout_rounded,
            confirmLabel: 'Sair',
            cancelLabel: 'Ficar',
          ),
        ),
      );

      expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
      expect(find.byIcon(Icons.help_outline_rounded), findsNothing);
      expect(find.text('Sair'), findsOneWidget);
      expect(find.text('Ficar'), findsOneWidget);
      expect(find.text('Cancelar'), findsNothing);
    });

    testWidgets('showConfirmDialog passes the options and the answer', (
      tester,
    ) async {
      final answers = <bool>[];
      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async => answers.add(
                await showConfirmDialog(
                  context,
                  title: 'Sair?',
                  message: 'Até logo.',
                  icon: Icons.logout_rounded,
                  confirmLabel: 'Sair',
                  cancelLabel: 'Ficar',
                ),
              ),
              child: const Text('abrir'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
      await tester.tap(find.text('Ficar'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sair'));
      await tester.pumpAndSettle();

      // Tapping the barrier dismisses: counts as false.
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();

      expect(answers, [false, true, false]);
    });
  });
}
