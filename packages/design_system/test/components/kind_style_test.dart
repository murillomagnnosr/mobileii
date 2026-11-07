import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  /// Builds the theme and returns what [kindStyleOf] says for every kind.
  Future<Map<TransactionKind, KindStyle>> stylesOf(
    WidgetTester tester, {
    required bool dark,
  }) async {
    late Map<TransactionKind, KindStyle> styles;
    await tester.pumpWidget(
      wrap(
        dark: dark,
        Builder(
          builder: (context) {
            styles = {
              for (final kind in TransactionKind.values)
                kind: kindStyleOf(context, kind),
            };
            return const SizedBox();
          },
        ),
      ),
    );
    return styles;
  }

  BoxDecoration orbDecoration(WidgetTester tester) =>
      tester
              .widget<DecoratedBox>(
                find.descendant(
                  of: find.byType(KindOrb),
                  matching: find.byType(DecoratedBox),
                ),
              )
              .decoration
          as BoxDecoration;

  group('kindStyleOf', () {
    for (final dark in [false, true]) {
      final mode = dark ? 'dark' : 'light';
      final s = (dark ? AppTheme.dark() : AppTheme.light())
          .extension<AppSemanticColors>()!;

      testWidgets('maps each kind to its semantic colors ($mode)', (
        tester,
      ) async {
        final styles = await stylesOf(tester, dark: dark);

        final income = styles[TransactionKind.income]!;
        expect(income.color, s.income);
        expect(income.container, s.incomeContainer);
        expect(income.tone, MoneyTone.income);

        final expense = styles[TransactionKind.expense]!;
        expect(expense.color, s.expense);
        expect(expense.container, s.expenseContainer);
        expect(expense.tone, MoneyTone.expense);

        final transfer = styles[TransactionKind.transfer]!;
        expect(transfer.color, s.transfer);
        expect(transfer.container, s.transferContainer);
        expect(transfer.tone, MoneyTone.neutral);
      });
    }

    testWidgets('icons: down is money in, up is money out', (tester) async {
      final styles = await stylesOf(tester, dark: false);
      expect(
        styles[TransactionKind.income]!.icon,
        Icons.arrow_downward_rounded,
      );
      expect(styles[TransactionKind.expense]!.icon, Icons.arrow_upward_rounded);
      expect(styles[TransactionKind.transfer]!.icon, Icons.swap_horiz_rounded);
    });

    testWidgets('kinds never differ by color alone', (tester) async {
      for (final dark in [false, true]) {
        final styles = await stylesOf(tester, dark: dark);
        expect(styles.values.map((k) => k.icon).toSet(), hasLength(3));
        expect(styles.values.map((k) => k.color).toSet(), hasLength(3));
      }
    });

    testWidgets('icons do not change with the theme', (tester) async {
      final light = await stylesOf(tester, dark: false);
      final dark = await stylesOf(tester, dark: true);
      for (final kind in TransactionKind.values) {
        expect(dark[kind]!.icon, light[kind]!.icon);
        expect(dark[kind]!.tone, light[kind]!.tone);
      }
    });
  });

  group('KindOrb', () {
    for (final dark in [false, true]) {
      final mode = dark ? 'dark' : 'light';
      final theme = dark ? AppTheme.dark() : AppTheme.light();

      for (final kind in TransactionKind.values) {
        testWidgets('${kind.name}: kind icon on a tonal gradient ($mode)', (
          tester,
        ) async {
          await tester.pumpWidget(wrap(KindOrb(kind: kind), dark: dark));
          final style = kindStyleOf(tester.element(find.byType(KindOrb)), kind);

          final icon = tester.widget<Icon>(find.byIcon(style.icon));
          expect(icon.color, style.color);
          expect(icon.size, 22);

          final decoration = orbDecoration(tester);
          final gradient = decoration.gradient! as LinearGradient;
          expect(gradient.colors, [
            style.container,
            Color.lerp(style.container, theme.colorScheme.surface, 0.5),
          ]);
          final border = decoration.border! as Border;
          expect(border.top.color, style.color.withValues(alpha: 0.24));
          // KindOrb is in the gradient budget, not in the glow budget.
          expect(decoration.boxShadow, isNull);
        });
      }
    }

    testWidgets('squircle radius follows the size', (tester) async {
      await tester.pumpWidget(
        wrap(const KindOrb(kind: TransactionKind.income)),
      );
      expect(tester.getSize(find.byType(KindOrb)), const Size(44, 44));
      expect(orbDecoration(tester).shape, BoxShape.rectangle);
      expect(
        orbDecoration(tester).borderRadius,
        BorderRadius.circular(AppRadius.md),
      );

      await tester.pumpWidget(
        wrap(const KindOrb(kind: TransactionKind.income, size: 52)),
      );
      expect(tester.getSize(find.byType(KindOrb)), const Size(52, 52));
      expect(orbDecoration(tester).borderRadius, BorderRadius.circular(16));
      expect(
        tester.widget<Icon>(find.byIcon(Icons.arrow_downward_rounded)).size,
        26,
      );
    });

    testWidgets('circle variant has no corner radius', (tester) async {
      await tester.pumpWidget(
        wrap(
          const KindOrb(kind: TransactionKind.expense, size: 24, circle: true),
        ),
      );
      expect(tester.getSize(find.byType(KindOrb)), const Size(24, 24));
      expect(orbDecoration(tester).shape, BoxShape.circle);
      expect(orbDecoration(tester).borderRadius, isNull);
      expect(
        tester.widget<Icon>(find.byIcon(Icons.arrow_upward_rounded)).size,
        12,
      );
    });
  });
}
