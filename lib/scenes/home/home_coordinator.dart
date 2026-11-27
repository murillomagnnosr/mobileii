import '../../app/app_services.dart';
import '../../app/navigation.dart';
import '../../app/shell_controller.dart';
import '../login/login_factory.dart';
import '../shared/session_coordinator.dart';
import '../transaction_detail/transaction_detail_factory.dart';
import '../transaction_form/transaction_form_factory.dart';

/// Navegação para fora da home. Os métodos `show*` esperam a cena aberta
/// fechar, para a home recarregar o que pode ter mudado.
abstract interface class HomeCoordinator implements SessionCoordinator {
  Future<void> showStatement();

  Future<void> showTransaction(String id);

  Future<void> showNewTransaction();

  Future<void> showProfile();
}

class DefaultHomeCoordinator implements HomeCoordinator {
  DefaultHomeCoordinator({required this._services});

  final AppServices _services;

  // Extrato e Perfil são abas do shell: trocar de aba não empilha tela.
  @override
  Future<void> showStatement() async =>
      _services.shell.select(ShellTab.statement);

  @override
  Future<void> showTransaction(String id) =>
      pushScene<void>(TransactionDetailFactory.make(_services, id));

  @override
  Future<void> showNewTransaction() =>
      pushScene<void>(TransactionFormFactory.make(_services));

  @override
  Future<void> showProfile() async => _services.shell.select(ShellTab.profile);

  @override
  void onSessionExpired() => resetToScene(LoginFactory.make(_services));
}
