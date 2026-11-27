import '../../app/app_services.dart';
import '../../app/navigation.dart';
import '../login/login_factory.dart';
import '../shared/session_coordinator.dart';

/// O resumo não navega para lugar nenhum além do login, quando a sessão expira.
abstract interface class InsightsCoordinator implements SessionCoordinator {}

class DefaultInsightsCoordinator implements InsightsCoordinator {
  DefaultInsightsCoordinator({required this._services});

  final AppServices _services;

  @override
  void onSessionExpired() => resetToScene(LoginFactory.make(_services));
}
