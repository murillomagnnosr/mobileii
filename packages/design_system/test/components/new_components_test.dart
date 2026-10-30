import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_helpers.dart';

void main() {
  group('AppChoiceChips', () {
    testWidgets('marks the selected option and reports taps', (tester) async {
      String? tapped;
      await tester.pumpWidget(
        wrap(
          AppChoiceChips<String>(
            options: const [
              (value: 'all', label: 'Todos'),
              (value: 'in', label: 'Entradas'),
            ],
            selected: 'all',
            onSelected: (value) => tapped = value,
          ),
        ),
      );
      final chips = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip));
      expect(chips.map((c) => c.selected), [true, false]);

      await tester.tap(find.text('Entradas'));
      expect(tapped, 'in');
    });
  });

  group('TransactionKindSelector', () {
    testWidgets('reports the new kind', (tester) async {
      TransactionKind? picked;
      await tester.pumpWidget(
        wrap(
          TransactionKindSelector(
            selected: TransactionKind.expense,
            onChanged: (kind) => picked = kind,
          ),
        ),
      );
      await tester.tap(find.text('Entrada'));
      expect(picked, TransactionKind.income);
    });
  });

  group('DetailRow', () {
    testWidgets('shows label and value', (tester) async {
      await tester.pumpWidget(
        wrap(const DetailRow(label: 'Conta', value: 'Nubank')),
      );
      expect(find.text('Conta'), findsOneWidget);
      expect(find.text('Nubank'), findsOneWidget);
    });
  });

  group('ProfileHeader', () {
    testWidgets('shows initials, name, e-mail and caption', (tester) async {
      await tester.pumpWidget(
        wrap(
          const ProfileHeader(
            name: 'Ana Ribeiro',
            email: 'ana@carteira.dev',
            caption: 'Cliente desde 2024',
          ),
        ),
      );
      expect(find.text('AR'), findsOneWidget);
      expect(find.text('Ana Ribeiro'), findsOneWidget);
      expect(find.text('ana@carteira.dev'), findsOneWidget);
      expect(find.text('Cliente desde 2024'), findsOneWidget);
    });
  });

  group('showConfirmDialog', () {
    /// Opens the dialog, taps [button] and returns what the future resolved to.
    Future<bool?> answer(WidgetTester tester, Finder button) async {
      bool? result;
      await tester.pumpWidget(
        wrap(
          Builder(
            builder: (context) => TextButton(
              onPressed: () async => result = await showConfirmDialog(
                context,
                title: 'Excluir?',
                message: 'Não dá para desfazer.',
                confirmLabel: 'Excluir',
                destructive: true,
              ),
              child: const Text('abrir'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      expect(find.text('Excluir?'), findsOneWidget);
      await tester.tap(button);
      await tester.pumpAndSettle();
      return result;
    }

    testWidgets('confirm resolves to true', (tester) async {
      final result = await answer(
        tester,
        find.byKey(const Key('confirm_dialog_confirm')),
      );
      expect(result, isTrue);
    });

    testWidgets('cancel resolves to false', (tester) async {
      final result = await answer(tester, find.text('Cancelar'));
      expect(result, isFalse);
    });
  });
}
