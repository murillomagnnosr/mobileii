import '../../app/app_services.dart';
import '../../app/navigation.dart';
import '../home/home_factory.dart';

/// Navegação para fora da cena de login.
abstract interface class LoginCoordinator {
  /// Chamado quando o login dá certo: vai para a home sem voltar ao login.
  void onLoginSuccess();
}

class DefaultLoginCoordinator implements LoginCoordinator {
  DefaultLoginCoordinator({required this._services});

  final AppServices _services;

  @override
  void onLoginSuccess() => resetToScene(HomeFactory.make(_services));
}
