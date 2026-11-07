import 'package:carteira_core/carteira_core.dart';
import 'package:flutter/widgets.dart';

import '../../app/app_services.dart';
import 'transaction_form_coordinator.dart';
import 'transaction_form_view.dart';
import 'transaction_form_view_model.dart';

/// Monta o formulário: criação quando [initial] é null, edição caso contrário.
abstract final class TransactionFormFactory {
  static Widget make(AppServices services, {Transaction? initial}) {
    final viewModel = TransactionFormViewModel(
      auth: services.auth,
      transactions: services.transactions,
      coordinator: DefaultTransactionFormCoordinator(services: services),
      initial: initial,
    );
    return TransactionFormView(viewModel: viewModel);
  }
}
