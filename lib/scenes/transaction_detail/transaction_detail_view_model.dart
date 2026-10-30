import 'package:carteira_core/carteira_core.dart';
import 'package:carteira_design_system/carteira_design_system.dart';
import 'package:flutter/foundation.dart';

import '../shared/transaction_display.dart';
import 'transaction_detail_coordinator.dart';

/// Estado e ações do detalhe de um lançamento.
class TransactionDetailViewModel extends ChangeNotifier {
  TransactionDetailViewModel({
    required this._id,
    required this._auth,
    required this._transactions,
    required this._coordinator,
  });

  final String _id;
  final AuthRepository _auth;
  final TransactionRepository _transactions;
  final TransactionDetailCoordinator _coordinator;

  final MoneyFormatter _money = MoneyFormatter.forCurrency(Currency.brl);

  bool _isLoading = true;
  bool _isDeleting = false;
  String? _errorMessage;
  String? _actionError;
  Transaction? _transaction;

  bool get isLoading => _isLoading;
  bool get isDeleting => _isDeleting;

  /// Falha ao carregar: a tela inteira vira estado de erro.
  String? get errorMessage => _errorMessage;

  /// Falha ao excluir: a tela continua, com a mensagem embaixo.
  String? get actionError => _actionError;
  Transaction? get transaction => _transaction;

  TransactionKind get kind => _transaction?.kind ?? TransactionKind.expense;
  String get title => _transaction?.description ?? '';
  String get amountText => _money.format(_transaction?.amount ?? 0);
  String get typeText => _transaction?.type.label ?? '';
  String get dateText {
    final transaction = _transaction;
    return transaction == null ? '' : formatDateTime(transaction.date);
  }

  String get accountText => switch (_transaction) {
    Transfer(:final account, :final toAccount) => '$account → $toAccount',
    final transaction? => transaction.account,
    null => '',
  };

  String get categoryText => _transaction?.category ?? 'Sem categoria';
  String? get noteText => _transaction?.note;

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _transactions.getById(_id);
    if (await _handleUnauthorized(result)) return;

    _transaction = result.valueOrNull;
    _errorMessage = result.errorOrNull?.message;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> edit() async {
    final transaction = _transaction;
    if (transaction == null) return;
    await _coordinator.showEdit(transaction);
    await load();
  }

  /// A View pergunta antes ("Excluir lançamento?"); aqui só executa.
  Future<void> delete() async {
    if (_isDeleting) return;
    _isDeleting = true;
    _actionError = null;
    notifyListeners();

    final result = await _transactions.delete(_id);
    if (await _handleUnauthorized(result)) return;

    if (result case Failure(:final error)) {
      _isDeleting = false;
      _actionError = error.message;
      notifyListeners();
      return;
    }
    _isDeleting = false;
    _coordinator.close();
  }

  Future<bool> _handleUnauthorized(Result<Object?> result) async {
    if (result.errorOrNull is! UnauthorizedError) return false;
    await _auth.logout();
    _coordinator.onSessionExpired();
    return true;
  }
}
