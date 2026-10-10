import 'package:carteira_core/carteira_core.dart';
import 'package:carteira_digital/scenes/home/home_coordinator.dart';
import 'package:carteira_digital/scenes/home/home_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fakes.dart';

class _FakeCoordinator implements HomeCoordinator {
  int expired = 0;

  @override
  void onSessionExpired() => expired++;
}

final _mercado = Expense(
  id: 'tx_0057',
  amount: 89.9,
  description: 'Mercado',
  date: DateTime(2026, 10, 6, 14, 32),
  account: 'Nubank',
  category: 'Alimentação',
);

final _page = Page<Transaction>(
  items: [_mercado],
  page: 1,
  pageSize: HomeViewModel.recentCount,
  total: 1,
);

final _summary = Summary(month: '2026-10', income: 9526.55, expense: 5330.04);

HomeViewModel _viewModel({
  required FakeAuth auth,
  required _FakeCoordinator coordinator,
  Result<Summary>? summary,
  Result<Page<Transaction>>? list,
  Result<User>? profile,
}) => HomeViewModel(
  auth: auth,
  users: FakeUsers(result: profile),
  transactions: FakeTransactions(
    summaryResult: summary ?? Ok(_summary),
    listResult: list ?? Ok(_page),
  ),
  coordinator: coordinator,
  clock: () => DateTime(2026, 10, 9),
);

void main() {
  test('carrega usuário, resumo e lançamentos do mês', () async {
    final auth = FakeAuth();
    final coordinator = _FakeCoordinator();
    final viewModel = _viewModel(auth: auth, coordinator: coordinator);

    await viewModel.load();

    expect(viewModel.isLoading, isFalse);
    expect(viewModel.errorMessage, isNull);
    expect(viewModel.greeting, 'Olá, Ana');
    expect(viewModel.monthText, 'Outubro de 2026');
    expect(viewModel.balanceText, contains('4.196,51'));
    expect(viewModel.incomeText, contains('9.526,55'));
    expect(viewModel.expenseText, contains('5.330,04'));
    expect(viewModel.recent.single.description, 'Mercado');
    expect(viewModel.amountOf(_mercado), contains('89,90'));
    expect(viewModel.subtitleOf(_mercado), '06/10 · Nubank');
    expect(auth.logoutCalls, 0);
    expect(coordinator.expired, 0);
  });

  test('token expirado encerra a sessão e volta ao login', () async {
    final auth = FakeAuth();
    final coordinator = _FakeCoordinator();
    final viewModel = _viewModel(
      auth: auth,
      coordinator: coordinator,
      list: const Failure(UnauthorizedError(expired: true)),
    );

    await viewModel.load();

    expect(auth.logoutCalls, 1);
    expect(coordinator.expired, 1);
  });

  test('servidor fora do ar mostra erro e não encerra a sessão', () async {
    final auth = FakeAuth();
    final coordinator = _FakeCoordinator();
    final viewModel = _viewModel(
      auth: auth,
      coordinator: coordinator,
      summary: const Failure(NetworkError()),
    );

    await viewModel.load();

    expect(viewModel.isLoading, isFalse);
    expect(viewModel.errorMessage, const NetworkError().message);
    expect(auth.logoutCalls, 0);
    expect(coordinator.expired, 0);
  });
}
