import 'package:flutter/widgets.dart';

import '../../app/app_services.dart';
import 'login_coordinator.dart';
import 'login_view.dart';
import 'login_view_model.dart';

/// Monta a cena de login, injetando os repositórios no ViewModel.
abstract final class LoginFactory {
  static Widget make(AppServices services) {
    final viewModel = LoginViewModel(
      auth: services.auth,
      coordinator: DefaultLoginCoordinator(services: services),
    );
    return LoginView(viewModel: viewModel);
  }
}
