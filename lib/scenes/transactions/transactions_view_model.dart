import 'dart:async';

import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/foundation.dart';

import 'transactions_coordinator.dart';

/// Estado e ações do extrato: filtro por tipo, busca e paginação.
class TransactionsViewModel extends ChangeNotifier {
  TransactionsViewModel({
    required this._auth,
    required this._transactions,
    required this._coordinator,
  }) {
    // Mudanças feitas em outras abas atualizam o extrato sem piscar.
    _changes = _transactions.watch().listen((_) {
      // A exclusão por deslize já tirou o item daqui: recarregar só faria a
      // lista voltar para a primeira página.
      if (_skipNextReload) {
        _skipNextReload = false;
        return;
      }
      load(silent: true);
    });
  }

  static const pageSize = 20;

  final AuthRepository _auth;
  final TransactionRepository _transactions;
  final TransactionsCoordinator _coordinator;
  late final StreamSubscription<List<Transaction>> _changes;
  bool _skipNextReload = false;
  bool _disposed = false;

  /// Lançamentos deslizados que esperam o prazo do "Desfazer" para sumir de vez.
  final Set<String> _pendingDelete = {};

  final MoneyFormatter _money = MoneyFormatter.forCurrency(Currency.brl);

  TransactionFilter _filter = const TransactionFilter(pageSize: pageSize);
  List<Transaction> _items = const [];
  bool _hasMore = false;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;

  List<Transaction> get items => [
    for (final item in _items)
      if (!_pendingDelete.contains(item.id)) item,
  ];
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;

  /// Null = todos os tipos.
  TransactionType? get type => _filter.type;
  String get query => _filter.query ?? '';

  String amountOf(Transaction transaction) => _money.format(transaction.amount);

  /// Recarrega a partir da primeira página com o filtro atual.
  ///
  /// [silent] mantém a lista na tela durante a atualização (puxar para
  /// atualizar, mudanças vindas de outras abas); se falhar, nada é apagado.
  Future<void> load({bool silent = false}) async {
    _filter = _filter.copyWith(page: 1);
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    final result = await _transactions.list(_filter);
    if (_disposed) return;
    if (await _handleUnauthorized(result)) return;

    switch (result) {
      case Ok(value: final page):
        _items = page.items;
        _hasMore = page.hasMore;
        _errorMessage = null;
      case Failure(:final error):
        if (!silent || _items.isEmpty) _errorMessage = error.message;
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Busca a próxima página e junta ao fim da lista.
  Future<void> loadMore() async {
    if (!_hasMore || _isLoadingMore || _isLoading) return;
    _isLoadingMore = true;
    notifyListeners();

    final next = _filter.nextPage();
    final result = await _transactions.list(next);
    if (_disposed) return;
    if (await _handleUnauthorized(result)) return;

    if (result case Ok(value: final page)) {
      _filter = next;
      _items = [..._items, ...page.items];
      _hasMore = page.hasMore;
    }
    // Falha ao paginar mantém o que já está na tela; o botão continua lá.
    _isLoadingMore = false;
    notifyListeners();
  }

  void onTypeChanged(TransactionType? type) {
    if (type == _filter.type) return;
    _filter = _filter.copyWith(type: () => type);
    load();
  }

  void onQuerySubmitted(String query) {
    final trimmed = query.trim();
    if (trimmed == this.query) return;
    _filter = _filter.copyWith(query: () => trimmed.isEmpty ? null : trimmed);
    load();
  }

  Future<void> openTransaction(Transaction transaction) async {
    await _coordinator.showTransaction(transaction.id);
    await load();
  }

  Future<void> newTransaction() async {
    await _coordinator.showNewTransaction();
    await load();
  }

  /// Esconde [transaction] da lista na hora; a exclusão de verdade só
  /// acontece em [commitDelete], depois do prazo do "Desfazer".
  void scheduleDelete(Transaction transaction) {
    _pendingDelete.add(transaction.id);
    notifyListeners();
  }

  /// Traz de volta um lançamento escondido por [scheduleDelete].
  void undoDelete(Transaction transaction) {
    if (_pendingDelete.remove(transaction.id)) notifyListeners();
  }

  /// Exclui de verdade. Devolve `false` se falhar, e o lançamento volta à lista.
  Future<bool> commitDelete(Transaction transaction) async {
    if (!_pendingDelete.contains(transaction.id)) return true;

    final result = await _transactions.delete(transaction.id);
    if (_disposed) return result is Ok;
    if (await _handleUnauthorized(result)) return false;

    if (result is Ok) {
      _skipNextReload = true;
      _items = [
        for (final item in _items)
          if (item.id != transaction.id) item,
      ];
      _pendingDelete.remove(transaction.id);
      notifyListeners();
      return true;
    }
    _pendingDelete.remove(transaction.id);
    notifyListeners();
    return false;
  }

  @override
  void dispose() {
    _disposed = true;
    _changes.cancel();
    super.dispose();
  }

  Future<bool> _handleUnauthorized(Result<Object?> result) async {
    if (result.errorOrNull is! UnauthorizedError) return false;
    await _auth.logout();
    _coordinator.onSessionExpired();
    return true;
  }
}
