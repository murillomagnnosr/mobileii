import 'package:flutter/widgets.dart';

import '../../app/app_services.dart';
import 'profile_coordinator.dart';
import 'profile_view.dart';
import 'profile_view_model.dart';

/// Monta o perfil, injetando repositórios e o controle de tema.
abstract final class ProfileFactory {
  static Widget make(AppServices services) {
    final viewModel = ProfileViewModel(
      auth: services.auth,
      users: services.users,
      theme: services.theme,
      coordinator: DefaultProfileCoordinator(services: services),
    );
    return ProfileView(viewModel: viewModel);
  }
}
