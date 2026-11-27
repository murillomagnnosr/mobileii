import 'package:flutter/widgets.dart';

import '../../app/app_services.dart';
import 'transactions_coordinator.dart';
import 'transactions_view.dart';
import 'transactions_view_model.dart';

/// Monta o extrato, injetando os repositórios no ViewModel.
abstract final class TransactionsFactory {
  static Widget make(AppServices services) {
    final viewModel = TransactionsViewModel(
      auth: services.auth,
      transactions: services.transactions,
      coordinator: DefaultTransactionsCoordinator(services: services),
    );
    return TransactionsView(viewModel: viewModel);
  }
}
