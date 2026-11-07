import '../../app/app_services.dart';
import '../../app/navigation.dart';
import '../login/login_factory.dart';
import '../shared/session_coordinator.dart';

/// Navegação a partir do formulário de lançamento.
abstract interface class TransactionFormCoordinator
    implements SessionCoordinator {
  /// Salvou: fecha o formulário e volta para quem abriu.
  void onSaved();
}

class DefaultTransactionFormCoordinator implements TransactionFormCoordinator {
  DefaultTransactionFormCoordinator({required this._services});

  final AppServices _services;

  @override
  void onSaved() => popScene<void>();

  @override
  void onSessionExpired() => resetToScene(LoginFactory.make(_services));
}
