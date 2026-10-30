import '../../app/app_services.dart';
import '../../app/navigation.dart';
import '../login/login_factory.dart';
import '../shared/session_coordinator.dart';
import '../transaction_detail/transaction_detail_factory.dart';
import '../transaction_form/transaction_form_factory.dart';

/// Navegação a partir do extrato.
abstract interface class TransactionsCoordinator implements SessionCoordinator {
  /// Abre o detalhe e espera fechar.
  Future<void> showTransaction(String id);

  /// Abre o formulário de criação e espera fechar.
  Future<void> showNewTransaction();
}

class DefaultTransactionsCoordinator implements TransactionsCoordinator {
  DefaultTransactionsCoordinator({required this._services});

  final AppServices _services;

  @override
  Future<void> showTransaction(String id) =>
      pushScene<void>(TransactionDetailFactory.make(_services, id));

  @override
  Future<void> showNewTransaction() =>
      pushScene<void>(TransactionFormFactory.make(_services));

  @override
  void onSessionExpired() => resetToScene(LoginFactory.make(_services));
}
