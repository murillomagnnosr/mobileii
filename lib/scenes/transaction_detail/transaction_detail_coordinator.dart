import 'package:carteira_core/carteira_core.dart';

import '../../app/app_services.dart';
import '../../app/navigation.dart';
import '../login/login_factory.dart';
import '../shared/session_coordinator.dart';
import '../transaction_form/transaction_form_factory.dart';

/// Navegação a partir do detalhe de um lançamento.
abstract interface class TransactionDetailCoordinator
    implements SessionCoordinator {
  /// Abre o formulário de edição e espera fechar.
  Future<void> showEdit(Transaction transaction);

  /// Fecha o detalhe (depois de excluir).
  void close();
}

class DefaultTransactionDetailCoordinator
    implements TransactionDetailCoordinator {
  DefaultTransactionDetailCoordinator({required this._services});

  final AppServices _services;

  @override
  Future<void> showEdit(Transaction transaction) => pushScene<void>(
    TransactionFormFactory.make(_services, initial: transaction),
  );

  @override
  void close() => popScene<void>();

  @override
  void onSessionExpired() => resetToScene(LoginFactory.make(_services));
}
