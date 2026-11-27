import 'package:carteira_core/carteira_core.dart';
import 'package:carteira_digital/scenes/transactions/transactions_coordinator.dart';
import 'package:carteira_digital/scenes/transactions/transactions_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fakes.dart';

class _FakeCoordinator implements TransactionsCoordinator {
  int expired = 0;
  final opened = <String>[];

  @override
  void onSessionExpired() => expired++;

  @override
  Future<void> showTransaction(String id) async => opened.add(id);

  @override
  Future<void> showNewTransaction() async => opened.add('new');
}

Expense _expense(String id) => Expense(
  id: id,
  amount: 10,
  description: 'Item $id',
  date: DateTime.utc(2026, 10, 1),
  account: 'Nubank',
);

void main() {
  test('carrega a primeira página e pagina com "Carregar mais"', () async {
    final transactions = FakeTransactions(
      pages: {
        1: Page(
          items: [_expense('a'), _expense('b')],
          page: 1,
          pageSize: 2,
          total: 3,
        ),
        2: Page(items: [_expense('c')], page: 2, pageSize: 2, total: 3),
      },
    );
    final viewModel = TransactionsViewModel(
      auth: FakeAuth(),
      transactions: transactions,
      coordinator: _FakeCoordinator(),
    );

    await viewModel.load();
    expect(viewModel.items.map((t) => t.id), ['a', 'b']);
    expect(viewModel.hasMore, isTrue);

    await viewModel.loadMore();
    expect(viewModel.items.map((t) => t.id), ['a', 'b', 'c']);
    expect(viewModel.hasMore, isFalse);
    expect(transactions.filters.last.page, 2);
  });

  test('filtro por tipo e busca vão para a consulta', () async {
    final transactions = FakeTransactions();
    final viewModel = TransactionsViewModel(
      auth: FakeAuth(),
      transactions: transactions,
      coordinator: _FakeCoordinator(),
    );

    viewModel.onTypeChanged(TransactionType.income);
    await Future<void>.delayed(Duration.zero);
    viewModel.onQuerySubmitted('  salário ');
    await Future<void>.delayed(Duration.zero);

    final last = transactions.filters.last;
    expect(last.type, TransactionType.income);
    expect(last.query, 'salário');
    expect(last.page, 1);
  });

  test('401 encerra a sessão', () async {
    final auth = FakeAuth();
    final coordinator = _FakeCoordinator();
    final viewModel = TransactionsViewModel(
      auth: auth,
      transactions: FakeTransactions(
        listResult: const Failure(UnauthorizedError()),
      ),
      coordinator: coordinator,
    );

    await viewModel.load();

    expect(auth.logoutCalls, 1);
    expect(coordinator.expired, 1);
  });

  test('abrir um lançamento recarrega a lista ao voltar', () async {
    final transactions = FakeTransactions();
    final coordinator = _FakeCoordinator();
    final viewModel = TransactionsViewModel(
      auth: FakeAuth(),
      transactions: transactions,
      coordinator: coordinator,
    );

    await viewModel.openTransaction(_expense('a'));

    expect(coordinator.opened, ['a']);
    expect(transactions.filters, hasLength(1));
  });
}
