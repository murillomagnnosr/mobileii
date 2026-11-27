import 'package:flutter/widgets.dart';

import '../../app/app_services.dart';
import '../../app/shell_controller.dart';
import '../home/home_factory.dart';
import '../insights/insights_factory.dart';
import '../profile/profile_factory.dart';
import '../transactions/transactions_factory.dart';
import 'shell_view.dart';

/// Monta o shell com as quatro cenas das abas, na ordem de [ShellTab].
abstract final class ShellFactory {
  static Widget make(AppServices services) {
    // Um novo login sempre começa no Início.
    services.shell.select(ShellTab.home);
    return ShellView(
      controller: services.shell,
      tabs: [
        HomeFactory.make(services),
        TransactionsFactory.make(services),
        InsightsFactory.make(services),
        ProfileFactory.make(services),
      ],
    );
  }
}
