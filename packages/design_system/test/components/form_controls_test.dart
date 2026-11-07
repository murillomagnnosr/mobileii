import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  final theme = AppTheme.light();
  final effects = theme.extension<AppEffects>()!;

  group('EmptyDivider', () {
    testWidgets('adds sm padding above and below a Divider', (tester) async {
      await tester.pumpWidget(wrap(const EmptyDivider()));

      final padding = tester.widget<Padding>(
        find
            .ancestor(of: find.byType(Divider), matching: find.byType(Padding))
            .first,
      );
      expect(
        padding.padding,
        const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      );
      expect(tester.widget<Divider>(find.byType(Divider)).indent, 0);
    });

    testWidgets('passes the indent to the line', (tester) async {
      await tester.pumpWidget(wrap(const EmptyDivider(indent: 48)));

      expect(tester.widget<Divider>(find.byType(Divider)).indent, 48);
      // The colour comes from the theme (outlineVariant), not the widget.
      expect(tester.widget<Divider>(find.byType(Divider)).color, isNull);
      expect(theme.dividerTheme.color, theme.colorScheme.outlineVariant);
    });
  });

  group('TransactionKindSelector', () {
    SegmentedButton<TransactionKind> button(WidgetTester tester) =>
        tester.widget<SegmentedButton<TransactionKind>>(
          find.byType(SegmentedButton<TransactionKind>),
        );

    for (final (kind, color) in [
      (TransactionKind.expense, AppColors.light.expense),
      (TransactionKind.income, AppColors.light.income),
      (TransactionKind.transfer, AppColors.light.transfer),
    ]) {
      testWidgets('selected ${kind.name} is a solid fill in its colour', (
        tester,
      ) async {
        await tester.pumpWidget(
          wrap(TransactionKindSelector(selected: kind, onChanged: (_) {})),
        );

        final style = button(tester).style!;
        expect(style.backgroundColor!.resolve({WidgetState.selected}), color);
        expect(
          style.foregroundColor!.resolve({WidgetState.selected}),
          AppColors.light.onKind,
        );
        expect(button(tester).selected, {kind});
        expect(button(tester).showSelectedIcon, isFalse);
      });
    }

    testWidgets('each segment shows its label and kind arrow', (tester) async {
      await tester.pumpWidget(
        wrap(
          TransactionKindSelector(
            selected: TransactionKind.expense,
            onChanged: (_) {},
          ),
        ),
      );

      expect(find.text('Saída'), findsOneWidget);
      expect(find.text('Entrada'), findsOneWidget);
      expect(find.text('Transf.'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
      expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
      expect(find.byIcon(Icons.swap_horiz_rounded), findsOneWidget);
    });

    testWidgets('disabled ignores taps', (tester) async {
      final picked = <TransactionKind>[];
      await tester.pumpWidget(
        wrap(
          TransactionKindSelector(
            selected: TransactionKind.expense,
            enabled: false,
            onChanged: picked.add,
          ),
        ),
      );

      expect(button(tester).onSelectionChanged, isNull);
      await tester.tap(find.text('Entrada'));
      await tester.pump();
      expect(picked, isEmpty);
    });
  });

  group('DetailRow', () {
    testWidgets('with icon shows a primary tint squircle', (tester) async {
      await tester.pumpWidget(
        wrap(
          const DetailRow(
            label: 'Data',
            value: '06/09/2026',
            icon: Icons.event_rounded,
          ),
        ),
      );

      final icon = tester.widget<Icon>(find.byIcon(Icons.event_rounded));
      expect(icon.color, theme.colorScheme.primary);
      expect(icon.size, 18);
      final box = tester.widget<DecoratedBox>(
        find
            .ancestor(
              of: find.byIcon(Icons.event_rounded),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );
      final decoration = box.decoration as BoxDecoration;
      expect(
        decoration.color,
        theme.colorScheme.primary.withValues(alpha: effects.tintAlpha),
      );
      expect(decoration.borderRadius, BorderRadius.circular(12));
      expect(
        tester.getSize(
          find
              .ancestor(
                of: find.byIcon(Icons.event_rounded),
                matching: find.byType(SizedBox),
              )
              .first,
        ),
        const Size(36, 36),
      );
    });

    testWidgets('reads as one "label: value" node', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        wrap(const DetailRow(label: 'Conta', value: 'Nubank')),
      );

      expect(find.bySemanticsLabel('Conta: Nubank'), findsOneWidget);
      expect(find.byType(Icon), findsNothing);
      semantics.dispose();
    });
  });

  group('AppTextField', () {
    testWidgets('disabled cannot be edited', (tester) async {
      final controller = TextEditingController(text: 'Nubank');
      addTearDown(controller.dispose);
      await tester.pumpWidget(
        wrap(
          AppTextField(label: 'Conta', controller: controller, enabled: false),
        ),
      );

      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
      expect(find.text('Conta'), findsOneWidget);
      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(
        tester
            .widget<EditableText>(find.byType(EditableText))
            .focusNode
            .hasFocus,
        isFalse,
      );
      expect(controller.text, 'Nubank');
    });

    testWidgets('maxLines makes it multi-line', (tester) async {
      await tester.pumpWidget(
        wrap(const AppTextField(label: 'Observação', maxLines: 3)),
      );

      expect(tester.widget<TextField>(find.byType(TextField)).maxLines, 3);
    });
  });
}
