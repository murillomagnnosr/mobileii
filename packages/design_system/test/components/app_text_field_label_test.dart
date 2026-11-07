import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  FloatingLabelBehavior? behaviorOf(WidgetTester tester) => tester
      .widget<TextField>(find.byType(TextField))
      .decoration!
      .floatingLabelBehavior;

  /// Opacity the decorator gives [text] (prefix or hint) right now.
  double opacityOf(WidgetTester tester, String text) => tester
      .widget<AnimatedOpacity>(
        find
            .ancestor(
              of: find.text(text),
              matching: find.byType(AnimatedOpacity),
            )
            .first,
      )
      .opacity;

  group('AppTextField floating label', () {
    testWidgets('a plain single-line field keeps the theme default', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const AppTextField(label: 'E-mail')));
      expect(behaviorOf(tester), isNull);
    });

    testWidgets('prefixText floats the label', (tester) async {
      await tester.pumpWidget(
        wrap(const AppTextField(label: 'Valor', prefixText: r'R$ ')),
      );
      expect(behaviorOf(tester), FloatingLabelBehavior.always);
    });

    testWidgets('a multi-line field floats the label', (tester) async {
      await tester.pumpWidget(
        wrap(const AppTextField(label: 'Observação', maxLines: 3)),
      );
      expect(behaviorOf(tester), FloatingLabelBehavior.always);
    });

    testWidgets('an explicit behavior wins over the default', (tester) async {
      await tester.pumpWidget(
        wrap(
          const AppTextField(
            label: 'Valor',
            prefixText: r'R$ ',
            maxLines: 2,
            floatingLabelBehavior: FloatingLabelBehavior.never,
          ),
        ),
      );
      expect(behaviorOf(tester), FloatingLabelBehavior.never);
    });

    testWidgets('an empty, unfocused Valor still shows R\$ and the hint', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const AppTextField(
            label: 'Valor',
            prefixText: r'R$ ',
            hint: '0,00',
            style: AppTypography.moneyInput,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(opacityOf(tester, r'R$ '), 1);
      expect(opacityOf(tester, '0,00'), 1);

      // The reason for the default: resting inside the field, the label
      // would hide both.
      await tester.pumpWidget(
        wrap(
          const AppTextField(
            label: 'Valor',
            prefixText: r'R$ ',
            hint: '0,00',
            style: AppTypography.moneyInput,
            floatingLabelBehavior: FloatingLabelBehavior.auto,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(opacityOf(tester, r'R$ '), 0);
      expect(opacityOf(tester, '0,00'), 0);
    });
  });
}
