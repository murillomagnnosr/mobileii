import 'package:flutter/widgets.dart';

import '../../app/app_services.dart';
import 'transaction_detail_coordinator.dart';
import 'transaction_detail_view.dart';
import 'transaction_detail_view_model.dart';

/// Monta o detalhe do lançamento [id].
abstract final class TransactionDetailFactory {
  static Widget make(AppServices services, String id) {
    final viewModel = TransactionDetailViewModel(
      id: id,
      auth: services.auth,
      transactions: services.transactions,
      coordinator: DefaultTransactionDetailCoordinator(services: services),
    );
    return TransactionDetailView(viewModel: viewModel);
  }
}
