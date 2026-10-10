import 'package:flutter/material.dart';

import '../../app/app_services.dart';
import '../../app/navigation.dart';
import '../login/login_factory.dart';

/// Navegação para fora da home.
abstract interface class HomeCoordinator {
  /// Sessão ausente, inválida ou expirada: volta ao login sem permitir
  /// voltar à home.
  void onSessionExpired();
}

class DefaultHomeCoordinator implements HomeCoordinator {
  DefaultHomeCoordinator({required this._services});

  final AppServices _services;

  @override
  void onSessionExpired() {
    final login = LoginFactory.make(_services);
    appNavigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => login),
      (_) => false,
    );
  }
}
