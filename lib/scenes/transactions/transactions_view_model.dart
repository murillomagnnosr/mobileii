import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/foundation.dart';

import 'transactions_coordinator.dart';

/// Estado e ações do extrato: filtro por tipo, busca e paginação.
class TransactionsViewModel extends ChangeNotifier {
  TransactionsViewModel({
    required this._auth,
    required this._transactions,
    required this._coordinator,
  });

  static const pageSize = 20;

  final AuthRepository _auth;
  final TransactionRepository _transactions;
  final TransactionsCoordinator _coordinator;

  final MoneyFormatter _money = MoneyFormatter.forCurrency(Currency.brl);

  TransactionFilter _filter = const TransactionFilter(pageSize: pageSize);
  List<Transaction> _items = const [];
  bool _hasMore = false;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;

  List<Transaction> get items => _items;
  bool get hasMore => _hasMore;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;

  /// Null = todos os tipos.
  TransactionType? get type => _filter.type;
  String get query => _filter.query ?? '';

  String amountOf(Transaction transaction) => _money.format(transaction.amount);

  /// Recarrega a partir da primeira página com o filtro atual.
  Future<void> load() async {
    _filter = _filter.copyWith(page: 1);
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _transactions.list(_filter);
    if (await _handleUnauthorized(result)) return;

    switch (result) {
      case Ok(value: final page):
        _items = page.items;
        _hasMore = page.hasMore;
      case Failure(:final error):
        _errorMessage = error.message;
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

  Future<bool> _handleUnauthorized(Result<Object?> result) async {
    if (result.errorOrNull is! UnauthorizedError) return false;
    await _auth.logout();
    _coordinator.onSessionExpired();
    return true;
  }
}
