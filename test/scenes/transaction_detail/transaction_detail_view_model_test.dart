import 'package:carteira_core/carteira_core.dart';
import 'package:carteira_digital/scenes/transaction_detail/transaction_detail_coordinator.dart';
import 'package:carteira_digital/scenes/transaction_detail/transaction_detail_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fakes.dart';

class _FakeCoordinator implements TransactionDetailCoordinator {
  int expired = 0;
  int closed = 0;
  Transaction? edited;

  @override
  void onSessionExpired() => expired++;

  @override
  void close() => closed++;

  @override
  Future<void> showEdit(Transaction transaction) async => edited = transaction;
}

final _reserva = Transfer(
  id: 'tx_0058',
  amount: 500,
  description: 'Reserva',
  date: DateTime.utc(2026, 10, 20, 9),
  account: 'Nubank',
  toAccount: 'Itaú',
);

void main() {
  test('carrega e formata o lançamento', () async {
    final viewModel = TransactionDetailViewModel(
      id: 'tx_0058',
      auth: FakeAuth(),
      transactions: FakeTransactions(getResult: Ok(_reserva)),
      coordinator: _FakeCoordinator(),
    );

    await viewModel.load();

    expect(viewModel.isLoading, isFalse);
    expect(viewModel.title, 'Reserva');
    expect(viewModel.amountText, contains('500,00'));
    expect(viewModel.typeText, 'Transferência');
    expect(viewModel.accountText, 'Nubank → Itaú');
    expect(viewModel.categoryText, 'Sem categoria');
  });

  test('não encontrado vira estado de erro', () async {
    final viewModel = TransactionDetailViewModel(
      id: 'tx_9999',
      auth: FakeAuth(),
      transactions: FakeTransactions(),
      coordinator: _FakeCoordinator(),
    );

    await viewModel.load();

    expect(viewModel.errorMessage, isNotNull);
  });

  test('excluir chama o repositório e fecha', () async {
    final transactions = FakeTransactions(getResult: Ok(_reserva));
    final coordinator = _FakeCoordinator();
    final viewModel = TransactionDetailViewModel(
      id: 'tx_0058',
      auth: FakeAuth(),
      transactions: transactions,
      coordinator: coordinator,
    );
    await viewModel.load();

    await viewModel.delete();

    expect(transactions.deletedId, 'tx_0058');
    expect(coordinator.closed, 1);
  });

  test('falha ao excluir mantém a tela com a mensagem', () async {
    final coordinator = _FakeCoordinator();
    final viewModel = TransactionDetailViewModel(
      id: 'tx_0058',
      auth: FakeAuth(),
      transactions: FakeTransactions(
        getResult: Ok(_reserva),
        deleteResult: const Failure(NetworkError()),
      ),
      coordinator: coordinator,
    );
    await viewModel.load();

    await viewModel.delete();

    expect(coordinator.closed, 0);
    expect(viewModel.actionError, const NetworkError().message);
    expect(viewModel.isDeleting, isFalse);
  });

  test('editar abre o formulário com o lançamento atual', () async {
    final coordinator = _FakeCoordinator();
    final viewModel = TransactionDetailViewModel(
      id: 'tx_0058',
      auth: FakeAuth(),
      transactions: FakeTransactions(getResult: Ok(_reserva)),
      coordinator: coordinator,
    );
    await viewModel.load();

    await viewModel.edit();

    expect(coordinator.edited, _reserva);
  });
}
