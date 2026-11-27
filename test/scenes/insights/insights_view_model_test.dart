import 'package:carteira_core/carteira_core.dart';
import 'package:carteira_digital/scenes/insights/insights_coordinator.dart';
import 'package:carteira_digital/scenes/insights/insights_view_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fakes.dart';

class _FakeCoordinator implements InsightsCoordinator {
  int expired = 0;

  @override
  void onSessionExpired() => expired++;
}

Expense _expense(String category, double amount, {String id = 'x'}) => Expense(
  id: id,
  amount: amount,
  description: 'gasto',
  date: DateTime(2026, 11, 5),
  account: 'Nubank',
  category: category.isEmpty ? null : category,
);

Page<Transaction> _page(List<Transaction> items) =>
    Page(items: items, page: 1, pageSize: 100, total: items.length);

InsightsViewModel _make({
  FakeTransactions? transactions,
  FakeAuth? auth,
  _FakeCoordinator? coordinator,
}) => InsightsViewModel(
  auth: auth ?? FakeAuth(),
  transactions: transactions ?? FakeTransactions(),
  coordinator: coordinator ?? _FakeCoordinator(),
  clock: () => DateTime(2026, 11, 27),
);

void main() {
  test('monta seis meses, do mais antigo ao atual', () async {
    final viewModel = _make(
      transactions: FakeTransactions(
        summaryResult: const Ok(Summary(month: '2026-11', income: 10, expense: 4)),
      ),
    );

    await viewModel.load();

    expect(viewModel.isLoading, isFalse);
    expect(viewModel.months, hasLength(InsightsViewModel.monthsShown));
    expect(viewModel.monthText, 'Novembro de 2026');
  });

  test('soma as saídas por categoria e calcula a participação', () async {
    final viewModel = _make(
      transactions: FakeTransactions(
        listResult: Ok(
          _page([
            _expense('Moradia', 300),
            _expense('Mercado', 60),
            _expense('Mercado', 50),
            _expense('', 90),
          ]),
        ),
      ),
    );

    await viewModel.load();

    expect(viewModel.categories.map((c) => c.category), [
      'Moradia',
      'Mercado',
      'Sem categoria',
    ]);
    expect(viewModel.totalExpense, 500);
    expect(viewModel.shareOf(viewModel.categories.first), '60%');
  });

  test('categorias demais viram "Outras"', () async {
    final viewModel = _make(
      transactions: FakeTransactions(
        listResult: Ok(
          _page([
            for (var i = 0; i < 8; i++) _expense('Cat $i', 100.0 - i),
          ]),
        ),
      ),
    );

    await viewModel.load();

    expect(viewModel.categories, hasLength(InsightsViewModel.maxCategories));
    expect(viewModel.categories.last.category, InsightsViewModel.othersLabel);
    // As três menores: 95 + 94 + 93.
    expect(viewModel.categories.last.total, 95 + 94 + 93);
  });

  test('escolher uma categoria troca o texto do centro da rosca', () async {
    final viewModel = _make(
      transactions: FakeTransactions(
        listResult: Ok(_page([_expense('Moradia', 300), _expense('Mercado', 100)])),
      ),
    );
    await viewModel.load();

    expect(viewModel.donutTitle, 'Total de saídas');

    viewModel.selectCategory(1);
    expect(viewModel.donutTitle, 'Mercado');

    viewModel.selectCategory(null);
    expect(viewModel.donutTitle, 'Total de saídas');
  });

  test('escolher um mês expõe o título e o resumo dele', () async {
    final viewModel = _make(
      transactions: FakeTransactions(
        summaryResult: const Ok(Summary(month: '2026-11', income: 10, expense: 4)),
      ),
    );
    await viewModel.load();

    viewModel.selectMonth(viewModel.months.length - 1);

    expect(viewModel.selectedMonthTitle, isNotNull);
    expect(viewModel.selectedMonthSummary?.balance, 6);
    expect(viewModel.shortMonthOf(viewModel.months.last), isNotEmpty);
  });

  test('sessão expirada encerra o login e avisa o coordinator', () async {
    final auth = FakeAuth();
    final coordinator = _FakeCoordinator();
    final viewModel = _make(
      auth: auth,
      coordinator: coordinator,
      transactions: FakeTransactions(
        listResult: const Failure(UnauthorizedError(expired: true)),
      ),
    );

    await viewModel.load();

    expect(auth.logoutCalls, 1);
    expect(coordinator.expired, 1);
  });

  test('falha vira mensagem de erro e uma nova carga se recupera', () async {
    final failing = FakeTransactions(
      listResult: const Failure(NetworkError()),
    );
    final viewModel = _make(transactions: failing);

    await viewModel.load();
    expect(viewModel.errorMessage, isNotNull);

    final good = FakeTransactions(
      listResult: Ok(_page([_expense('Moradia', 300)])),
    );
    final recovered = _make(transactions: good);
    await recovered.load();
    expect(recovered.errorMessage, isNull);
    expect(recovered.categories, hasLength(1));
  });
}
