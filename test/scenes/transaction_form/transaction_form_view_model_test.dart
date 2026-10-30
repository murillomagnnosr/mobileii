import 'package:carteira_core/carteira_core.dart';
import 'package:carteira_digital/scenes/transaction_form/transaction_form_coordinator.dart';
import 'package:carteira_digital/scenes/transaction_form/transaction_form_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fakes.dart';

class _FakeCoordinator implements TransactionFormCoordinator {
  int expired = 0;
  int saved = 0;

  @override
  void onSessionExpired() => expired++;

  @override
  void onSaved() => saved++;
}

TransactionFormViewModel _viewModel(
  FakeTransactions transactions,
  _FakeCoordinator coordinator, {
  Transaction? initial,
  FakeAuth? auth,
}) => TransactionFormViewModel(
  auth: auth ?? FakeAuth(),
  transactions: transactions,
  coordinator: coordinator,
  initial: initial,
  clock: () => DateTime(2026, 10, 30, 15, 45),
);

void main() {
  test('campos vazios mostram erros e não enviam', () async {
    final transactions = FakeTransactions();
    final coordinator = _FakeCoordinator();
    final viewModel = _viewModel(transactions, coordinator);

    await viewModel.submit();

    expect(viewModel.errorOf('amount'), isNotNull);
    expect(viewModel.errorOf('description'), isNotNull);
    expect(viewModel.errorOf('account'), isNotNull);
    expect(transactions.created, isNull);
    expect(coordinator.saved, 0);
  });

  test('cria uma saída com valor no formato brasileiro', () async {
    final transactions = FakeTransactions();
    final coordinator = _FakeCoordinator();
    final viewModel = _viewModel(transactions, coordinator)
      ..onAmountChanged('1.234,56')
      ..onDescriptionChanged(' Mercado ')
      ..onAccountChanged('Nubank')
      ..onCategoryChanged('');

    await viewModel.submit();

    final created = transactions.created;
    expect(created, isA<Expense>());
    expect(created!.amount, 1234.56);
    expect(created.description, 'Mercado');
    expect(created.category, isNull);
    expect(created.date, DateTime(2026, 10, 30, 15, 45).toUtc());
    expect(coordinator.saved, 1);
  });

  test('transferência exige conta de destino', () async {
    final transactions = FakeTransactions();
    final viewModel = _viewModel(transactions, _FakeCoordinator())
      ..onTypeChanged(TransactionType.transfer)
      ..onAmountChanged('500')
      ..onDescriptionChanged('Reserva')
      ..onAccountChanged('Nubank');

    await viewModel.submit();
    expect(viewModel.errorOf('toAccount'), isNotNull);

    viewModel.onToAccountChanged('Itaú');
    await viewModel.submit();
    expect(transactions.created, isA<Transfer>());
    expect((transactions.created! as Transfer).toAccount, 'Itaú');
  });

  test('edição parte do lançamento e chama update', () async {
    final initial = Income(
      id: 'tx_0059',
      amount: 9526.55,
      description: 'Salário',
      date: DateTime.utc(2026, 10, 25, 12),
      account: 'Itaú',
      category: 'Renda',
    );
    final transactions = FakeTransactions();
    final viewModel = _viewModel(
      transactions,
      _FakeCoordinator(),
      initial: initial,
    );

    expect(viewModel.isEditing, isTrue);
    expect(viewModel.amount, '9526,55');
    expect(viewModel.type, TransactionType.income);

    viewModel.onDescriptionChanged('Salário outubro');
    await viewModel.submit();

    expect(transactions.updated?.id, 'tx_0059');
    expect(transactions.updated?.description, 'Salário outubro');
    expect(transactions.created, isNull);
  });

  test('422 do servidor destaca os campos', () async {
    final coordinator = _FakeCoordinator();
    final viewModel =
        _viewModel(
            FakeTransactions(
              saveResult: const Failure(
                ValidationError({'date': 'must be an ISO 8601 date'}),
              ),
            ),
            coordinator,
          )
          ..onAmountChanged('10')
          ..onDescriptionChanged('Café')
          ..onAccountChanged('Nubank');

    await viewModel.submit();

    expect(viewModel.errorOf('date'), 'Data inválida.');
    expect(viewModel.errorMessage, isNotNull);
    expect(viewModel.isSaving, isFalse);
    expect(coordinator.saved, 0);
  });

  test('401 encerra a sessão', () async {
    final auth = FakeAuth();
    final coordinator = _FakeCoordinator();
    final viewModel =
        _viewModel(
            FakeTransactions(saveResult: const Failure(UnauthorizedError())),
            coordinator,
            auth: auth,
          )
          ..onAmountChanged('10')
          ..onDescriptionChanged('Café')
          ..onAccountChanged('Nubank');

    await viewModel.submit();

    expect(auth.logoutCalls, 1);
    expect(coordinator.expired, 1);
  });
}
