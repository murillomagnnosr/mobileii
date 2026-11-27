import 'package:flutter/widgets.dart';

import '../../app/app_services.dart';
import 'home_coordinator.dart';
import 'home_view.dart';
import 'home_view_model.dart';

/// Monta a home, injetando os repositórios no ViewModel.
abstract final class HomeFactory {
  static Widget make(AppServices services) {
    final viewModel = HomeViewModel(
      auth: services.auth,
      users: services.users,
      transactions: services.transactions,
      coordinator: DefaultHomeCoordinator(services: services),
    );
    return HomeView(viewModel: viewModel);
  }
}
