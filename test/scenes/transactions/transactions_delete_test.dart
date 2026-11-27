import 'package:carteira_core/carteira_core.dart';
import 'package:carteira_digital/scenes/transactions/transactions_coordinator.dart';
import 'package:carteira_digital/scenes/transactions/transactions_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fakes.dart';

class _FakeCoordinator implements TransactionsCoordinator {
  @override
  void onSessionExpired() {}

  @override
  Future<void> showTransaction(String id) async {}

  @override
  Future<void> showNewTransaction() async {}
}

Expense _expense(String id) => Expense(
  id: id,
  amount: 10,
  description: 'Item $id',
  date: DateTime.utc(2026, 10, 1),
  account: 'Nubank',
);

Future<(TransactionsViewModel, FakeTransactions)> _loaded({
  Result<void>? deleteResult,
}) async {
  final transactions = FakeTransactions(
    deleteResult: deleteResult,
    pages: {
      1: Page(
        items: [_expense('a'), _expense('b'), _expense('c')],
        page: 1,
        pageSize: 20,
        total: 3,
      ),
    },
  );
  final viewModel = TransactionsViewModel(
    auth: FakeAuth(),
    transactions: transactions,
    coordinator: _FakeCoordinator(),
  );
  await viewModel.load();
  return (viewModel, transactions);
}

void main() {
  group('exclusão por deslize', () {
    test('scheduleDelete esconde o item sem chamar o servidor', () async {
      final (viewModel, transactions) = await _loaded();

      viewModel.scheduleDelete(viewModel.items[1]);

      expect(viewModel.items.map((t) => t.id), ['a', 'c']);
      expect(transactions.deletedId, isNull);
    });

    test('undoDelete traz o item de volta no mesmo lugar', () async {
      final (viewModel, transactions) = await _loaded();
      final removed = viewModel.items[1];

      viewModel.scheduleDelete(removed);
      viewModel.undoDelete(removed);

      expect(viewModel.items.map((t) => t.id), ['a', 'b', 'c']);
      expect(transactions.deletedId, isNull);
    });

    test('commitDelete exclui no servidor e tira o item da lista', () async {
      final (viewModel, transactions) = await _loaded();
      final removed = viewModel.items[1];

      viewModel.scheduleDelete(removed);
      final deleted = await viewModel.commitDelete(removed);

      expect(deleted, isTrue);
      expect(transactions.deletedId, 'b');
      expect(viewModel.items.map((t) => t.id), ['a', 'c']);
    });

    test('commitDelete que falha devolve o item à lista', () async {
      final (viewModel, _) = await _loaded(
        deleteResult: const Failure(NetworkError()),
      );
      final removed = viewModel.items[1];

      viewModel.scheduleDelete(removed);
      final deleted = await viewModel.commitDelete(removed);

      expect(deleted, isFalse);
      expect(viewModel.items.map((t) => t.id), ['a', 'b', 'c']);
    });

    test('commitDelete de um item desfeito não chama o servidor', () async {
      final (viewModel, transactions) = await _loaded();
      final removed = viewModel.items[1];

      viewModel.scheduleDelete(removed);
      viewModel.undoDelete(removed);
      await viewModel.commitDelete(removed);

      expect(transactions.deletedId, isNull);
    });
  });

  test('load silencioso não mostra o carregando e mantém a lista', () async {
    final (viewModel, _) = await _loaded();
    var sawLoading = false;
    viewModel.addListener(() => sawLoading |= viewModel.isLoading);

    await viewModel.load(silent: true);

    expect(sawLoading, isFalse);
    expect(viewModel.items, hasLength(3));
  });
}
