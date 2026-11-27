import '../../app/app_services.dart';
import '../../app/navigation.dart';
import '../login/login_factory.dart';
import '../shared/session_coordinator.dart';

/// Navegação a partir do perfil.
abstract interface class ProfileCoordinator implements SessionCoordinator {
  /// Saiu da conta: volta ao login sem permitir voltar.
  void onLoggedOut();
}

class DefaultProfileCoordinator implements ProfileCoordinator {
  DefaultProfileCoordinator({required this._services});

  final AppServices _services;

  @override
  void onLoggedOut() => resetToScene(LoginFactory.make(_services));

  @override
  void onSessionExpired() => resetToScene(LoginFactory.make(_services));
}
