import 'package:flutter/widgets.dart';

import '../../app/app_services.dart';
import 'insights_coordinator.dart';
import 'insights_view.dart';
import 'insights_view_model.dart';

/// Monta o resumo (gráficos), injetando os repositórios no ViewModel.
abstract final class InsightsFactory {
  static Widget make(AppServices services) {
    final viewModel = InsightsViewModel(
      auth: services.auth,
      transactions: services.transactions,
      coordinator: DefaultInsightsCoordinator(services: services),
    );
    return InsightsView(viewModel: viewModel);
  }
}
