// The money rules the README calls non-negotiable: display figures with a
// half-size "R$", figures that shrink instead of being cut, signs and arrows
// on tiles, and entrances that play once and honour reduced motion.
import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

/// Turns animations off, as the OS "reduce motion" setting does.
Widget _reducedMotion(Widget child) => Builder(
  builder: (context) => MediaQuery(
    data: MediaQuery.of(context).copyWith(disableAnimations: true),
    child: child,
  ),
);

final _entrance = find.byWidgetPredicate(
  (widget) => widget is TweenAnimationBuilder<double>,
);

TweenAnimationBuilder<double> _tween(WidgetTester tester) =>
    tester.widget<TweenAnimationBuilder<double>>(_entrance);

double _entranceOpacity(WidgetTester tester) => tester
    .widget<Opacity>(
      find.descendant(of: _entrance, matching: find.byType(Opacity)).first,
    )
    .opacity;

void main() {
  final effects = AppTheme.light().extension<AppEffects>()!;

  group('MoneyText', () {
    testWidgets('display splits a half-size "R\$" and scales down', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const SizedBox(
            width: 320,
            child: MoneyText('R\$ 4.196,51', size: MoneySize.display),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.style!.fontSize, AppTypography.displayLarge.fontSize);
      expect(text.style!.fontFamily, AppTypography.displayLarge.fontFamily);
      expect(text.style!.fontFeatures, AppTypography.tabularFigures);
      final spans = (text.textSpan! as TextSpan).children!.cast<TextSpan>();
      expect([for (final s in spans) s.text], ['', 'R\$ ', '4.196,51']);
      final currency = spans[1].style!;
      expect(currency.fontSize, AppTypography.displayLarge.fontSize! / 2);
      expect(currency.fontWeight, FontWeight.w600);
      expect(currency.fontVariations, const [FontVariation('wght', 600)]);
      // The plain text is unchanged, so find.text still works.
      expect(find.text('R\$ 4.196,51'), findsOneWidget);
      expect(find.byType(FittedBox), findsOneWidget);
    });

    testWidgets('display keeps the sign in front of the currency', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const MoneyText(
            'R\$ 120,00',
            size: MoneySize.display,
            tone: MoneyTone.expense,
            signed: true,
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      final spans = (text.textSpan! as TextSpan).children!.cast<TextSpan>();
      expect([for (final s in spans) s.text], ['−', 'R\$ ', '120,00']);
      expect(text.style!.color, AppColors.light.expense);
    });

    testWidgets('scaleDown shrinks a long value instead of cutting it', (
      tester,
    ) async {
      const value = 'R\$ 1.234.567.890,12';
      await tester.pumpWidget(
        wrap(
          const SizedBox(
            width: 120,
            child: MoneyText(value, size: MoneySize.large, scaleDown: true),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      final text = tester.widget<Text>(find.text(value));
      expect(text.overflow, isNull);
      expect(text.maxLines, 1);
      expect(find.byType(FittedBox), findsOneWidget);
      expect(
        tester.getSize(find.byType(FittedBox)).width,
        lessThanOrEqualTo(120),
      );
      // The paragraph keeps its natural width: the whole value is laid out.
      final paragraph = tester.renderObject<RenderParagraph>(find.text(value));
      expect(paragraph.didExceedMaxLines, isFalse);
      expect(paragraph.size.width, greaterThan(120));
    });

    testWidgets('display at narrow width also scales down', (tester) async {
      await tester.pumpWidget(
        wrap(
          const SizedBox(
            width: 100,
            child: MoneyText('R\$ 98.765.432,10', size: MoneySize.display),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(FittedBox)).width,
        lessThanOrEqualTo(100),
      );
    });

    testWidgets('without scaleDown a non-display figure may ellipsize', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const MoneyText('R\$ 89,90')));

      final text = tester.widget<Text>(find.text('R\$ 89,90'));
      expect(text.overflow, TextOverflow.ellipsis);
      expect(text.style!.fontSize, AppTypography.moneyMedium.fontSize);
      expect(find.byType(FittedBox), findsNothing);
    });

    testWidgets('small and large pick their money styles', (tester) async {
      await tester.pumpWidget(
        wrap(
          const Column(
            children: [
              MoneyText('R\$ 1,00', size: MoneySize.small),
              MoneyText('R\$ 2,00', size: MoneySize.large),
            ],
          ),
        ),
      );

      expect(
        tester.widget<Text>(find.text('R\$ 1,00')).style!.fontSize,
        AppTypography.moneySmall.fontSize,
      );
      expect(
        tester.widget<Text>(find.text('R\$ 2,00')).style!.fontSize,
        AppTypography.moneyLarge.fontSize,
      );
    });
  });

  group('TransactionTile', () {
    testWidgets('expense shows the up arrow and a red "−" amount', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const TransactionTile(
            kind: TransactionKind.expense,
            title: 'Aluguel',
            amount: 'R\$ 4.813,44',
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
      final amount = tester.widget<Text>(find.text('−R\$ 4.813,44'));
      expect(amount.style!.color, AppColors.light.expense);
    });

    testWidgets('income is "+" and transfer is unsigned', (tester) async {
      await tester.pumpWidget(
        wrap(
          const Column(
            children: [
              TransactionTile(
                kind: TransactionKind.income,
                title: 'Salário',
                amount: 'R\$ 9.526,55',
              ),
              TransactionTile(
                kind: TransactionKind.transfer,
                title: 'Reserva',
                amount: 'R\$ 500,00',
              ),
            ],
          ),
        ),
      );

      expect(
        tester.widget<Text>(find.text('+R\$ 9.526,55')).style!.color,
        AppColors.light.income,
      );
      expect(
        tester.widget<Text>(find.text('R\$ 500,00')).style!.color,
        AppColors.light.onSurface,
      );
    });

    testWidgets('capsule wraps the row in an AppPanel with tileShadow', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const TransactionTile(
            kind: TransactionKind.expense,
            title: 'Mercado',
            amount: 'R\$ 89,90',
            capsule: true,
          ),
        ),
      );

      final panel = find.ancestor(
        of: find.byType(ListTile),
        matching: find.byType(AppPanel),
      );
      expect(panel, findsOneWidget);
      final widget = tester.widget<AppPanel>(panel);
      expect(widget.padding, EdgeInsets.zero);
      expect(widget.shadows, effects.tileShadow);
    });

    testWidgets('plain row has no panel and no entrance', (tester) async {
      await tester.pumpWidget(
        wrap(
          const TransactionTile(
            kind: TransactionKind.expense,
            title: 'Mercado',
            amount: 'R\$ 89,90',
          ),
        ),
      );

      expect(find.byType(AppPanel), findsNothing);
      expect(_entrance, findsNothing);
    });

    testWidgets('entranceIndex fades in once with a capped stagger', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const TransactionTile(
            kind: TransactionKind.income,
            title: 'Salário',
            amount: 'R\$ 1,00',
            entranceIndex: 2,
          ),
        ),
      );

      expect(_tween(tester).duration, const Duration(milliseconds: 380));
      expect(_tween(tester).duration, AppDurations.listEntranceAt(2));
      expect(_entranceOpacity(tester), 0);
      await tester.pumpAndSettle();
      expect(_entranceOpacity(tester), 1);

      await tester.pumpWidget(
        wrap(
          const TransactionTile(
            kind: TransactionKind.income,
            title: 'Salário',
            amount: 'R\$ 1,00',
            entranceIndex: 9,
          ),
        ),
      );
      expect(_tween(tester).duration, const Duration(milliseconds: 500));
    });

    testWidgets('entrance is instant with reduced motion', (tester) async {
      await tester.pumpWidget(
        wrap(
          _reducedMotion(
            const TransactionTile(
              kind: TransactionKind.income,
              title: 'Salário',
              amount: 'R\$ 1,00',
              entranceIndex: 0,
            ),
          ),
        ),
      );

      expect(_tween(tester).duration, Duration.zero);
      expect(_entranceOpacity(tester), 1);
    });
  });

  group('BalanceCard', () {
    const card = BalanceCard(
      balance: 'R\$ 4.196,51',
      income: 'R\$ 9.526,55',
      expense: 'R\$ 5.330,04',
      monthLabel: 'Setembro 2026',
    );

    final sparkPill = find.byWidgetPredicate(
      (widget) =>
          widget is DecoratedBox &&
          widget.decoration is ShapeDecoration &&
          (widget.decoration as ShapeDecoration).color == effects.spark,
    );

    testWidgets('balance is a display figure in onHero', (tester) async {
      await tester.pumpWidget(wrap(card));
      await tester.pumpAndSettle();

      final money = tester.widget<MoneyText>(
        find.ancestor(
          of: find.text('R\$ 4.196,51'),
          matching: find.byType(MoneyText),
        ),
      );
      expect(money.size, MoneySize.display);
      expect(
        tester.widget<Text>(find.text('R\$ 4.196,51')).style!.color,
        effects.onHero,
      );
      // Legs keep the kind arrows and shrink instead of being cut.
      expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
      for (final leg in ['R\$ 9.526,55', 'R\$ 5.330,04']) {
        final legMoney = tester.widget<MoneyText>(
          find.ancestor(of: find.text(leg), matching: find.byType(MoneyText)),
        );
        expect(legMoney.scaleDown, isTrue);
      }
      expect(sparkPill, findsOneWidget);
    });

    testWidgets('without monthLabel there is no spark pill', (tester) async {
      await tester.pumpWidget(
        wrap(
          const BalanceCard(
            balance: 'R\$ 1,00',
            income: 'R\$ 2,00',
            expense: 'R\$ 1,00',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Saldo do mês'), findsOneWidget);
      expect(sparkPill, findsNothing);
    });

    testWidgets('animateIn fades and slides in once', (tester) async {
      await tester.pumpWidget(wrap(card));

      expect(_tween(tester).duration, AppDurations.slow);
      expect(_entranceOpacity(tester), 0);
      await tester.pumpAndSettle();
      expect(_entranceOpacity(tester), 1);
    });

    testWidgets('animateIn: false shows the card at once', (tester) async {
      await tester.pumpWidget(
        wrap(
          const BalanceCard(
            balance: 'R\$ 1,00',
            income: 'R\$ 2,00',
            expense: 'R\$ 1,00',
            animateIn: false,
          ),
        ),
      );

      expect(_entrance, findsNothing);
      expect(find.text('R\$ 1,00'), findsNWidgets(2));
    });

    testWidgets('entrance is instant with reduced motion', (tester) async {
      await tester.pumpWidget(wrap(_reducedMotion(card)));

      expect(_tween(tester).duration, Duration.zero);
      expect(_entranceOpacity(tester), 1);
    });
  });
}
